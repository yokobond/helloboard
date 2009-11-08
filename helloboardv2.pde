/*
 HelloBoardV2 

 Created 30 October. 2009
 by PINY and Song Hojun.

 TODO
  * Calulate Polling Time. 30 millis seconds.
  * Calibrate Mic, CdS values and constain values.
  * Check CdS value graph and Light Sensor from Scratchboard value graph.
  * Smooting values
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
const int maxNumReadings = 15;

int smoothingValues[sensorChannels][maxNumReadings];
int smoothingIndex[sensorChannels];
int smoothingTotal[sensorChannels];

void setup() {
     Serial.begin(38400);
     setupSmoothing();
}

void setupSmoothing() {
     for(int i =0; i< sensorChannels; i++) {
       for(int j =0 ; j< maxNumReadings ; j++) {
         smoothingValues[i][j]=0;
       }
     smoothingTotal[i]=0;
     smoothingIndex[i]=0;
     }
}

void loop() {

    if( Serial.available() > 0) {
      incomingByte = Serial.read();
#ifndef DEBUG
      if (incomingByte == 0x01) {
#else
      if (incomingByte == 'a') {
       lastIncommingMicroSec = micros();
 //      Serial.println("lastIncommingMicroSec");
   //    Serial.println("Got Incoming Byte!");
       
       //Serial.println(IncomingByte, DEC); 
#endif
        readSensors();
#ifdef DEBUG          
        //Serial.println(lightValue);
        Serial.println(micros() -lastIncommingMicroSec);
#endif

#ifndef DEBUG

        sendFirstSecondBytes(15, 0x04);
        sendFirstSecondBytes(0, resistanceDValue);  
        sendFirstSecondBytes(1, resistanceCValue);
        sendFirstSecondBytes(2, resistanceBValue);
        sendFirstSecondBytes(3, buttonValue);
        sendFirstSecondBytes(4, resistanceAValue);
        sendFirstSecondBytes(5, lightValue);
        sendFirstSecondBytes(6, soundValue);
        sendFirstSecondBytes(7, sliderValue);
#endif

      }
      
   }
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
  //for( int i =0 ; i < 50; i++) {
  light = analogRead(LightSensor);
  light = calibrateLightSensor(light);
  light = smoothingValue(LightSensor,light, 13);
  //}
  return light;
}

int calibrateLightSensor(int light) {
  if (light <= 512 ) {light= (int(round((26/512)*light)));}
  else {light = int(round((1023-26)/511.0*light)-972);}
  light = constrain(light, 0, 1023);
  return light;
  /*
  if (light < 50) {return (100 - light);}
  else { light = int(round((1023-light) * ((100-50)/998.0)));}
  return ( light);
  */
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
    return int(round(smoothingTotal[channel] / numReadings));
}

int readSound() {
  int sound;
  sound = analogRead(SoundSensor);
  sound = smoothingValue(SoundSensor,sound, 10);
  return sound;
  sound = max(0, sound - 18);
  if (sound < 50) { return int(sound/2); }
  // noise ceiling
  return int(25 + min( 75, round((sound - 50) * (75.0/580.0))));
/*  return analogRead(0); */ 
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
