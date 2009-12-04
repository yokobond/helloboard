/*
 HelloBoardV2 

 Created 30 October. 2009
 by PINY and Song Hojun.

 TODO
  * Calulate Polling Time. 30 millis seconds.
  * Calibrate Mic, CdS values and constain values.
  * Check CdS value graph and Light Sensor from Scratchboard value graph.
  * Smoothing values
  * Test resistance ABCD 
  * Why my computer can't work with Helloboard. To make troubleshoot FAQ.
  * Why soundValue changed, when I touch Helloboard.
  * Check smoothing speed. Slider do not need smoothing.
  
*/

//#define DEBUG 1

// Sensor <--> Analog port mapping
#define SoundSensor 0
#define LightSensor 1
#define Slider 2
#define ResistanceA 3
#define ResistanceB 4
#define ResistanceC 5
#define ResistanceD 6
#define Button 7

int sliderValue = 0;
int lightValue = 0;
int soundValue = 0;
int buttonValue = 0;
int resistanceAValue = 0;
int resistanceBValue = 0;
int resistanceCValue = 0;
int resistanceDValue = 0;

unsigned long lastIncommingMicroSec = 0;

uint8_t incomingByte;

const int sensorChannels = 8;
const int maxNumReadings = 30;

int smoothingValues[sensorChannels][maxNumReadings];
int smoothingIndex[sensorChannels];
int smoothingTotal[sensorChannels];

void setup() {
     setupSmoothing();  
     Serial.begin(38400);
}

void setupSmoothing() {
     for(int i = 0; i < sensorChannels; i++) {
       for(int j = 0 ; j < maxNumReadings ; j++) {
         smoothingValues[i][j]=0;
       }
     smoothingTotal[i]=0;
     smoothingIndex[i]=0;
     }
}

void loop() {

#ifdef DEBUG  
  if( Serial.available() > 0) {
    incomingByte = Serial.read();

    if (incomingByte == 'a') {
         lastIncommingMicroSec = micros();
#endif
        readSensors();
 
#ifdef DEBUG          
          Serial.println(micros() -lastIncommingMicroSec);
      }
  }
#endif

       
#ifndef DEBUG
    if( Serial.available() > 0) {
      incomingByte = Serial.read();
      // readSensors(); // readSensors x 7
//          readSensors();      
      if (incomingByte == 0x01) {
        sendFirstSecondBytes(15, 0x04);
        sendFirstSecondBytes(0, resistanceDValue);  
        sendFirstSecondBytes(1, resistanceCValue);
        sendFirstSecondBytes(2, resistanceBValue);
        sendFirstSecondBytes(3, buttonValue);
        sendFirstSecondBytes(4, resistanceAValue);
        sendFirstSecondBytes(5, lightValue);
        sendFirstSecondBytes(6, soundValue);
        sendFirstSecondBytes(7, sliderValue);
      }  
   }        
#endif

}

void readSensors() {
    sliderValue = readSlider();
    lightValue = readLight();
    soundValue = readSound();
    buttonValue = readButton();
    
    resistanceAValue = readResistance(ResistanceA);
    resistanceBValue = readResistance(ResistanceB);
    resistanceCValue = readResistance(ResistanceC);
    resistanceDValue = readResistance(ResistanceD);
}

int readButton() {
  return analogRead(Button);
}

int readResistance(int adc) {
  int value;
  value = analogRead(adc);
  value = smoothingValue(adc, value, 5);
  if (value ==1022) value = 1023;
  return value;
}

int readSlider() {
  int sliderValue;
  sliderValue = analogRead(Slider);
  sliderValue = smoothingValue(Slider, sliderValue, 3);
  return sliderValue;
}

int readLight() {
  int light;
  light = analogRead(LightSensor);
  light = calibrateLightSensor(light);
  light = smoothingValue(LightSensor,light, 25);
  return light;
}

int calibrateLightSensor(int light) {
  // mid y value = 40
  // mid x value = 540
  // y axis value = 1069

/*
  if (light <= 540 ) {light= (int(round((40.0/540.0)*light)));}
  else {light = int(round((1023-40)/(1023-540)*light)-1069);}
  light = constrain(light, 0, 1023);
  return light;
  
  */
  
  // s-curve
    int mid = 600;
    int mid2 = 900;
    if ( light < mid) {
        light = int(round((40.0/mid)*light));
    } else if (light < mid2) {
        light = int(round((mid2-40)/(mid2-float(mid))* light) - 1680);
    }
    light = constrain(light, 0, 1023);    
    return light;
}

int smoothingValue(int channel, int value, int numReadings) {
    int total;
    int index = smoothingIndex[channel];
    total = smoothingTotal[channel] - smoothingValues[channel][index];
    smoothingValues[channel][index] = value;
    smoothingTotal[channel] = total + value;
    smoothingIndex[channel]++;
    if(smoothingIndex[channel] >=numReadings) {
      smoothingIndex[channel]=0;
    }
    return int(round(smoothingTotal[channel] / (numReadings)));
}

int readSound() {
  int sound;
  sound = analogRead(SoundSensor);
  sound = smoothingValue(SoundSensor,sound, 25);
  // noise ceiling 
  if (sound < 70) {
    sound = max(0, sound - 70);
    return sound;
  }
  if (sound < 90) { return int(sound /2); }
  return sound;
}

void sendFirstSecondBytes(int channel, int value) {
      int firstByte;
      int secondByte;
      int highValue = value;
      int lowValue = value;
      firstByte = 1 << 7;
      channel = channel << 3;
      highValue = highValue >> 7;
      firstByte |= channel;
      firstByte |= highValue;

      Serial.print(firstByte, BYTE);  
      lowValue &= 0b01111111;
      secondByte = lowValue;
      Serial.print(secondByte, BYTE);
}

