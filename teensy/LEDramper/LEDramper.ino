
#include "Arduino.h"
#include "ArCOM.h"

// –--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--
// Code to use a Teensy 3.6 for analog signal generation with its 2 DAC output pins.
// The code is intended to create a pyramid shapped control signal that is converted from a digital input.
// To create the analog signal correctly, the digital signals are monitored and the mean trigger duration is inferred from a rolling average.
// For this to work correctly, the triggers should not change their duration very often, as it will take time for the Teensy to adjust to a new trigger duration.
// The LED power can be set via serial communication or via a potentiometer on the analog input pins. The power defines the output value at the peak of the pyramid.
// Any point of the pyramid that is larger then 4095 will get clipped (.
//
// –--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--

// Serial-write variables
unsigned long FirmwareVersion = 1;
char moduleName[] = "LEDramper"; // Name of module for manual override UI and state machine assembler
ArCOM SerialCOM(Serial); // serial port

unsigned long clocker = millis(); // timer for serial communication
int FSMheader = 0;
bool midRead = false;
byte temp; // temporary variable to read bytes
bool useRamp = false; // flag to produce light ramps. If this is false, the Teensy will produce a modulated square wave.

/* #################################################
  ############## PIN CONFIGURATION ###################
  #################################################### */
// Analog outputs
#define LED_OUT1 A21 // analog output for LED1 (blue)
#define LED_OUT2 A22 // analog output for LED2 (violet)

// Analog inputs
#define LED_MOD1 A14 // analog input to modulate LED1 (blue)
#define LED_MOD2 A15 // analog input to modulate LED2 (violet)

// TTL inputs for LEDs
#define LED_TRIGGER1 25 // trigger for LED1
#define LED_TRIGGER2 24 // trigger for LED2


/* #################################################
  ########### Serial COMMUNICATION ################
  #################################################### */
// Byte codes for serial communication
// inputs
#define MODULE_INFO 255 // byte to return module info
#define CHANGE_LED1 10 // identifier to change intensity for LED 1
#define CHANGE_LED2 11 // identifier to change intensity for LED 2

// outputs
#define DID_ABORT 15 // identifier for unknown header etc


/* #################################################
  ##################### VARIABLES ####################
  #################################################### */

// variables to measure duration of trigger signals
unsigned long trigClocker1 = micros(); // timer used to measure duration of first trigger signal
unsigned long trigClocker2 = micros(); // timer used to measure duration of second trigger signal
long trigTime1 = 5000; // variable to measure duration of input triggers in us
long trigTime2 = 5000; // variable to measure duration of input triggers in us
long trigLength1 = 5000; // average measured length of the trigger1 in us
long trigLength2 = 5000; // average measured length of the trigger2 in us
float sampleWeight = 10; // weight of each duration measure for the average. Larger numbers reduce the impact of new measures on the average.
bool trig1 = false; // flag for LED 1 trigger
bool trig2 = false; // flag for LED 2 trigger
int trigShift = 1000; // the Thorlabs T-Cube driver introduces a 1ms phase shift. Correct this by ending the control pyramid 1ms earlier.

// variables to generate analog output
int powerLED1 = 0; // current power of LED 1
int powerLED2 = 0; // current power of LED 2
int out1 = 0; // courrent output on DAC1 - max is 4095
int out2 = 0; // courrent output on DAC2 - max is 4095
bool driveLED1 = false; // flag to produce analog signal for LED 1
bool driveLED2 = false; // flag to produce analog signal for LED 2

// variables to read analog inuput
int currentRead1 = 0; // current read from analog input 1
float lastRead1 = 0; // last read from analog input 1
int currentRead2 = 0; // current read from analog input 2
int lastRead2 = 0; // last read from analog input 2
int inputDiff = 40; // minimum absolute difference between current and last read to trigger 'inputLive' and reset 'inputLiveDur'
int inputLiveDur = 5000; // duration for which analog inputs are considered in milliseconds.
bool inputLive = true; // flag to enable analog inputs. Only occurs if there was a larger change in the analog input and remains live for 'inputLiveDur' milliseconds.
unsigned long inputClocker = millis(); // timer to check when the last larger input change occured.

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600); // USB baud rate

  // Set pin modes for digital inpput lines
  pinMode(LED_TRIGGER1, INPUT);
  pinMode(LED_TRIGGER2, INPUT);

  // Set pin modes for analog inpput lines
  pinMode(LED_MOD1, INPUT_PULLDOWN);
  pinMode(LED_MOD2, INPUT_PULLDOWN);

  // Set bit depth
  analogWriteResolution(12); // make sure to use full range of DAC output
  analogReadResolution(12); // set ADC input to same resolution as the output
  analogReadAveraging(4); // this should help to avoid that analog inputs vary due to noise
}

void loop() {
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // This is the serial communication
  if (Serial.available() > 0) {
    if (!midRead) {
      FSMheader = SerialCOM.readByte();
      midRead = 1; // flag for current reading of serial information
      clocker = millis(); // counter to make sure that all serial information arrives within a reasonable time frame (currently 100ms)
    }

    if (FSMheader == CHANGE_LED1) {
      temp = SerialCOM.readByte(); // number of characters for current variable
      if (Serial.available() >= temp) { // if enough bytes are sent for all characters to be read
        // read all variables for current trial
        powerLED1 = round(readSerialChar(temp)); // current power level
        writeCurrentVals(); // report current values
        midRead = 0;

        while (Serial.available() > 0) {
          SerialCOM.readByte();
        }
      }

      else if ((millis() - clocker) >= 100) {
        midRead = 0; SerialCOM.writeByte(DID_ABORT);
      }
    }

    else if (FSMheader == CHANGE_LED2) {
      temp = SerialCOM.readByte(); // number of characters for current variable
      if (Serial.available() >= temp) { // if enough bytes are sent for all characters to be read
        // read all variables for current trial
        powerLED2 = round(readSerialChar(temp)); // current power level
        writeCurrentVals(); // report current values
        midRead = 0;
        
        while (Serial.available() > 0) {
          SerialCOM.readByte();
        }
      }

      else if ((millis() - clocker) >= 100) {
        midRead = 0; SerialCOM.writeByte(DID_ABORT);
      }
    }

    else if (FSMheader == MODULE_INFO) { // return module information
      returnModuleInfo();
      midRead = 0;
    }

    else {
      midRead = 0; SerialCOM.writeByte(DID_ABORT);
    }
  }


  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // check input triggers and determine stimulus duration and LED outputs
  // LED 1
  trig1 = digitalReadFast(LED_TRIGGER1);
  if (trig1) { // produce output for LED 1
    driveLED1 = true;
    trigTime1 = (micros() - trigClocker1); // duration of trigger1 so far
    if (useRamp){
      out1 = makePyramidSignal(trigTime1, trigLength1, powerLED1); // get output signal based on current time, expected total time and LED amplitude
      }
    else{
      out1 = powerLED1;
      }
    analogWrite(LED_OUT1, out1);
  }

  else {
    if (driveLED1) { // LED is still on. Switch off and update estimate of trigger duration.
      analogWrite(LED_OUT1, 0);
      driveLED1 = false;

      if (trigTime1 > 1000) { // measured trigger time needs to be at least 1ms. Otherwise its probably noise.
        trigLength1 = trigLength1 + (((trigTime1 - trigShift) - trigLength1) / sampleWeight); // update average of trigger length
        trigTime1 = 0;
      }

      // check analog modulation signal
      currentRead1 = analogRead(LED_MOD1);
      if (abs(currentRead1 - powerLED1) > inputDiff) {
        inputLive = true;
        inputClocker = millis();
      }
      else if ((millis() - inputClocker) > inputLiveDur){
        inputLive = false;
      }
        
      if (inputLive) {
        powerLED1 = currentRead1;
        writeCurrentVals(); // report current values
      }
    }

    else { // not much going on here. keep timer updated
      trigClocker1 = micros();
    }
  }

  // LED 2
  trig2 = digitalReadFast(LED_TRIGGER2);
  if (trig2) { // produce output for LED 2
    driveLED2 = true;
    trigTime2 = (micros() - trigClocker2); // duration of trigger2 so far
    if (useRamp){
      out2 = makePyramidSignal(trigTime2, trigLength2, powerLED2); // get output signal based on current time, expected total time and LED amplitude
    }
    else{
      out2 = powerLED2;
      }
    analogWrite(LED_OUT2, out2);
  }

  else {
    if (driveLED2) { // LED is still on. Switch off and update estimate of trigger duration.
      analogWrite(LED_OUT2, 0);
      driveLED2 = false;

      if (trigTime2 > 1000) { // measured trigger time needs to be at least 1ms. Otherwise its probably noise.
        trigLength2 = trigLength2 + (((trigTime2 - trigShift) - trigLength2) / sampleWeight); // update average of trigger length
        trigTime2 = 0;
      }

      // check analog modulation signal
      currentRead2 = analogRead(LED_MOD2);
      if (abs(currentRead2 - powerLED2) > inputDiff) {
        inputLive = true;
        inputClocker = millis();
      }
      else if ((millis() - inputClocker) > inputLiveDur){
        inputLive = false;
      }
        
      if (inputLive) {
        powerLED2 = currentRead2;
        writeCurrentVals(); // report current values
      }
    }

    else { // not much going on here. keep timer updated
      trigClocker2 = micros();
    }
  }
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// additional functions


void returnModuleInfo() {
  SerialCOM.writeByte(65); // Acknowledge
  SerialCOM.writeUint32(FirmwareVersion); // 4-byte firmware version
  SerialCOM.writeByte(sizeof(moduleName) - 1); // Length of module name
  SerialCOM.writeCharArray(moduleName, sizeof(moduleName) - 1); // Module name
  SerialCOM.writeByte(0); // 1 if more info follows, 0 if not
}


void writeCurrentVals() {
 SerialCOM.writeByte(50);
 Serial.print(",");
 // Serial.print(trigLength1);
 // Serial.print(",");
  Serial.print(powerLED1);
  Serial.print(",");
//  Serial.print(trigLength2);
 // Serial.print(",");
  Serial.println(powerLED2);
}


int makePyramidSignal(unsigned long cTime, unsigned long avgTime, int power) {

  if (cTime < avgTime / 2) { // ramp up in the first half of the stimulus. power defines the peak of the pyramid
    cTime = cTime * 10000; // this is to increase precision during integer division
    cTime = cTime / (avgTime / 2); // assess where we are in the stimulus window. 100% = 10000 here where power hits the peak
  }

  else if (cTime < avgTime){ // ramp down in the second half of the stimulus
    cTime = cTime * 10000; // this is to increase precision during integer division
    cTime = 20000 - (cTime / (avgTime / 2)); // assess where we are in the stimulus window. 0% = 10000 here where power hits the peak and 20000 is the end
  }

  else {
    cTime = 0;
  }

  power = (power * cTime) / 10000; // current power
  if (power < 0) {
    power = 0;
  }
  if (power > 4095) {
    power = 4095;
  }

  return power;
}


float readSerialChar(byte currentRead) {
  float currentVar = 0;
  byte cBytes[currentRead - 1]; // current byte
  int preDot = currentRead; // indicates how many characters there are before a dot
  int cnt = 0; // character counter

  if (currentRead == 1) {
    currentVar = SerialCOM.readByte() - '0';
  }

  else {
    for (int i = 0; i < currentRead; i++) {
      cBytes[i] = SerialCOM.readByte(); // go through all characters and check for dot or non-numeric characters
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
