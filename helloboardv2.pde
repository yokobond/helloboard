/*
 HelloBoardV2 

 Created 30 October. 2009
 by PINY and Song Hojun.

 TODO
  * Calibrate Mic, CdS values
  * Test resistance ABCD 
  * ...
*/

#define DEBUG 1

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

int lightS=0;
int x = 0;
unsigned long lastIncommingMills = 0;

uint8_t incomingByte;

void setup() {
     Serial.begin(38400);
}

void loop() {

    
#ifdef DEBUG
/*
    //Serial.println(lightValue);
    //delay(100);
    
    for(int i=0; i<1024; i++) {
      x=analogRead(LightSensor);
      lightS = calibrateLightSensor(x);
//      lightS = calibrateLightSensor(i);
      Serial.print(x);
//      Serial.print(i);
      Serial.print(' ');
      Serial.println(lightS);
    }
    
    */
#endif    

    if( Serial.available() > 0) {
      incomingByte = Serial.read();
      if (incomingByte == 'a') {
      
#ifdef DEBUG        

       lastIncommingMills = micros();
 //      Serial.println("lastIncommingMills");
   //    Serial.println("Got Incoming Byte!");
       
       //Serial.println(IncomingByte, DEC); 
#endif

        readSensors();
        Serial.println(micros() -lastIncommingMills);
        
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
  return analogRead(adc);
}

int readSlider() {
  return analogRead(Slider);
}

int readLight() {
  int light = 0;
  light = analogRead(LightSensor);
//  return light;

  light = calibrateLightSensor(light);
  return light;
}

int calibrateLightSensor(int light) {
  if (light <= 512 ) {return (int(round((26/512)*light)));}
  else {light = int(round((1023-26)/511.0*light)-972);}
  return light;
  /*
  if (light < 50) {return (100 - light);}
  else { light = int(round((1023-light) * ((100-50)/998.0)));}
  return ( light);
  */
}

int readSound() {
  int sound = 0;
  sound = analogRead(SoundSensor);
  return sound;
  sound = max(0, sound - 18);
  if (sound < 50) { return int(sound/2); }
  // noise ceiling
  return int(25 + min( 75, round((sound - 50) * (75.0/580.0))));
/*  return analogRead(0); */
  
}

void sendFirstSecondBytes(int channel, int value) {
      int firstByte = 0;
      int secondByte = 0;
      int highValue = value;
      int lowValue = value;
      firstByte = 1 << 7;
      channel = channel << 3;
      highValue = highValue >> 7;
      firstByte |= channel;
      firstByte |= highValue;

      serialBytePrint(firstByte);    
      lowValue &= 127;
      secondByte = lowValue;
      serialBytePrint(secondByte);
}

void serialBytePrint(int code) {
  Serial.print(code, BYTE);
#ifdef DEBUG        
  Serial.println(code);
#endif
}
