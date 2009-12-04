import cc.piny.*;
import processing.serial.*;

ScratchBoard scratchBoard;
ScratchBoard helloBoard;

PFont font, font2;

void setup()
{
  size(600, 450, P3D);
  println(ScratchBoard.list());
  helloBoard = new ScratchBoard(this, ScratchBoard.list()[1]);  
  scratchBoard = new ScratchBoard(this, ScratchBoard.list()[2]);
  font = loadFont("SeoulHangangM-32.vlw");
  font2 = loadFont("SeoulHangangL-24.vlw");  
  textFont(font, 32);
}

void draw()
{
  int val2;
  boolean button;
  textFont(font, 32); 
  background(200);             // Set background to white
  text ("   elloBoard", 15, 40);   
  fill(0, 102, 153);  
  textFont(font, 37);   
  text ("H", 15, 40);     
  fill(255, 255, 255);    
  textFont(font2, 25);  
  val2 = helloBoard.readSound();  
  text(" - Sound: "+str(val2), 15 , 40*2 );
  val2 = helloBoard.readLight();  
  text(" - Light: "+str(val2), 15 , 40*3 );  
  button = helloBoard.readButton();  
  text(" - Button: "+str(button), 15 , 40*4 );
  val2 = helloBoard.readSlide();  
  text(" - Slide: "+str(val2), 15 , 40*5 );  
  val2 = helloBoard.readResistanceA();  
  text(" - RegistanceA: "+str(val2), 15 , 40*6 );  
  val2 = helloBoard.readResistanceB();
  text(" - RegistanceB: "+str(val2), 15 , 40*7 );  
  val2 = helloBoard.readResistanceC();
  text(" - RegistanceC: "+str(val2), 15 , 40*8 );  
  val2 = helloBoard.readResistanceD();
  text(" - RegistanceD: "+str(val2), 15 , 40*9 );  

  textFont(font, 32);  
  text ("  cratch Board", 300, 40);   
  fill(216, 255, 3);  
  textFont(font, 37);   
  text ("S", 300, 40);     
  fill(255, 255, 255);      
  textFont(font2, 25);  
  val2 = scratchBoard.readSound();  
  text(" - Sound: "+str(val2), 300 , 40*2 );
  val2 = scratchBoard.readLight();  
  text(" - Light: "+str(val2), 300 , 40*3 );  
  button = scratchBoard.readButton();  
  text(" - Button: "+str(button), 300 , 40*4 );
  val2 = scratchBoard.readSlide();  
  text(" - Slide: "+str(val2), 300 , 40*5 );  
  val2 = scratchBoard.readResistanceA();  
  text(" - RegistanceA: "+str(val2), 300 , 40*6 );  
  val2 = scratchBoard.readResistanceB();
  text(" - RegistanceB: "+str(val2), 300 , 40*7 );  
  val2 = scratchBoard.readResistanceC();
  text(" - RegistanceC: "+str(val2), 300 , 40*8 );  
  val2 = scratchBoard.readResistanceD();
  text(" - RegistanceD: "+str(val2), 300 , 40*9 );  
  
  PImage b;
  b = loadImage("piny_logo_s.png");
  image(b, 480,380);
}


