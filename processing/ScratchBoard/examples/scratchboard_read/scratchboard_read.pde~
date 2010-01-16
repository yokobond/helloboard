import cc.piny.*;
import processing.serial.*;

ScratchBoard scratchBoard;

void setup()
{
  size(535, 535);
  println(ScratchBoard.list());
  scratchBoard = new ScratchBoard(this, ScratchBoard.list()[1]);
}

void draw()
{
  int val2;
  boolean button;
  int sound;
  int slide;
  val2 = scratchBoard.readSound();
  sound = int(map(val2,0,1023,5,50));
  val2 = scratchBoard.readLight();
  slide = int(map(val2,0,1023,5,255)); 
  button = scratchBoard.readButton();
  val2 = scratchBoard.readSlide();
  val2 = scratchBoard.readResistanceA();
  val2 = scratchBoard.readResistanceB();
  val2 = scratchBoard.readResistanceC();
  val2 = scratchBoard.readResistanceD();

  background(255);             // Set background to white
  
  fill(slide, 100, 100);
  for(int i =0 ; i<sound; i++) {
    for (int j =0; j< 50 ; j++) {
      rect(i*10 + 2, j*10 + 2, 6 , 6);
    }
  }
}


