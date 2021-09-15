// Code to control a single bar matrix displays for behavioral stimulation.
// Generates a sequence of digital output signals to generate sweeping visual motion. Alternatively, the whole panel is triggered.
// Inputs are digital sequences of 0.1ms duration per pulse. Each sequence should consist of up to 5bits (0.5ms in toal).
// A single high or any unknown sequence deactivates the panel.
// A 1-0-1 signal will trigger the sequence mode where a limited number of LEDs are active. Subsequent signals, move the sequence accross the panel.
// A 1-0-1-0-1 signal will switch on the whole panel
// Made to run on Teensy 3.2
//////////////////////////////////////////////////////////////////////////////////////////////////

// define digital lines
#define IN_STIM 23 // trigger for motion sequence
#define IN_BLUE1 22 // trigger1 for ambient blue light
#define IN_BLUE2 21 // trigger2 for ambient blue light
#define OUT_BLUE 20 // output for ambient blue light

// stim variables
int lightCount = 20; // number of used LEDs for a single display (default is 20).
int barWidth = 1; // width of moving bar in LEDs
int barSpace = 4; // space between two bars in LEDs (barWidth + barSpace should be a divider of lightCount-1)
float outOffset = 0; // offset for output channels. This is the first channel that will be used for display control. The last is at outOffset + lightCount - 1.
unsigned int sigDur = 500; // duration of stim signal on 'IN_STIM' pin. Default is 500us.

// internal variables
bool newStim = true; // flag if a trigger should be read
bool switchStim = true; // flag if waiting for low signal
bool dispOn = false; // flag to indicate if display is on.
int stimInd = 0; // index for display sequence
int counter = 0; // temporary variable to count triggers.
int temp = 0; // temporary variable.
unsigned int maxOnTime = 3000; // maximum ontime without another trigger to keep curren pattern alive. Default is 1000ms.
unsigned long clocker = micros(); // timer to measure trigger signal duration

// blue light variables
unsigned int blueDur = 500; // duration of blue ambient light output after receiving a trigger. Default is 500ms.
bool blueOn = false; // flag if blue light is on
unsigned long blueClocker = millis(); // timer to measure blue light output duration
int blueThresh = 200; // threshold for analog signal to trigger blue light output
int blueCheck[2] = {0, 0};
bool serialTrigger = false;

//////////////////////////////////////////////////////////////////////////////////////////////////
int offset = 0;

void setup() {
  // set input lines
  pinMode(IN_STIM, INPUT);
  pinMode(IN_BLUE1, INPUT); // left stim lane
  pinMode(IN_BLUE2, INPUT); // right stim lane
  pinMode(OUT_BLUE, OUTPUT);

  // set up output lines
  for (int i = 0; i < lightCount; ++i) {
    pinMode(i + outOffset, OUTPUT); // output pins for LED control
  }

  for (int i = 0; i < lightCount; ++i) {
    digitalWriteFast(outOffset + i, HIGH);
    delayMicroseconds(50000);
    digitalWriteFast(outOffset + i, LOW);

  }
  // for debugging
  Serial.begin(9600);
  
}


//////////////////////////////////////////////////////////////////////////////////////////////////

void loop() { // check stim trigger and control display
  for (int i = 0; i < lightCount; ++i) {
    digitalWriteFast(outOffset + i, HIGH);
    delayMicroseconds(50000);
    digitalWriteFast(outOffset + i, LOW);

  }
 
 if (serialTrigger == true) {
 int offsetCount = 0;
    for (int i = 0; i < lightCount; ++i) {
        digitalWriteFast((i+offset)%lightCount, HIGH);
  }
  delayMicroseconds(1000000);
    for (int i = 0; i < lightCount; ++i) {
        digitalWriteFast((i+offset)%lightCount, LOW);
  }
  delayMicroseconds(1000000);

 }
  if (digitalReadFast(IN_STIM) == HIGH) {  // new trigger. read signal and set state.
    Serial.println("Counting");
    switchStim = false;
    counter = 1;
    clocker = micros();

    while ((micros() - clocker) <= sigDur) { // read trigger signal for 'sigDur'. Summed up trigger events define display mode.
      if (digitalReadFast(IN_STIM) == LOW) {
        switchStim = true;
      }
      else {
        if (switchStim) {
          ++counter; // increase counter
          switchStim = false; //wait for next low before increasing counter again
        }
      }
    }
  }

  else {
    counter = 0; // reset trigger counter
  }
  if (counter>1) {
    Serial.println("count");
    Serial.println(counter);
    
  }
  if (counter == 1 || counter > 2 || ((micros() - clocker) > maxOnTime * 1000)) { // unknown trigger or stop signal. reset display if currently in motion.
    clocker = micros();
    stimInd = outOffset; // reset sequence index

    for (int i = 0; i < lightCount; ++i) {
      digitalWriteFast(outOffset + i, LOW);
    }
  }

  if (counter == 2) { // sequence mode. move bars in display.
    for (int i = 0; i < lightCount; ++i) {

      temp = stimInd + i;
      if (temp >= outOffset + lightCount)  {
        temp = temp % lightCount;
      }

      if ((i % (barWidth + barSpace)) >= barWidth) { // same as rem(i,barWidth+barSpace) >= barWidth
        digitalWriteFast(temp, LOW);
      }
      else {
        digitalWriteFast(temp, HIGH);
      }
    }

    clocker = micros();
    ++ stimInd;
  }
  if (counter == 3) { // sequence mode. move bars in display.
    Serial.println("Playing the sequence");
    
  int offsetCount = 0;
  while ((digitalReadFast(IN_STIM) == LOW) || (serialTrigger)) {
    for (int i = 0; i < lightCount; ++i) {
      if (  i%3 == 0){
        digitalWriteFast((i+offset)%lightCount, HIGH);
      }
      else {
        digitalWriteFast((i+offset)%lightCount, LOW);
      }
    }
//    if (offsetCount%2000 == 0) {
//      ++offset;
//    }
//    ++offsetCount;
  }
  ++offset;
    for (int i = 0; i < lightCount; ++i) {
         digitalWriteFast(i, LOW);
             Serial.println("Turning off");
             Serial.println(offsetCount);
             Serial.println(offset);

    }
    clocker = micros();
    ++ stimInd;
  }

  // this part is about producing an output for ambient light. Reset clocker on trigger and make sure output is on.
  blueCheck[0] = analogRead(IN_BLUE1);
  blueCheck[1] = analogRead(IN_BLUE2);

  if (((blueCheck[0] + blueCheck[1]) >  blueThresh)) {
    blueClocker = millis();
    digitalWriteFast(OUT_BLUE, HIGH);

    if (!blueOn) {
      digitalWriteFast(OUT_BLUE, HIGH);
      blueOn = true;
    }
  }
  if (blueOn) {
    if ((millis() - blueClocker) > blueDur) {
      digitalWriteFast(OUT_BLUE, LOW);
      blueOn = false;
    }
  }
}
void serialEvent() {
  while (Serial.available()) {
    // get the new byte:
    char inChar = Serial.read();
  }
      serialTrigger = !serialTrigger;
      if (serialTrigger)
      Serial.println("Software triggered.");
}
