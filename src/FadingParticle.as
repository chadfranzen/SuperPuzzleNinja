package
{
	import org.flixel.*;
	
	public class FadingParticle extends FlxParticle
	{
		public var time:Number = 0;
		
		public function FadingParticle()
		{
			super();
		}
		
		override public function update():void
		{
			//particle fades out over time
			time += FlxG.elapsed;
			if (time > 1)
			{
				alpha -= 0.05;
				if (alpha <= 0) kill();
			}
			
			super.update();
		}
	}
}