package
{
	import org.flixel.*;
	
	public class InstructionsPageThree extends FlxState
	{
		[Embed(source = "data/PressStart2P.ttf", fontFamily="PIXEL", embedAsCFF="false")] public var fontPixel:String;
		[Embed(source = "data/04B_03__.TTF", fontFamily="TINY", embedAsCFF="false")] public var fontTiny:String;
		[Embed(source = "data/titleScreen.png")] public var titleScreenPng:Class;
		[Embed(source = "data/instructions3.png")] public var instructions3Png:Class;
		[Embed(source = "data/beep.mp3")] public var beepSound:Class;
		
		public var titleScreen:FlxSprite;
		public var instructions:FlxSprite;
		public var text:FlxText;
		public var scoreText:FlxText;
		
		/**
		 * The text in the bottom right saying if the sound is on or not 
		 */		
		public static var soundText:FlxText;
		
		override public function create():void
		{
			FlxG.play(beepSound);
			
			titleScreen= new FlxSprite(0, 0, titleScreenPng);
			add(titleScreen);
			
			instructions = new FlxSprite(0, 0, instructions3Png);
			add(instructions);
			
			text = new FlxText(0, 170, FlxG.width, "Place 4+ blocks together\nwith a bomb (round) block\nto remove it from the board.\n\n\nPress ENTER to continue");
			text.setFormat("PIXEL", 8, 0xFFFFFFFF, "center", 0xff333333);
			add(text);
			
			scoreText = new FlxText(0, 130, FlxG.width, "         +400");
			scoreText.setFormat("PIXEL", 6, 0xFFFFFFFF, "center");
			add(scoreText);
			
			soundText = new FlxText(0, FlxG.height - 10, FlxG.width, "(S)ound: On");
			soundText.setFormat("TINY", 8, 0xffffffff, "right");
			if (FlxG.mute) soundText.text = "(S)ound: Off";
			add(soundText);
			
		}
		
		
		override public function update():void
		{
			super.update();
			
			if (FlxG.keys.justPressed("SPACE") || FlxG.keys.justPressed("X") || FlxG.keys.justPressed("ENTER"))
			{
				FlxG.switchState(new MenuState());
			}
			if (FlxG.keys.justPressed("S"))
			{
				FlxG.mute = !FlxG.mute;
				if (FlxG.mute) soundText.text = "(S)ound: Off";
				else soundText.text = "(S)ound: On";
			}
			
		}
		
		
		public function InstructionsPageThree()
		{
			super();
			
		}
		
	} 
}