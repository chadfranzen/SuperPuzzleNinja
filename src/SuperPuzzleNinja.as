package
{
	import org.flixel.*;

	[SWF(width="576", height="504", backgroundColor="#000000")]
	
	public class SuperPuzzleNinja extends FlxGame
	{
		public function SuperPuzzleNinja()
		{
			super(288, 252, MenuState, 2, 60, 60);
			HighScore.load();
		}
	}
}