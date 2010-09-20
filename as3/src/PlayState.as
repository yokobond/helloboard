package
{
import org.flixel.*;

public class PlayState extends FlxState
{
  private var _slide: FlxText = new FlxText(20,10,100,"Test");
  private var _sound: FlxText = new FlxText(20,20,100,"Test");
  private var _light: FlxText = new FlxText(20,30,100,"Test");
  private var _button: FlxText = new FlxText(20,40,100,"Test");
  private var _resistanceA: FlxText = new FlxText(20,50,100,"Test");
  private var _resistanceB: FlxText = new FlxText(20,60,100,"Test");
  private var _resistanceC: FlxText = new FlxText(20,70,100,"Test");
  private var _resistanceD: FlxText = new FlxText(20,80,100,"Test");

  private var _h: ScratchBoard = new ScratchBoard();
  private var scratchcat: ScratchCat;

  override public function create():void
  {
	addScratchBoardWatcher();
	scratchcat = new ScratchCat();
	add(scratchcat);
	super.create();
  }

  override public function update():void
  {
	updateScratchBoardWatcher();
	scratchcat.x = _h.readSlide()/4;
	scratchcat.rotate(15);
	scratchcat.alpha = _h.readLight()/1023.0 * 50;
	if (_h.readButton()) {
	  scratchcat.scale = new FlxPoint(1.0,1.0);
	} else {
	  scratchcat.scale = new FlxPoint(0.5,0.5);
	}
	super.update();
  }


  private function addScratchBoardWatcher():void
  {
	//	add(new FlxText(0,0,100,"Hello, World!")); //adds a 100x20 text field at position 0,0 (upper left)
	add(_slide);
	add(_sound);
	add(_light);
	add(_button);
	add(_resistanceA);
	add(_resistanceB);
	add(_resistanceC);
	add(_resistanceD);
  }

  private function updateScratchBoardWatcher():void 
  {
	_slide.text = "Slide: " + String(_h.readSlide());
	_sound.text = "Sound: " + String(_h.readSound());
	_light.text = "Light: " + String(_h.readLight());
	_button.text = "Button: " + String(_h.readButton());

	_resistanceA.text = "A: " + String(_h.readResistanceA());
	_resistanceB.text = "B: " + String(_h.readResistanceB());
	_resistanceC.text = "C: " + String(_h.readResistanceC());
	_resistanceD.text = "D: " + String(_h.readResistanceD());

  }
}
}