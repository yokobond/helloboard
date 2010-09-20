package
{
    import org.flixel.*;
    public class ScratchCat extends FlxSprite
    {
    [Embed(source='scratchcat-as.gif')] private var ImgCat:Class;

	 public function ScratchCat():void
	  {
		super(25, 40, ImgCat);
	  }

	  override public function update():void
	  {
	  }

  public function rotate(howMuch:Number = 1):void {
	
  }

}
}