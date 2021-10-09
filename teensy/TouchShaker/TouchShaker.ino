
#include "Arduino.h"
#include "ArCOM.h"

#define HANDLE_MOTOR_BOTTOM 1
#ifdef HANDLES_MOTOR_BOTTOM
#define LOW_DIR_H HIGH
#define HIGH_DIR_H LOW
#else
#define LOW_DIR_H LOW
#define HIGH_DIR_H HIGH
#endif

#define SPOUT_MOTOR_BOTTOM 1
#ifdef SPOUT_MOTOR_BOTTOM
#define LOW_DIR_S HIGH
#define HIGH_DIR_S LOW
#else
#define LOW_DIR_S LOW
#define HIGH_DIR_S HIGH
#endif


//#define USE_LOAD_CELL 1
#ifdef USE_LOAD_CELL
#include "HX711.h" //This load-cell library can be obtained here http://librarymanager/All#Avia_HX711
#endif
// –--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--
// This version includes:
// control two stepper motors to move the sputes
// control two stepper motors to move levers
// reads water spout and lever touches using capacitive sensing.
// serial communication with bpod v2 state machine
// –--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--–--

// Serial-write variables
unsigned long FirmwareVersion = 2;
char moduleName[] = "TouchShaker"; // Name of module for manual override UI and state machine assembler
ArCOM Serial1COM(Serial1); // UART serial port

unsigned long clocker = millis();
unsigned long stimClocker = millis();
unsigned long trialClocker = millis();
int FSMheader = 0;
const int sRateLicks = 5;  // This is the minimum duration of lick events that are send to bpod.
const int sRateLever = 10; // This is the number of ms for outputs to be during levertouch. Signal remains live until 'sRateLever' ms after the last contact.

/* #################################################
  ############## PIN CONFIGURATION ###################
  #################################################### */
// TTL Outputs
#define PIN_STIMTRIG 21 // stimulus trigger that can be switched by serial command 'MAKE_STIMTRIGGER'
#define PIN_TRIALTRIG 4 // trial-start trigger that can be switched by serial command 'MAKE_TRIALTRIGGER'
#define PIN_CAMTIMER 3 // Trigger to synchronize camera acquisition. Sends TTL for 'camTrigDur' with an inter-pulse of 'camTrigRate'.

#ifdef USE_LOAD_CELL
// load cell pins
#define LOADCELL_SCK_PIN  19
#define LOADCELL_DOUT_PIN  20
HX711 scale;
#endif
// Inputs for lick sensors
#define LEVERSENSOR_L 15 // touch line for lever touch
#define LEVERSENSOR_R 16 // touch line for lever touch
#define SPOUTSENSOR_L 22 // touch line for left spout
#define SPOUTSENSOR_R 23 // touch line for right spout
// Pins for stepper - spouts
#define PIN_SPOUTOUT_L 5
#define PIN_SPOUTOUT_R 6
#define PIN_SPOUTSTEP_L 13
#define PIN_SPOUTDIR_L 14
#define PIN_SPOUTSTEP_R 17
#define PIN_SPOUTDIR_R 18
// Pins for stepper - handles
#define PIN_LEVEROUT_L 7
#define PIN_LEVEROUT_R 8
#define PIN_LEVERSTEP_L 9
#define PIN_LEVERDIR_L 10
#define PIN_LEVERSTEP_R 11
#define PIN_LEVERDIR_R 12

/* #################################################
  ########### UART/BPOD COMMUNICATION ################
  #################################################### */
// Byte codes for serial communication
// inputs
#define MODULE_INFO 255 // byte to return module info
#define HWRESET 128
#define START_TRIAL 70 // identifier to start trial, provides limit for wheel motion and servo movement
#define ADJUST_SPOUTES 71 // identifier to change spout positions
#define ADJUST_LEVER 72 // identifier to change lever positions
#define ADJUST_SPOUTSPEED 73 // identifier to change spout servo speed
#define ADJUST_LEVERSPEED 74 // identifier to change lever servo speed
#define ADJUST_TOUCHLEVEL 75 // identifier to re-adjust threshold for touch sensors. Will sample over 1 second of data to infer mean/std of measurements.
#define CHECK_LEVERS 76 // identifier to provide information over which handles are being touched
#define MAKE_STIMTRIGGER 77 // identifier to produce a stimulus trigger
#define MAKE_TRIALTRIGGER 78 // identifier to produce a trial onset trigger
#define INCREASE_SPOUTTHRESH_L 80 // identifier to increase touch threshold for the left spout
#define DECREASE_SPOUTTHRESH_L 81 // identifier to decrease touch threshold for the left spout
#define INCREASE_SPOUTTHRESH_R 82 // identifier to increase touch threshold for the right spout
#define DECREASE_SPOUTTHRESH_R 83 // identifier to decrease touch threshold for the right spout
#define INCREASE_LEVERTHRESH_L 84 // identifier to increase touch threshold for the left LEVER
#define DECREASE_LEVERTHRESH_L 85 // identifier to decrease touch threshold for the left LEVER
#define INCREASE_LEVERTHRESH_R 86 // identifier to increase touch threshold for the right LEVER
#define DECREASE_LEVERTHRESH_R 87 // identifier to decrease touch threshold for the right LEVER
#define SET_TOUCHLEVELS 89
#define GET_TOUCHLEVELS 95 // send the touch thresholds to bpod
#define IS_MOVING 88

#define START_SCALE 91 // identifier to start logging data from the load cell
#define STOP_SCALE 92 // identifier to stop logging data from the load cell
#define SEND_DATA_SCALE 93 // identifier to return data from load cell recording
// outputs
#define LEFT_SPOUT_TOUCH 1 // byte to indicate left spout is being touched
#define RIGHT_SPOUT_TOUCH 2 // byte to indicate right spout is being touched
#define LEFT_SPOUT_RELEASE 3 // byte to indicate left spout was released
#define RIGHT_SPOUT_RELEASE 4 // byte to indicate left spout was released
#define LEFT_HANDLE_TOUCH 5 // byte to indicate left handle is being touched
#define RIGHT_HANDLE_TOUCH 6 // byte to indicate that right handle is being touched
#define BOTH_HANDLES_TOUCH 7 // byte to indicate that both handles are being touched
#define LEFT_HANDLE_RELEASE 8 // byte to indicate left handle was released
#define RIGHT_HANDLE_RELEASE 9 // byte to indicate that right handle was released
#define OK 14 // positive handshake for bpod commands
#define FAIL 15 // negative handshake for bpod commands

// other serial commands during the trial
#define SPOUTS_IN 101 // serial command to move the spouts in
#define SPOUTS_OUT 106 // serial command to move the spouts out
#define LEFT_SPOUT_OUT 102 // serial command to move the left spout out
#define RIGHT_SPOUT_OUT 103 // serial command to move the right spout out
#define LEVER_IN 104 // serial command to move the lever in
#define LEVER_OUT 105 // serial command to move the lever out

/* #################################################
  ##################### VARIABLES ####################
  #################################################### */
// Servo vars
float lServoIn = 10; // position to be reached when spouts are moved in by bpod trigger.
float lServoOut = 0;  // position to be reached when spouts are moved outin by bpod trigger.
float lServoAdjust = 0; // position that is taken when matlab changes spout position via the ADJUST_SPOUTS event.
float lServoCurrent = 0; // current servo position - tracks where the servo currently is.
float rServoIn = 10; // position to be reached when spouts are moved in by bpod trigger.
float rServoOut = 0;  // position to be reached when spouts are moved out by bpod trigger.
float rServoAdjust = 0; // position that is taken when matlab changes spout position via the ADJUST_SPOUTS event.
float rServoCurrent = 0; // current servo position - tracks where the servo currently is.
float leverIn = 10; // inner lever position.
float leverOut = 0; // outer lever position.
float leverAdjust = 0; // lever position via adjust_lever commands.
float leverCurrent = 0; // current lever position

float spoutSpeed = 50000; // duration of the spout movement in us.
float leverSpeed = 50000; // duration of the lever movement in us. this is the time it takes the lever to move from the outer to the inner position or vice versa.
unsigned long lSpoutClocker = micros(); // timer to modulate speed of left spout
unsigned long rSpoutClocker = micros(); // timer to modulate speed of right spout
unsigned long lClocker = micros(); // timer to modulate speed of lever motion
unsigned long touchClocker_L = millis(); // timer to measure duration of lever touch
unsigned long touchClocker_R = millis(); // timer to measure duration of lever touch
int lSpoutInc = 1000; // incremental left spout motion to modulate speed
int rSpoutInc = 1000; // incremental right spout motion to modulate speed
int leverInc = 1000; // time between steps of the handle motor to move at requested speed
int touchChangeInc = 2; // step size when increasing/decreasing touch thresholds

// flags for current servo states. Required to control servo speed
bool stimTrigger = false; // flag to indicate that stim trigger is produced
bool trialTrigger = false; // flag to indicate that trial trigger is produced
bool spoutMoves = false; // flag to indicate that spouts are in motion
bool lSpoutMovesIn = false; // flag to indicate that spout is moving to inward position
bool lSpoutMovesOut = true; // flag to indicate that spout is moving to outward position
bool lSpoutMovesAdjust = false; // flag to indicate that spout is moving to outward position
bool rSpoutMovesIn = false; // flag to indicate that spout is moving to inward position
bool rSpoutMovesOut = true; // flag to indicate that spout is moving to outward position
bool rSpoutMovesAdjust = false; // flag to indicate that spout is moving to outward position
bool leverMoves = false; // flag to indicate that lever is in motion
bool lMovesIn = false; // flag to indicate that lever is moving to inward position
bool lMovesOut = true; // flag to indicate that lever is moving to outward position
bool lMovesAdjust = false; // flag to indicate that lever is moving to outward position
unsigned long spoutClocker_L = millis(); // timer to measure duration of left lick
unsigned long spoutClocker_R = millis(); // timer to measure duration of right lick

// Touch variables
int touchAdjustDur = 2000; // time used to re-adjust touch levels if neccessary. This will infer the mean (in the first hald) and standard deviation (in the second half) of the read-noise to infer decent thresholds for touch.
int touchThresh = 3; // threshold for touch event in standard deviation units.
int touchThreshOffset = 50; // additional offset for touch threshold.
bool touchAdjust = true; // flag to determine values to detect touches. Do this on startup.
float touchData[4]; // current values for the four touch lines (left spout, right spout, left, handle, right handle)
float meanTouchVals[4]; // mean values for the four touch lines (left spout, right spout, left, handle, right handle)
float stdTouchVals[4]; // stand deviation values for the four touch lines (left spout, right spout, left, handle, right handle)
float touchVal = 0; // temporary variable for usb communication
long int sampleCnt[] = {0, 0}; // counter for samples during touch adjustment
unsigned long adjustClocker = millis(); // timer for re-adjustment of touch lines

// Other variables
bool midRead = false;
bool spoutTouch_L = false; // flag to indicate that left spout is touched
bool spoutTouch_R = false; // flag to indicate that right spout is touched
bool leverTouch_L = false; // flag to indicate that left lever is touched
bool leverTouch_R = false; // flag to indicate that right lever is touched
bool leverTouch_BOTH = false; // flag to indicate that both levers are touched
bool findSpoutOut[2] = {true, true}; // flag that stepper motors are being moved out.
bool findLeverOut[2] = {true, true}; // flag that stepper motors are being moved out.
int stepPulse = 10; // duration of stepper pulse in microseconds
int stimDur = 5; // duration of stimulus trigger in ms
int trialDur = 50; // duration of trial trigger in ms
float temp[10]; // temporary variable for general purposes
int camTrigRate = 90; // rate of camera trigger in Hz.

#ifdef USE_LOAD_CELL
unsigned long scaleClocker = millis(); // timer for load-cell measurements
bool readScale = false; // flag to collect data from load-cell
int scaleRate = 10; // duration between samples from load-cell in ms (default is 10ms).
unsigned long scaleCnt = 0; //counter to fill readings into scaleVals
#define SCALE_READS 100 // maximum samples from load-cell per trial. Default duration for readout at 100Hz is 1 minute. decrease from 60000 for memory
long scaleVals[SCALE_READS]; //array for scale readings.
bool scaleWrap = false; // flag that scale reacording was above maximum. In this case, the full scaleVals array and the current scaleCnt is sent to Bpod.
int weight_val = 0;
#endif

unsigned long usbClocker = millis();
int usbRate = 5;
/* #################################################
  ##################### CAMERA TRIGGER ###############
  #################################################### */
// volatile long cameraFramesCounter = 0;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void setup() {
  // put your setup code here, to run once:
  Serial1.begin(1312500); //baud rate for UART bpod serial communication
  Serial.begin(9600); // USB baud rate
  //Serial.println("Started spatial sparrow");

#ifdef USE_LOAD_CELL
  scale.begin(LOADCELL_DOUT_PIN, LOADCELL_SCK_PIN); // communication with load cell amp
#endif
  //digitalWrite(LOADCELL_SCK_PIN, HIGH);
  // Set servo pins to output mode
  pinMode(PIN_SPOUTSTEP_L, OUTPUT);
  pinMode(PIN_SPOUTSTEP_R, OUTPUT);
  pinMode(PIN_SPOUTDIR_L, OUTPUT);
  pinMode(PIN_SPOUTDIR_R, OUTPUT);

  pinMode(PIN_LEVERSTEP_L, OUTPUT);
  pinMode(PIN_LEVERSTEP_R, OUTPUT);
  pinMode(PIN_LEVERDIR_L, OUTPUT);
  pinMode(PIN_LEVERDIR_R, OUTPUT);

  // Set pin modes for digital output lines
  pinMode(PIN_STIMTRIG, OUTPUT);
  pinMode(PIN_TRIALTRIG, OUTPUT);

  //pinMode(PIN_CAMTIMER, OUTPUT);
  //analogWriteFrequency(PIN_CAMTIMER, camTrigRate);
  //analogWrite(PIN_CAMTIMER, 128); // set to 50% duty cycle

  // Set pin modes for input lines and stepper range
  pinMode(PIN_SPOUTOUT_L, INPUT_PULLUP);
  pinMode(PIN_SPOUTOUT_R, INPUT_PULLUP);
  pinMode(PIN_LEVEROUT_L, INPUT_PULLUP);
  pinMode(PIN_LEVEROUT_R, INPUT_PULLUP);
  touchData[0] = touchRead(SPOUTSENSOR_L);
  touchData[1] = touchRead(SPOUTSENSOR_R);
  touchData[2] = touchRead(LEVERSENSOR_L);
  touchData[3] = touchRead(LEVERSENSOR_R);
}

void serialEvent1() {
  FSMheader = Serial1COM.readByte();
  switch (FSMheader) {
    case HWRESET:
    _reboot_Teensyduino_();
      break;
    case MODULE_INFO: // return module information to bpod
        returnModuleInfo();
        break;
    case START_TRIAL:
      if (Serial1.available() > 6) {
        for (int i = 0; i < 6; i++)  // get number of characters for each variable (6 in total)
          temp[i] = Serial1COM.readByte(); // number of characters for current variable
      }
      else {
        Serial1.write(FAIL);
        break;
      }
      lServoIn = readSerialChar(temp[0]); // left spout inner position
      rServoIn = readSerialChar(temp[1]); // right spout inner position
      lServoOut = readSerialChar(temp[2]); // left spout outer position
      rServoOut = readSerialChar(temp[3]); // right spout outer position
      leverIn = readSerialChar(temp[4]); // inner handle position
      leverOut = readSerialChar(temp[5]); // outer handle position
      lSpoutInc = round(spoutSpeed / abs(lServoIn)); // time between steps to move at requested left spout speed.
      rSpoutInc = round(spoutSpeed / abs(rServoIn)); // time between steps to move at requested right spout speed.
      leverInc = round(leverSpeed / abs(leverIn)); // time between steps to move at requested leverspeed.
      Serial1.write(OK);
      break;
    case ADJUST_SPOUTES:
      if (Serial1.available() > 1) {
        spoutMoves = true;
        lServoAdjust = readSerialChar(Serial1COM.readByte()); // requested handle position
        lSpoutClocker = micros() - lSpoutInc; // initialize timer for spout movement
        lSpoutMovesIn = false; lSpoutMovesOut = false; lSpoutMovesAdjust = true;  // flag that left spout moves to adjusted position

        if (lServoAdjust == 0 && lServoCurrent != 0) // move handles to zero position (absolute outer limits)
          findSpoutOut[0] = true; // find outer limit for left stepper

        rServoAdjust = readSerialChar(Serial1COM.readByte()); // requested handle position
        rSpoutClocker = micros() - rSpoutInc; // initialize timer for spout movement
        rSpoutMovesIn = false; rSpoutMovesOut = false; rSpoutMovesAdjust = true;  // flag that right spout moves to adjusted position

        if (rServoAdjust == 0 && rServoCurrent != 0) // move handles to zero position (absolute outer limits)
          findSpoutOut[1] = true; // find outer limit for right stepper
        Serial1.write(OK);
      }
      else {
        Serial1.write(FAIL);
      }
      break;
    case ADJUST_LEVER:
      if (Serial1.available() > 1) {
        leverAdjust = readSerialChar(Serial1COM.readByte()); // requested handle position
        lClocker = micros() - leverInc; // initialize timer for lever movement
        leverMoves = true;
        lMovesIn = false; lMovesOut = false; lMovesAdjust = true; // flag that lever moves to adjusted position

        if (leverAdjust == 0) { // move handles to zero position (absolute outer limits)
          findLeverOut[0] = true; // find outer limit for left stepper
          findLeverOut[1] = true; // find outer limit for right stepper
        }
        Serial1.write(OK); // send confirmation
        midRead = 0;
      }
      else {
        Serial1.write(FAIL);
      }
      break;
    case ADJUST_SPOUTSPEED:
      if (Serial1.available() > 1) {
        spoutSpeed = readSerialChar(Serial1COM.readByte()); // Duration of spout movement from outer to inner position in ms.
        spoutSpeed = spoutSpeed * 1000;
        lSpoutInc = round(spoutSpeed / abs(lServoIn)); // time between steps to move at requested left spout speed.
        rSpoutInc = round(spoutSpeed / abs(rServoIn)); // time between steps to move at requested right spout speed.

        Serial1.write(OK); // send confirmation
      }
      else {
        Serial1.write(FAIL);
      }
    case ADJUST_LEVERSPEED:
      if (Serial1.available() > 1) {
        leverSpeed = readSerialChar(Serial1COM.readByte()); // Duration of spout movement from outer to inner position in ms.
        leverSpeed = leverSpeed * 1000;
        leverInc = round(leverSpeed / abs(leverIn)); // time between steps to move at requested leverspeed.
        Serial1.write(OK); // send confirmation
      }
      else {
        Serial1.write(FAIL);
      }
      break;
    case GET_TOUCHLEVELS:
      Serial1.write(GET_TOUCHLEVELS); // send header
      for (int i=0;i<4;i++) {
        Serial1.print(stdTouchVals[i]);
        Serial1.print("_");
      }
      Serial1.write(OK);
      break;
    case SET_TOUCHLEVELS:
       if (Serial1.available() > 4) {
          for (int i = 0; i < 4; i++)
            temp[i] = Serial1COM.readByte(); 
          for (int i = 0; i < 4; i++)
            stdTouchVals[i] = readSerialChar(temp[i]);
          Serial1.write(OK);
        } else {
          Serial1.write(FAIL);
        }
      break;
    case ADJUST_TOUCHLEVEL:
      if (Serial1.available() > 1) {
        touchThresh = readSerialChar(Serial1COM.readByte()); // new threshold for touch detection in SDUs
        touchAdjust = true; // flag to adjust touchlevels
        adjustClocker = millis();
        sampleCnt[0] = 0; sampleCnt[1] = 0; // reset counter
        meanTouchVals[0] = 0; meanTouchVals[1] = 0; meanTouchVals[2] = 0; meanTouchVals[3] = 0; // reset mean values
        stdTouchVals[0] = 0; stdTouchVals[1] = 0; stdTouchVals[2] = 0; stdTouchVals[3] = 0; // reset std values
        Serial1.write(OK); // send confirmation
      }
      else {
        Serial1.write(FAIL);
      }
      break;
    case SPOUTS_IN:
      spoutMoves = true;
      if (lServoIn == 0) { // move left spout to zero position (absolute outer limits)
        findSpoutOut[0] = true; // find outer limit for left stepper
      }
      if (rServoIn == 0) { // move left spout to zero position (absolute outer limits)
        findSpoutOut[1] = true; // find outer limit for right stepper
      }

      lSpoutClocker = micros() - lSpoutInc; // initialize timer for spout movement
      lSpoutMovesIn = true; lSpoutMovesOut = false; lSpoutMovesAdjust = false;  // flag that left spout moves to inner position

      rSpoutClocker = micros() - rSpoutInc; // initialize timer for spout movement
      rSpoutMovesIn = true; rSpoutMovesOut = false; rSpoutMovesAdjust = false;  // flag that left spout moves to inner position

      Serial1.write(OK);
      break;
    case SPOUTS_OUT:
      spoutMoves = true;
      if (lServoOut == 0) { // move left spout to zero position (absolute outer limits)
        findSpoutOut[0] = true; // find outer limit for left stepper
      }
      if (rServoOut == 0) { // move left spout to zero position (absolute outer limits)
        findSpoutOut[1] = true; // find outer limit for right stepper
      }

      lSpoutClocker = micros() - lSpoutInc; // initialize timer for spout movement
      lSpoutMovesIn = false; lSpoutMovesOut = true; lSpoutMovesAdjust = false;  // flag that left spout moves to inner position

      rSpoutClocker = micros() - rSpoutInc; // initialize timer for spout movement
      rSpoutMovesIn = false; rSpoutMovesOut = true; rSpoutMovesAdjust = false;  // flag that left spout moves to inner position

      Serial1.write(OK);
      break;
    case LEFT_SPOUT_OUT:
      spoutMoves = true;
      if (lServoOut == 0) { // move left spout to zero position (absolute outer limits)
        findSpoutOut[0] = true; // find outer limit for left stepper
      }
      lSpoutClocker = micros() - lSpoutInc; // initialize timer for spout movement
      lSpoutMovesIn = false; lSpoutMovesOut = true; lSpoutMovesAdjust = false;  // flag that left spout moves to outer position
//      rSpoutMovesIn = false; rSpoutMovesOut = false; rSpoutMovesAdjust = false;  // flag that left spout moves to outer position
      Serial1.write(OK);
      break;
    case RIGHT_SPOUT_OUT:
      spoutMoves = true;
      if (rServoOut == 0) { // move left spout to zero position (absolute outer limits)
        findSpoutOut[1] = true; // find outer limit for right stepper
      }
      rSpoutClocker = micros() - rSpoutInc; // initialize timer for spout movement
      rSpoutMovesIn = false; rSpoutMovesOut = true; rSpoutMovesAdjust = false;  // flag that right spout moves to outer position
//      lSpoutMovesIn = false; lSpoutMovesOut = false; lSpoutMovesAdjust = false;  // flag that left spout moves to outer position
      
      Serial1.write(OK);
      break;
    case LEVER_IN:
      leverMoves = true;
      if (leverIn == 0) {
        findLeverOut[0] = true; // find outer limit for left stepper
        findLeverOut[1] = true; // find outer limit for right stepper
      }
      leverInc = round(leverSpeed / abs(leverIn)); // time between steps to move at requested leverspeed.
      lClocker = micros() - leverInc;
      lMovesIn = true; lMovesOut = false; lMovesAdjust = false; // flag that lever moves inward

      Serial1.write(OK);
      break;
    case LEVER_OUT:
        if (lMovesOut == false) { //
          leverMoves = true;
          if (leverOut == 0) {
            findLeverOut[0] = true; // find outer limit for left stepper
            findLeverOut[1] = true; // find outer limit for right stepper
          }
          leverInc = round(leverSpeed / abs(leverIn)); // time between steps to move at requested leverspeed.
          lClocker = micros() - leverInc;
          lMovesIn = false; lMovesOut = true; lMovesAdjust = false; // flag that lever moves outward
        }
      Serial1.write(OK);
      break;
    case CHECK_LEVERS: // return lever touch information if requested by bpod
        if (leverTouch_L && !leverTouch_R) {
          Serial1.write(LEFT_HANDLE_TOUCH);
        }
        else if (!leverTouch_L && leverTouch_R) {
          Serial1.write(RIGHT_HANDLE_TOUCH);
        }
        else if (leverTouch_BOTH) {
          Serial1.write(BOTH_HANDLES_TOUCH);
        }
      break;
    case MAKE_STIMTRIGGER: // stimulus trigger
        stimTrigger = true;
        stimClocker = millis();
        digitalWriteFast(PIN_STIMTRIG, HIGH); // set stimulus trigger to high

        Serial1.write(OK);
        break;
    case MAKE_TRIALTRIGGER:
        trialTrigger = true;
        trialClocker = millis();
        digitalWriteFast(PIN_TRIALTRIG, HIGH); // set trial trigger to high
        Serial1.write(OK);
        break;
    case INCREASE_SPOUTTHRESH_L: // increase threshold
        stdTouchVals[0] = stdTouchVals[0] + touchChangeInc;
        Serial1.write(OK);
        break;
    case DECREASE_SPOUTTHRESH_L: // decrease threshold
        stdTouchVals[0] = stdTouchVals[0] - touchChangeInc;
        Serial1.write(OK);
        break;
    case INCREASE_SPOUTTHRESH_R:        
        stdTouchVals[1] = stdTouchVals[1] + touchChangeInc;
        Serial1.write(OK);
        break;
    case DECREASE_SPOUTTHRESH_R: // decrease threshold
        stdTouchVals[1] = stdTouchVals[1] - touchChangeInc;
        Serial1.write(OK);
        break;
    case INCREASE_LEVERTHRESH_L: // increase threshold
        stdTouchVals[2] = stdTouchVals[2] + touchChangeInc;
        Serial1.write(OK);
        break;
    case DECREASE_LEVERTHRESH_L:
        stdTouchVals[2] = stdTouchVals[2] - touchChangeInc;
        Serial1.write(OK);
        break;
    case INCREASE_LEVERTHRESH_R: // increase threshold
        stdTouchVals[3] = stdTouchVals[3] + touchChangeInc;
        Serial1.write(OK);
        break;
    case DECREASE_LEVERTHRESH_R:
        stdTouchVals[3] = stdTouchVals[3] - touchChangeInc;
        Serial1.write(OK);
        break;
#ifdef USE_LOAD_CELL
      case START_SCALE:// byte for scale recording
          scaleCnt = 0;
          scaleWrap = false;
          scaleClocker = millis();
          readScale = true;
          Serial1.write(OK);
          break;
      case STOP_SCALE:
          readScale = false;
          Serial.write(OK);
          break;
      case SEND_DATA_SCALE:
          Serial1COM.writeUint32(scaleCnt); // send current array index
          if (scaleWrap) {
            Serial1COM.writeInt32Array(scaleVals, SCALE_READS); // write full array
          }
          else {
            Serial1COM.writeInt32Array(scaleVals, scaleCnt); // write partial array
          }
        Serial1.write(OK);
        break;
#endif
    case IS_MOVING:
        if (spoutMoves || leverMoves) {
          Serial1.write(FAIL);
        }
        else {
          Serial1.write(OK);
        }
        break;
    default:
        Serial1.write(FAIL);
  }
}

void loop() {
  // This is the main loop for the teensy
  ///////////////////////////////////////////////////////////////////////////////////////
  // make stim trigger
  if (stimTrigger) {
    if ((millis() - stimClocker) > stimDur) {  // done with stim trigger
      digitalWriteFast(PIN_STIMTRIG, LOW); // set stimulus trigger to low
      stimTrigger = false;
    }
  }

  // make trial trigger
  if (trialTrigger) {
    if ((millis() - trialClocker) > trialDur) {  // done with trial trigger
      digitalWriteFast(PIN_TRIALTRIG, LOW); // set trial trigger to low
      trialTrigger = false;
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // get data from touch pins
  touchData[0] = (touchData[0] * 15 + touchRead(SPOUTSENSOR_L)) / 16;
  touchData[1] = (touchData[1] * 15 + touchRead(SPOUTSENSOR_R)) / 16;
  touchData[2] = (touchData[2] * 15 + touchRead(LEVERSENSOR_L)) / 16;
  touchData[3] = (touchData[3] * 15 + touchRead(LEVERSENSOR_R)) / 16;

  // recompute estimates for mean and standard deviation in each touch line and updates thresholds accordingly
  if (touchAdjust) {
    ++sampleCnt[0];
    for (int i = 0; i < 4; i++) {
      meanTouchVals[i] = meanTouchVals[i] + ((touchData[i] - meanTouchVals[i]) / sampleCnt[0]); // update mean
    }
    if ((millis() - adjustClocker) > (touchAdjustDur / 2)) { // second part of adjustment: get summed variance
      ++sampleCnt[1];
      for (int i = 0; i < 4; i++) {
        stdTouchVals[i] = stdTouchVals[i] + sq(touchData[i] - meanTouchVals[i]); // update standard deviation (summed variance here)
      }
    }
    if ((millis() - adjustClocker) > touchAdjustDur) {  // done with adjustment
      for (int i = 0; i < 4; i++) {
        stdTouchVals[i] = sqrt(stdTouchVals[i] / sampleCnt[1]) + touchThreshOffset; // compute standard deviation from summed variance
      }
      touchAdjust = false;
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////////
  // check touch lines and create according output
  if (!touchAdjust & !spoutMoves & !leverMoves) {
    if (touchData[0] > (meanTouchVals[0] + (stdTouchVals[0]*touchThresh))) { // signal above 'stdTouchVals' standard deviations indicate lick event. only when spouts dont move.
      spoutClocker_L = millis(); //update time when spout was last touched
      if (!spoutTouch_L) {
        Serial1.write(LEFT_SPOUT_TOUCH); // send a byte to bpod if this is an onset event
      }
      spoutTouch_L = true;
    }
    else {
      if ((millis() - spoutClocker_L) >= sRateLicks) { // check when lever was last touched and set output to low if it happened too long ago.
        if (spoutTouch_L) {
          Serial1.write(LEFT_SPOUT_RELEASE); // send a byte to bpod if this is an offset event
        }
        spoutTouch_L = false;
      }
    }


    if (touchData[1] > (meanTouchVals[1] + (stdTouchVals[1]*touchThresh))) { // signal above 'stdTouchVals' standard deviations indicate lick event. only when spouts dont move.
      spoutClocker_R = millis(); //update time when spout was last touched
      if (!spoutTouch_R) {
        Serial1.write(RIGHT_SPOUT_TOUCH); // send a byte to bpod if this is an onset event
      }
      spoutTouch_R = true;
    }
    else {
      if ((millis() - spoutClocker_R) >= sRateLicks) { // check when lever was last touched and set output to low if it happened too long ago.
        if (spoutTouch_R) {
          Serial1.write(RIGHT_SPOUT_RELEASE); // send a byte to bpod if this is an offset event
        }
        spoutTouch_R = false;
      }
    }


    if (touchData[2] > (meanTouchVals[2] + (stdTouchVals[2]*touchThresh))) { // signal above 200mv from lick circuit and not receiving serial data
      touchClocker_L = millis(); //update time when lever was last touched
      if (!leverTouch_L) {
        Serial1.write(LEFT_HANDLE_TOUCH); // send a byte to bpod if this is an onset event
      }
      leverTouch_L = true;
    }
    else {
      if ((millis() - touchClocker_L) >= sRateLever) { // check when lever was last touched and set output to low if it happened too long ago.
        if (leverTouch_L) {
          Serial1.write(LEFT_HANDLE_RELEASE); // send a byte to bpod if this is an offset event
        }
        leverTouch_L = false;
      }
    }

    if (touchData[3] > (meanTouchVals[3] + (stdTouchVals[3]*touchThresh))) { // signal above 200mv from lick circuit and not receiving serial data
      touchClocker_R = millis(); //update time when lever was last touched
      if (!leverTouch_R) {
        Serial1.write(RIGHT_HANDLE_TOUCH); // send a byte to bpod if this is an onset event
      }
      leverTouch_R = true;
    }
    else {
      if ((millis() - touchClocker_R) >= sRateLever) { // check when lever was last touched and set output to low if it happened too long ago.
        if (leverTouch_R) {
          Serial1.write(RIGHT_HANDLE_RELEASE); // send a byte to bpod if this is an offset event
        }
        leverTouch_R = false;
      }
    }

    if (leverTouch_L && leverTouch_R) {
      if (!leverTouch_BOTH) {
        Serial1.write(BOTH_HANDLES_TOUCH); // send a byte to bpod if this is an onset event
      }
      leverTouch_BOTH = true;
    }
    else {
      if (((millis() - touchClocker_L) >= sRateLever) || ((millis() - touchClocker_R) >= sRateLever)) { // check when lever was last touched and set output to low if it happened too long ago.
        leverTouch_BOTH = false;
      }
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////
  // Check for ongoing spout movements
  if (spoutMoves == true) { // check spout motion
    // left spout movements
    if (lSpoutMovesIn || lSpoutMovesOut || lSpoutMovesAdjust) {
      if ((micros() - lSpoutClocker) >= lSpoutInc) { // move left spout motor
        lSpoutClocker = micros();

        // find absolute outer limits, this happens when requestion a movement to position zero
        if (findSpoutOut[0]) { // left spout is moving to zero position
          digitalWriteFast(PIN_SPOUTDIR_L, LOW_DIR_S); // make sure stepper is moving in the right direction
          delayMicroseconds(10); // short delay to ensure direction has changed
          sendStep(PIN_SPOUTSTEP_L, stepPulse); // make a step
          if (!digitalReadFast(PIN_SPOUTOUT_L)) { // check if outer limit has been reached
            findSpoutOut[0] = false;
            lServoCurrent = 0;
          }
        }

        // regular movements, relative to zero position
        if (!findSpoutOut[0]) {

          // left spout moves in
          if (lSpoutMovesIn == true) {
            // target hasnt been reached yet
            if (lServoCurrent != lServoIn) {
              lServoCurrent = moveLeftSpout(lServoCurrent, lServoIn, stepPulse); // move left spout
            }

            // stop motion when target has been reached
            if (lServoCurrent == lServoIn) {
              lSpoutMovesIn = false;
            }
          }

          // left spout adjustment movement
          else if (lSpoutMovesAdjust == true) {

            // target hasnt been reached yet
            if (lServoCurrent != lServoAdjust) {
              lServoCurrent = moveLeftSpout(lServoCurrent, lServoAdjust, stepPulse); // move left spout
            }

            // stop motion when target has been reached
            if (lServoCurrent == lServoAdjust) {
              lSpoutMovesAdjust = false;
            }
          }

          // left spout moves out
          else if (lSpoutMovesOut == true) {
            // target hasnt been reached yet
            if (lServoCurrent != lServoOut) {
              lServoCurrent = moveLeftSpout(lServoCurrent, lServoOut, stepPulse); // move left spout
            }

            // stop motion when target has been reached
            if (lServoCurrent == lServoOut) {
              lSpoutMovesOut = false;
            }
          }
        }
      }
    }


    // right spout movements
    if (rSpoutMovesIn || rSpoutMovesOut || rSpoutMovesAdjust) {
      if ((micros() - rSpoutClocker) >= rSpoutInc) { // move right spout motor
        rSpoutClocker = micros();

        // find absolute outer limits, this happens when requestion a movement to position zero
        if (findSpoutOut[1]) { // right spout is moving to zero position
          digitalWriteFast(PIN_SPOUTDIR_R, HIGH_DIR_S); // make sure stepper is moving in the right direction
          delayMicroseconds(10); // short delay to ensure direction has changed
          sendStep(PIN_SPOUTSTEP_R, stepPulse); // make a step
          if (!digitalReadFast(PIN_SPOUTOUT_R)) { // check if outer limit has been reached
            findSpoutOut[1] = false;
            rServoCurrent = 0;
          }
        }

        // regular movements, relative to zero position
        if (!findSpoutOut[1]) {

          // right spout moves in
          if (rSpoutMovesIn == true) {
            // target hasnt been reached yet
            if (rServoCurrent != rServoIn) {
              rServoCurrent = moveRightSpout(rServoCurrent, rServoIn, stepPulse); // move right spout
            }

            // stop motion when target has been reached
            if (rServoCurrent == rServoIn) {
              rSpoutMovesIn = false;
            }
          }

          // right spout adjustment movement
          else if (rSpoutMovesAdjust == true) {
            // target hasnt been reached yet
            if (rServoCurrent != rServoAdjust) {
              rServoCurrent = moveRightSpout(rServoCurrent, rServoAdjust, stepPulse); // move right spout
            }

            // stop motion when target has been reached
            if (rServoCurrent == rServoAdjust) {
              rSpoutMovesAdjust = false;
            }
          }

          // right spout moves out
          else if (rSpoutMovesOut == true) {
            // target hasnt been reached yet
            if (rServoCurrent != rServoOut) {
              rServoCurrent = moveRightSpout(rServoCurrent, rServoOut, stepPulse); // move right spout
            }

            // stop motion when target has been reached
            if (rServoCurrent == rServoOut) {
              rSpoutMovesOut = false;
            }
          }
        }
      }
    }


    // check if all spout movements are complete
    if (spoutMoves && !lSpoutMovesIn && !lSpoutMovesOut && !lSpoutMovesAdjust && !rSpoutMovesIn && !rSpoutMovesOut && !rSpoutMovesAdjust) {
      spoutMoves = false;
    }
  }

  ////////////////////////////////////////////////////////////////
  // Check for ongoing handle movements
  if (leverMoves == true) { // check lever motion
    if ((micros() - lClocker) >= leverInc) { // move stepper motors
      lClocker = micros();

      // find absolute outer limits, this happens when requestion a movement to position zero
      if (findLeverOut[0]) { // left stepper is moving to zero position
        digitalWriteFast(PIN_LEVERDIR_L, LOW_DIR_H); // make sure stepper is moving in the right direction
        delayMicroseconds(10); // short delay to ensure direction has changed
        sendStep(PIN_LEVERSTEP_L, stepPulse); // make a step
        if (!digitalReadFast(PIN_LEVEROUT_L)) { // check if outer limit has been reached
          findLeverOut[0] = false;
          leverCurrent = 0;
        }
      }

      if (findLeverOut[1]) { // right stepper is moving to zero position
        digitalWriteFast(PIN_LEVERDIR_R, HIGH_DIR_H); // make sure stepper is moving in the right direction
        delayMicroseconds(10); // short delay to ensure direction has changed
        sendStep(PIN_LEVERSTEP_R, stepPulse); // make a step
        if (!digitalReadFast(PIN_LEVEROUT_R)) { // check if outer limit has been reached
          findLeverOut[1] = false;
          leverCurrent = 0;
        }
      }

      // regular movements, relative to zero position
      if (!findLeverOut[0] && !findLeverOut[1]) {
        // handles move in
        if (lMovesIn == true) {

          // target hasnt been reached yet
          if (leverCurrent != leverIn) {
            leverCurrent = moveHandles(leverCurrent, leverIn, stepPulse); // move handles
          }

          // stop motion when target has been reached
          if (leverCurrent == leverIn) {
            leverMoves = false; lMovesIn = false;
          }
        }

        // adjustment movement
        else if (lMovesAdjust == true) {

          // target hasnt been reached yet
          if (leverCurrent != leverAdjust) {
            leverCurrent = moveHandles(leverCurrent, leverAdjust, stepPulse); // move handles
          }

          // stop motion when target has been reached
          if (leverCurrent == leverAdjust) {
            leverMoves = false; lMovesAdjust = false;
          }
        }

        // handles move out
        else if (lMovesOut == true) {

          // target hasnt been reached yet
          if (leverCurrent != leverOut) {
            leverCurrent = moveHandles(leverCurrent, leverOut, stepPulse); // move handles
          }

          // stop motion when target has been reached
          if (leverCurrent == leverOut) {
            leverMoves = false; lMovesOut = false;
          }
        }
      }
    }
  }


#ifdef USE_LOAD_CELL
  ////////////////////////////////////////////////
  /////// check load-cell inputs /////////////////
  if (scale.is_ready() && readScale && ((millis() - scaleClocker) >= scaleRate)) {
    scaleVals[scaleCnt] = scale.read();
    ++scaleCnt;
    if (scaleCnt > SCALE_READS) {
      scaleCnt = 0;
      scaleWrap = true;
    }
  }
#endif
  if (Serial && ((millis() - usbClocker) >= usbRate)) { // (false){
    usbClocker = millis();
    //    long wv_tmp = scale.read();
    ///////////////////////////////////////////////////

    // send touch data for serial monitor
    for (int i = 0; i < 4; i++) { // send some feedback about touch events

      touchVal = touchData[i] + (i * 1500); //((touchData[i] / pow(2,16)) * pow(2,8) + (i*5)); // convert value from 16 to 8 bit number
      Serial.print(int(touchVal)); Serial.print(",");

      touchVal = (meanTouchVals[i] + (stdTouchVals[i] * touchThresh)) + (i * 1500); //(((meanTouchVals[i]+(stdTouchVals[i]*touchThresh))/ pow(2,16)) * pow(2,8) + (i*5)); // convert bound from 16 to 8 bit number
      Serial.print(int(touchVal)); Serial.print(",");
    }
    //    weight_val = ((wv_tmp / pow(2,16)) * pow(2,8) + (4*20)); // convert value from 16 to 8 bit number
    //  weight_val = ((scaleVals[scaleCnt] / pow(2,16)) * pow(2,8) + (4*20)); // convert value from 16 to 8 bit number
    //    Serial.print(byte(weight_val));
    Serial.println();
  }

} // end of void loop


// additional functions
float AdjustServo(float Position, float Target, float Increment) {
  if ((Target - Position) < 0) { // desired is lower as current position
    if ((Position - Increment) <= Target) { // check if target is reached at next incremental change
      Position = Target;
    }
    else {
      Position = Position - Increment; // decrease position until target position is reached
    }
  }

  if ((Target - Position) > 0) { // desired is higher as current position
    if ((Position + Increment) >= Target) { // check if target is reached at next incremental change
      Position = Target;
    }
    else {
      Position = Position + Increment; // increase position until target position is reached
    }
  }
  return Position;
}


void sendStep(int cPin, int pulseTime) { // send stepper pulse as long as control signal is high
  digitalWriteFast(cPin, HIGH); // send step
  delayMicroseconds(pulseTime); // keep step signal high for pulseTime in microseconds. Should be at least 2 or longer.
  digitalWriteFast(cPin, LOW);
}


float moveHandles(float current, float target, int pulseDur) {
  if (current < target) { // levers move towards the animal
    digitalWriteFast(PIN_LEVERDIR_R, LOW_DIR_H); // make sure handle is moving in the right direction
    digitalWriteFast(PIN_LEVERDIR_L, HIGH_DIR_H); // make sure handle is moving in the right direction
  }
  else {  // levers move away from the animal
    digitalWriteFast(PIN_LEVERDIR_R, HIGH_DIR_H); // make sure handle is moving in the right direction
    digitalWriteFast(PIN_LEVERDIR_L, LOW_DIR_H); // make sure handle is moving in the right direction
  }
  delayMicroseconds(10); // short delay to ensure direction has changed
  sendStep(PIN_LEVERSTEP_L, pulseDur); // make a step
  sendStep(PIN_LEVERSTEP_R, pulseDur); // make a step
  current = AdjustServo(current, target, 1); // adjust current servo position

  if (!digitalReadFast(PIN_LEVEROUT_L) && !digitalReadFast(PIN_LEVEROUT_R)) {
    current = 0; // if zero-pins are touched, set current position to zero
  }
  return current;
}

float moveLeftSpout(float current, float target, int pulseDur) {
  if (current < target) { // spout moves towards the animal
    digitalWriteFast(PIN_SPOUTDIR_L, HIGH_DIR_S); // make sure spout is moving in the correct direction
  }
  else {  // spout move away from the animal
    digitalWriteFast(PIN_SPOUTDIR_L, LOW_DIR_S); // make sure spout is moving in the right direction
  }
  delayMicroseconds(10); // short delay to ensure direction has changed
  sendStep(PIN_SPOUTSTEP_L, pulseDur); // make a step
  current = AdjustServo(current, target, 1); // adjust current servo position
  if (!digitalReadFast(PIN_SPOUTOUT_L)) {
    current = 0; // if zero-pin is touched, set current position to zero
  }
  return current;
}

float moveRightSpout(float current, float target, int pulseDur) {
  if (current < target) { // spout moves towards the animal
    digitalWriteFast(PIN_SPOUTDIR_R, LOW_DIR_S); // make sure spout is moving in the correct direction
  }
  else {  // spout move away from the animal
    digitalWriteFast(PIN_SPOUTDIR_R, HIGH_DIR_S); // make sure spout is moving in the correct direction
  }
  delayMicroseconds(10); // short delay to ensure direction has changed
  sendStep(PIN_SPOUTSTEP_R, pulseDur); // make a step

  if (!digitalReadFast(PIN_SPOUTOUT_R)) {
    current = 0; // if zero-pin is touched, set current position to zero

  }
  current = AdjustServo(current, target, 1); // adjust current servo position

  return current;
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
