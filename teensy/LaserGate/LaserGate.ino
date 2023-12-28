#include "Arduino.h"
#include "ArCOM.h"

/* #################################################
   ################ LaserGater #####################
// Generate gating signals for FISBA lasers. Can receive
// external trigger signals or act as a Bpod modulate to
// create gating signals based on serial commands.
// Current version created for Teensy 3.2.
  #################################################### */
  
/* #################################################
  ############## PIN CONFIGURATION ###################
  #################################################### */
  
// TTL outputs
// pins to create triggers
#define PIN_TRIALTRIG 16 // trial-start trigger that can be switched by serial command 'MAKE_TRIALTRIGGER'
#define PIN_STIMTRIG 15 // stimulus trigger that can be switched by serial command 'MAKE_STIMTRIGGER'
#define PIN_CAMTRIG 14 // camera trigger that can be switched by serial command 'MAKE_CAMTRIGGER'

// output for FISBA module 1
#define PIN_GND_1 6 // make this the ground pin for laser 1
#define PIN_RED_1 2 // trigger that is used to enable red (625nm) output from laser 1
#define PIN_CYAN_1 3 // trigger that is used to enable cyan (488nm) output from laser 1 - CARFEUL this is referred to as 'green' in the FISBA nomenclature but its really more blue-ish and should be used for most optogenetics
#define PIN_BLUE_1 4 // trigger that is used to enable violet (405nm) output from laser 1 - CARFEUL this is referred to as 'blue' in the FISBA nomenclature but really violet

// output for FISBA module 2
#define PIN_GND_2 22 // make this the ground pin for laser 2
#define PIN_RED_2 21 // trigger that is used to enable red (625nm) output from laser 2
#define PIN_CYAN_2 20 // trigger that is used to enable cyan (488nm) output from laser 2 - CARFEUL this is referred to as 'green' in the FISBA nomenclature but its really more blue-ish and should be used for most optogenetics
#define PIN_BLUE_2 19 // trigger that is used to enable violet (405nm) output from laser 2 - CARFEUL this is referred to as 'blue' in the FISBA nomenclature but really violet

// output for 2 valves (for airpuffs)
#define PIN_VALVE_OUT_1 11 // trigger for valve 1
#define PIN_VALVE_OUT_2 12 // trigger for valve 2

// TTL inputs
// pins to read potential enable triggers from
#define PIN_ENABLE_1 8 // enable signal for laser 1
#define PIN_ENABLE_2 9 // enable signal for laser 2
#define PIN_VALVE_IN 17 // enable signal for valves

/* #################################################
  ############## SERIAL COMMANDS ###################
  #################################################### */

// Serial-write variables
unsigned long FirmwareVersion = 2;
char moduleName[] = "LaserGate"; // Name of module for manual override UI and state machine assembler
ArCOM Serial1COM(Serial1); // UART serial port

// Byte codes for serial communication
// inputs
#define MAKE_STIMTRIGGER 101 // identifier to produce a stimulus trigger
#define MAKE_TRIALTRIGGER 102 // identifier to produce a trial onset trigger
#define MAKE_CAMTRIGGER 103 // identifier to produce a trigger for video cameras
#define STOP_CAMTRIGGER 104 // identifier to stop the trigger for video cameras
#define CHANGE_ENABLETRIGGERS 150 // identifier to adjust trigger output lines (expects two subsequent bytes: a number between 1-3 to enable either red (1), cyan(2) or violet(3) output for each module
#define CHANGE_VALVETRIGGERS 151 // identifier to adjust valve trigger output lines (expects one subsequent byte for valve1 (1), valve2 (2) or both (3))

#define GATE_BLUE1 160 // identifier to immediately create enable signal for blue1
#define GATE_CYAN1 161 // identifier to immediately create enable signal for cyan1
#define GATE_RED1 162 // identifier to immediately create enable signal for red1
#define GATE_BLUE2 163 // identifier to immediately create enable signal for blue2
#define GATE_CYAN2 164 // identifier to immediately create enable signal for cyan2
#define GATE_RED2 165 // identifier to immediately create enable signal for red2
#define GATE_BLUE_BOTH 166 // identifier to immediately create enable signal for both blue laser
#define GATE_CYAN_BOTH 167 // identifier to immediately create enable signal for both cyan laser
#define GATE_RED_BOTH 168 // identifier to immediately create enable signal for both red laser

#define STOP_BLUE1 170 // identifier to immediately stop enable signal for blue1
#define STOP_CYAN1 171 // identifier to immediately stop enable signal for cyan1
#define STOP_RED1 172 // identifier to immediately stop enable signal for red1
#define STOP_BLUE2 173 // identifier to immediately stop enable signal for blue2
#define STOP_CYAN2 174 // identifier to immediately stop enable signal for cyan2
#define STOP_RED2 175 // identifier to immediately stop enable signal for red2
#define STOP_BLUE_BOTH 176 // identifier to immediately stop enable signal for both blue laser
#define STOP_CYAN_BOTH 177 // identifier to immediately stop enable signal for both cyan laser
#define STOP_RED_BOTH 178 // identifier to immediately stop enable signal for both red laser

// return bytes
#define GOT_TRIGGER 14 // positive handshake for trigger command
#define DID_ABORT 15 // negative handshake for incoming bytes
#define HWRESET 128 // byte to reset teensy code
#define MODULE_INFO 255 // byte to return module info

// Other variables
bool midRead = false;
int FSMheader = 0;
unsigned long clocker = millis();
unsigned long camClocker = millis();
unsigned long gateClocker = millis();
unsigned long trialClocker = millis();
unsigned long stimClocker = millis();
int stimDur = 10; // duration of stimulus trigger in ms
int trialDur = 50; // duration of trial trigger in ms
int camDur = 30000; // maximal duration of camera trigger in ms (if no stop byte is received)
int gateDur = 60000; // maximal duration of gate trigger in ms (if no stop byte is received)
bool stimTrigger = false;
bool trialTrigger = false;
bool camTrigger = false;
bool gateTrigger = false;
byte cByte = 0; // temporary variable for serial communication
volatile int enable_1 = PIN_RED_1; //current enable line for laser module 1
volatile int enable_2 = PIN_RED_2; //current enable line for laser module 2
volatile int valveByte = 1; // which valve should be triggered in response to PIN_VALVE_IN

#define RESTART_ADDR 0xE000ED0C
#define READ_RESTART() (*(volatile uint32_t *)RESTART_ADDR)
#define WRITE_RESTART(val) ((*(volatile uint32_t *)RESTART_ADDR) = (val))

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void setup() {

  Serial1.begin(1312500); //baud rate for UART bpod serial communication
  Serial.begin(9600); // USB baud rate

  // Set pin modes for digital output lines
  pinMode(PIN_STIMTRIG, OUTPUT);
  pinMode(PIN_TRIALTRIG, OUTPUT);
  pinMode(PIN_CAMTRIG, OUTPUT);

  pinMode(PIN_GND_1, OUTPUT);
  pinMode(PIN_GND_2, OUTPUT);
  digitalWriteFast(PIN_GND_1, LOW);
  digitalWriteFast(PIN_GND_2, LOW);

  pinMode(PIN_RED_1, OUTPUT);
  pinMode(PIN_BLUE_1, OUTPUT);
  pinMode(PIN_CYAN_1, OUTPUT);
  pinMode(PIN_RED_2, OUTPUT);
  pinMode(PIN_BLUE_2, OUTPUT);
  pinMode(PIN_CYAN_2, OUTPUT); 
  pinMode(PIN_VALVE_OUT_1, OUTPUT); 
  pinMode(PIN_VALVE_OUT_2, OUTPUT);

  // Set pin modes for digital input lines
  pinMode(PIN_ENABLE_1, INPUT);
  pinMode(PIN_ENABLE_2, INPUT);
  pinMode(PIN_VALVE_IN, INPUT);

  attachInterrupt(digitalPinToInterrupt(PIN_ENABLE_1), EnableChange_1, CHANGE); // interupt to create enable triggers
  attachInterrupt(digitalPinToInterrupt(PIN_ENABLE_2), EnableChange_2, CHANGE); // interupt to create enable triggers
  attachInterrupt(digitalPinToInterrupt(PIN_VALVE_IN), ValveChange, CHANGE); // interupt to create valve triggers

}

void loop() {
  if (Serial.available() > 0) {
    if (!midRead) {
      FSMheader = Serial.read();
      midRead = true; // flag for current reading of serial information
      clocker = millis(); // counter to make sure that all serial information arrives within a reasonable time frame (currently 100ms)
    }

    if (FSMheader == MAKE_STIMTRIGGER) { // create stimulus trigger
      stimTrigger = true;
      stimClocker = millis();
      digitalWriteFast(PIN_STIMTRIG, HIGH); // set stimulus trigger to high

      Serial.write(GOT_TRIGGER);
      midRead = false;
    }

    if (FSMheader == MAKE_TRIALTRIGGER) { // create trial-onset trigger
      trialTrigger = true;
      trialClocker = millis();
      digitalWriteFast(PIN_TRIALTRIG, HIGH); // set trial trigger to high

      Serial.write(GOT_TRIGGER);
      midRead = false;
    }
    
    if (FSMheader == MAKE_CAMTRIGGER) { // create trial-onset trigger
      camTrigger = true;
      camClocker = millis();
      digitalWriteFast(PIN_CAMTRIG, HIGH); // set camera trigger to high

      Serial.write(GOT_TRIGGER);
      midRead = false;
    }

    if (FSMheader == STOP_CAMTRIGGER) { // create trial-onset trigger
      camTrigger = false;
      camClocker = millis();
      digitalWriteFast(PIN_CAMTRIG, LOW); // set camera trigger to low

      Serial.write(GOT_TRIGGER);
      midRead = false;
    }

    if (FSMheader == CHANGE_ENABLETRIGGERS) { // check which enable lines should be used for laser modules 1 and 2

      if (Serial.available() > 1){
        // check laser l
        cByte = Serial.read();
        if (cByte == 1) {enable_1 = PIN_RED_1;} // enable red line
        else if (cByte == 2) {enable_1 = PIN_CYAN_1;} // enable 488nm line
        else if (cByte == 3) {enable_1 = PIN_BLUE_1;} // enable 405nm line
        else {Serial.write(DID_ABORT);}

        // check laser 2
        cByte = Serial.read();
        if (cByte == 1) {enable_2 = PIN_RED_2;} // enable red line
        else if (cByte == 2) {enable_2 = PIN_CYAN_2;} // enable 488nm line
        else if (cByte == 3) {enable_2 = PIN_BLUE_2;} // enable 405nm line
        else {Serial.write(DID_ABORT);}

        // done
        Serial.write(GOT_TRIGGER);
        midRead = false;
      }
    }
    
    if (FSMheader == CHANGE_VALVETRIGGERS) { // check which trigger lines should be used for valve 1 and 2
      if (Serial.available() > 0){
        
        valveByte = Serial.read();
        if (valveByte >= 1 && valveByte <= 3) {Serial.write(GOT_TRIGGER);} // valveByte needs to be between 1 and 3
        else {valveByte = 0; Serial.write(DID_ABORT);}
        
        // done
        midRead = false;
      }
    }
  }

  if (midRead && ((millis() - clocker) >= 1000)) {
    midRead = false; Serial.write(FSMheader);
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // check stim trigger
  if (stimTrigger) {
    if ((millis() - stimClocker) > stimDur) {  // done with stim trigger
      digitalWriteFast(PIN_STIMTRIG, LOW); // set stimulus trigger to low
      stimTrigger = false;
    }
  }

  // check trial trigger
  if (trialTrigger) {
    if ((millis() - trialClocker) > trialDur) {  // done with trial trigger
      digitalWriteFast(PIN_TRIALTRIG, LOW); // set trial trigger to low
      trialTrigger = false;
    }
  }
  
  // check camera trigger
  if (camTrigger) {
    if ((millis() - camClocker) > camDur) {  // done with camera trigger
      digitalWriteFast(PIN_CAMTRIG, LOW); // set trial trigger to low
      camTrigger = false;
    }
  }

  // check gate trigger
  if (gateTrigger) {
    if ((millis() - gateClocker) > gateDur) {  // done with camera trigger
      digitalWriteFast(PIN_BLUE_1, LOW);
      digitalWriteFast(PIN_CYAN_1, LOW);
      digitalWriteFast(PIN_RED_1, LOW);
      digitalWriteFast(PIN_BLUE_2, LOW);
      digitalWriteFast(PIN_CYAN_2, LOW);
      digitalWriteFast(PIN_RED_2, LOW);
      gateTrigger = false;
    }
  }
}

// for Bpod communication 
void serialEvent1() {
  FSMheader = Serial1COM.readByte();
  
  switch (FSMheader) {
  case HWRESET:
    Serial1.write(GOT_TRIGGER);
    delayMicroseconds(5000); // wait a moment to make sure response byte is written
    WRITE_RESTART(0x5FA0004);
    break;
    
  case MODULE_INFO: // return module information to bpod
      returnModuleInfo();
      break;

  case CHANGE_ENABLETRIGGERS: // check which enable lines should be used for laser modules 1 and 2
    // check laser l
    cByte = Serial1COM.readByte();
    if (cByte == 1) {enable_1 = PIN_RED_1;} // enable red line
    else if (cByte == 2) {enable_1 = PIN_CYAN_1;} // enable 488nm line
    else if (cByte == 3) {enable_1 = PIN_BLUE_1;} // enable 405nm line
    else {Serial.write(DID_ABORT);}
  
    // check laser 2
    cByte = Serial1COM.readByte();
    if (cByte == 1) {enable_2 = PIN_RED_2;} // enable red line
    else if (cByte == 2) {enable_2 = PIN_CYAN_2;} // enable 488nm line
    else if (cByte == 3) {enable_2 = PIN_BLUE_2;} // enable 405nm line
    else {Serial1.write(DID_ABORT);}
  
    // done
    Serial1.write(GOT_TRIGGER);
    break;

  // enable signals
  case GATE_BLUE1: // gate blue 1
    digitalWriteFast(PIN_BLUE_1, HIGH);
    gateClocker = millis();
    gateTrigger = true;
    Serial1.write(GOT_TRIGGER);
    break;

  case GATE_CYAN1: // gate cyan 1
    digitalWriteFast(PIN_CYAN_1, HIGH);
    gateClocker = millis();
    gateTrigger = true;
    Serial1.write(GOT_TRIGGER);
    break;

  case GATE_RED1: // gate red 1
    digitalWriteFast(PIN_RED_1, HIGH);
    gateClocker = millis();
    gateTrigger = true;
    Serial1.write(GOT_TRIGGER);
    break;

  case GATE_BLUE2: // gate blue 2
    digitalWriteFast(PIN_BLUE_2, HIGH);
    gateClocker = millis();
    gateTrigger = true;
    Serial1.write(GOT_TRIGGER);
    break;

  case GATE_CYAN2: // gate cyan 2
    digitalWriteFast(PIN_CYAN_2, HIGH);
    gateClocker = millis();
    gateTrigger = true;
    Serial1.write(GOT_TRIGGER);
    break;

  case GATE_RED2: // gate red 2
    digitalWriteFast(PIN_RED_2, HIGH);
    gateClocker = millis();
    gateTrigger = true;
    Serial1.write(GOT_TRIGGER);
    break;

  case GATE_BLUE_BOTH: // gate blue both
    digitalWriteFast(PIN_BLUE_1, HIGH);
    digitalWriteFast(PIN_BLUE_2, HIGH);
    gateClocker = millis();
    gateTrigger = true;
    Serial1.write(GOT_TRIGGER);
    break;

  case GATE_CYAN_BOTH: // gate cyan both
    digitalWriteFast(PIN_CYAN_1, HIGH);
    digitalWriteFast(PIN_CYAN_2, HIGH);
    gateClocker = millis();
    gateTrigger = true;
    Serial1.write(GOT_TRIGGER);
    break;

  case GATE_RED_BOTH: // gate red both
    digitalWriteFast(PIN_RED_1, HIGH);
    digitalWriteFast(PIN_RED_2, HIGH);
    gateClocker = millis();
    gateTrigger = true;
    Serial1.write(GOT_TRIGGER);
    break;

  // disable signals
  case STOP_BLUE1: // stop blue 1
    digitalWriteFast(PIN_BLUE_1, LOW);
    Serial1.write(GOT_TRIGGER);
    break;

  case STOP_CYAN1: // stop cyan 1
    digitalWriteFast(PIN_CYAN_1, LOW);
    Serial1.write(GOT_TRIGGER);
    break;

  case STOP_RED1: // stop red 1
    digitalWriteFast(PIN_RED_1, LOW);
    Serial1.write(GOT_TRIGGER);
    break;

  case STOP_BLUE2: // stop blue 2
    digitalWriteFast(PIN_BLUE_2, LOW);
    Serial1.write(GOT_TRIGGER);
    break;

  case STOP_CYAN2: // stop cyan 2
    digitalWriteFast(PIN_CYAN_2, LOW);
    Serial1.write(GOT_TRIGGER);
    break;

  case STOP_RED2: // stop red 2
    digitalWriteFast(PIN_RED_2, LOW);
    Serial1.write(GOT_TRIGGER);
    break;

  case STOP_BLUE_BOTH: // stop blue both
    digitalWriteFast(PIN_BLUE_1, LOW);
    digitalWriteFast(PIN_BLUE_2, LOW);
    Serial1.write(GOT_TRIGGER);
    break;

  case STOP_CYAN_BOTH: // stop cyan both
    digitalWriteFast(PIN_CYAN_1, LOW);
    digitalWriteFast(PIN_CYAN_2, LOW);
    Serial1.write(GOT_TRIGGER);
    break;

  case STOP_RED_BOTH: // stop red both
    digitalWriteFast(PIN_RED_1, LOW);
    digitalWriteFast(PIN_RED_2, LOW);
    Serial1.write(GOT_TRIGGER);
    break;

  } 
}

// interrupts
void EnableChange_1() {
  if (digitalReadFast(PIN_ENABLE_1)) {
    digitalWriteFast(enable_1, HIGH);
  }
  else {
      digitalWriteFast(enable_1, LOW);
  }
}

void EnableChange_2() {
  if (digitalReadFast(PIN_ENABLE_2)) {
    digitalWriteFast(enable_2, HIGH);
  }
  else {
      digitalWriteFast(enable_2, LOW);
  }
}


void ValveChange() {
  if (digitalReadFast(PIN_VALVE_IN)) {
    if (valveByte == 1 || valveByte == 3){
      digitalWriteFast(PIN_VALVE_OUT_1, HIGH);
    }
    if (valveByte == 2 || valveByte == 3){
      digitalWriteFast(PIN_VALVE_OUT_2, HIGH);
    }
  }
  else {
      digitalWriteFast(PIN_VALVE_OUT_1, LOW);
      digitalWriteFast(PIN_VALVE_OUT_2, LOW);
  }
}


void returnModuleInfo() {
  Serial1COM.writeByte(65); // Acknowledge
  Serial1COM.writeUint32(FirmwareVersion); // 4-byte firmware version
  Serial1COM.writeByte(sizeof(moduleName) - 1); // Length of module name
  Serial1COM.writeCharArray(moduleName, sizeof(moduleName) - 1); // Module name
  Serial1COM.writeByte(0); // 1 if more info follows, 0 if not
}


float readSerialChar(byte currentRead) {
  float currentVar = 0;
  byte cBytes[currentRead - 1]; // current byte
  int preDot = currentRead; // indicates how many characters there are before a dot
  int cnt = 0; // character counter

  if (currentRead == 1) {
    currentVar = Serial1COM.readByte() - '0';
  }

  else {
    for (int i = 0; i < currentRead; i++) {
      cBytes[i] = Serial1COM.readByte(); // go through all characters and check for dot or non-numeric characters
      if (cBytes[i] == '.') {
        cBytes[i] = '0';
        preDot = i;
      }
      if (cBytes[i] < '0') {
        cBytes[i] = '0';
      }
      if (cBytes[i] > '9') {
        cBytes[i] = '9';
      }
    }

    // go through all characters to create new number
    if (currentRead > 1) {
      for (int i = preDot - 1; i >= 1; i--) {
        currentVar = currentVar + ((cBytes[cnt] - '0') * pow(10, i));
        cnt++;
      }
    }
    currentVar = currentVar + (cBytes[cnt] - '0');
    cnt++;

    // add numbers after the dot
    if (preDot != currentRead) {
      for (int i = 0; i < (currentRead - preDot); i++) {
        currentVar = currentVar + ((cBytes[cnt] - '0') / pow(10, i));
        cnt++;
      }
    }
  }
  return currentVar;
}
