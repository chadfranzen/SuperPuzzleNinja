package
{
	import org.flixel.*;
	
	public class MenuState extends FlxState
	{
		[Embed(source = "data/PressStart2P.ttf", fontFamily="PIXEL", embedAsCFF="false")] public var fontPixel:String;
		[Embed(source = "data/04B_03__.TTF", fontFamily="TINY", embedAsCFF="false")] public var fontTiny:String;
		[Embed(source = "data/titleScreen.png")] public var titleScreenPng:Class;
		[Embed(source = "data/arrow.png")] public var arrowPng:Class;
		[Embed(source = "data/reverseArrow.png")] public var reverseArrowPng:Class;
		[Embed(source = "data/beep.mp3")] public var beepSound:Class;
		
		public var titleScreen:FlxSprite;
		public var arrow:FlxSprite;
		public var reverseArrow:FlxSprite;
		public var title:FlxText;
		public var instructions:FlxText;
		
		/**
		 * The text in the bottom right saying if the sound is on or not 
		 */		
		public static var soundText:FlxText;
		
		public var arrowPos1:FlxPoint = new FlxPoint(120, FlxG.height - 46);
		public var arrowPos2:FlxPoint = new FlxPoint(89, FlxG.height - 30);
		public var reverseArrowPos1:FlxPoint = new FlxPoint(163, FlxG.height - 46);
		public var reverseArrowPos2:FlxPoint = new FlxPoint(195, FlxG.height - 30);
		
		public var selection:uint;
		
		override public function create():void
		{
			FlxG.play(beepSound);
			
			selection = 0;
			
			titleScreen= new FlxSprite(0, 0, titleScreenPng);
			add(titleScreen);

			title = new FlxText(0, 48, FlxG.width, "Super Puzzle\nNinja");
			title.setFormat("PIXEL", 16, 0xFFFFFFFF, "center", 0xff333333);
			add(title);
			
			arrow = new FlxSprite(arrowPos1.x, arrowPos1.y, arrowPng);
			add(arrow);
			
			reverseArrow = new FlxSprite(reverseArrowPos1.x, reverseArrowPos1.y, reverseArrowPng);
			add(reverseArrow);

			instructions = new FlxText(0, FlxG.height - 48, FlxG.width, "Play\n\nInstructions");
			instructions.setFormat ("PIXEL", 8, 0xFFFFFFFF, "center", 0xff333333);
			add(instructions);
			
			soundText = new FlxText(0, FlxG.height - 10, FlxG.width, "(S)ound: On");
			soundText.setFormat("TINY", 8, 0xffffffff, "right");
			if (FlxG.mute) soundText.text = "(S)ound: Off";
			add(soundText);
		} // end function create
		
		
		override public function update():void
		{
			super.update(); // calls update on everything you added to the game loop
			
			if (FlxG.keys.justPressed("SPACE") || FlxG.keys.justPressed("X") || FlxG.keys.justPressed("ENTER"))
			{
				if (selection == 0)
					FlxG.switchState(new PlayState());
				else if (selection == 1)
					FlxG.switchState(new InstructionsPageOne());
			}
			if (FlxG.keys.justPressed("UP") || FlxG.keys.justPressed("DOWN"))
			{
				if (selection == 0)
				{
					selection = 1;
					arrow.x = arrowPos2.x;
					arrow.y = arrowPos2.y;
					reverseArrow.x = reverseArrowPos2.x;
					reverseArrow.y = reverseArrowPos2.y;
				} else
				{
					selection = 0;
					arrow.x = arrowPos1.x;
					arrow.y = arrowPos1.y;
					reverseArrow.x = reverseArrowPos1.x;
					reverseArrow.y = reverseArrowPos1.y;
				}
				FlxG.play(beepSound);
			}
			if (FlxG.keys.justPressed("S"))
			{
				FlxG.mute = !FlxG.mute;
				if (FlxG.mute) soundText.text = "(S)ound: Off";
				else soundText.text = "(S)ound: On";
			}
			
		} // end function update
		
		
		public function MenuState()
		{
			super();
			
		}  // end function MenuState
		
	} // end class
}// end package 

