package
{
	import org.flixel.*;
	
	public class HighScore
	{
		private static var _save:FlxSave; //The FlxSave instance
		private static var _temp:int = 0; //Holds level data if bind() did not work. This is not persitent, and will be deleted when the application ends
		private static var _loaded:Boolean = false; //Did bind() work? Do we have a valid SharedObject?
		
		/**
		 * Returns the high score
		 */
		public static function get highScore():int
		{
			//We only get data from _save if it was loaded properly. Otherwise, use _temp
			if (_loaded)
			{
				return _save.data.highScore;
			}
			else
			{
				return _temp;
			}
		}
		
		/**
		 * Sets the high score
		 */
		public static function set highScore(value:int):void
		{
			if (_loaded)
			{
				_save.data.highScore = value;
			}
			else
			{
				_temp = value;
			}
		}
		
		/**
		 * Setup highScore
		 */
		public static function load():void
		{
			_save = new FlxSave();
			_loaded = _save.bind("myHighScore");
			if (_loaded && _save.data.highScore == null)
			{
				_save.data.highScore = 0;
			}
		}
	}
}