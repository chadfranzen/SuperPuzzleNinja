package
{
	import org.flixel.FlxSprite;
	
	public class Player extends FlxSprite
	{
		[Embed(source = "data/ninjaSheet.png")] public var ninjaSheetPng:Class;
		
		/**
		 * Whether the player is touching a left wall, a right wall, or nothing. 
		 */		
		public var wallState:uint;
		
		//wallState constants
		public const NO_WALL:uint = 0;
		public const LEFT_WALL:uint = 1;
		public const RIGHT_WALL:uint = 2;
		
		public function Player(X:Number = 0, Y:Number = 0)
		{
			super(X, Y);
			this.loadGraphic(ninjaSheetPng, true, true, 9, 12, true);
			this.maxVelocity.x = 130;
			this.maxVelocity.y = 400;
			this.acceleration.y = 700;
			this.drag.x = this.maxVelocity.x*10;
			
			addAnimation("IDLE", [0]);
			addAnimation("WALK", [1, 2], 20, true);
			addAnimation("JUMP", [3]);
			addAnimation("WALL", [4]);
			addAnimation("CARRY_IDLE", [5]);
			addAnimation("CARRY_WALK", [6, 7], 20, true);
			addAnimation("CARRY_JUMP", [8]);
			addAnimation("CARRY_WALL", [9]);
			
			facing = RIGHT;
			wallState = NO_WALL;
		}
		
		/**
		 * Centers the player underneath a block.
		 * Used for making collision a little prettier when the player and block stack are moving as a unit
		 */		
		public function placeUnder(block:Block):void
		{
			this.x = (block.x + (block.width / 2) - (this.width / 2));
		}
		
		public function isFacingLeft():Boolean
		{
			return facing == LEFT;
		}
		
		public function isFacingRight():Boolean
		{
			return facing == RIGHT;
		}
		
		public function isOnLeftWall():Boolean
		{
			return wallState == LEFT_WALL;
		}
		
		public function isOnRightWall():Boolean
		{
			return wallState == RIGHT_WALL;
		}
		
		public function selectAnimation():void
		{
			if (PlayState.blockStack.isEmpty())
			{
				if ((isOnRightWall() || isOnLeftWall()) && !isTouching(FLOOR)) play("WALL");
				else if (velocity.y > 0) play("JUMP");
				else if (velocity.x == 0) play("IDLE");
				else play("WALK");
			}
			else
			{
				if ((isOnRightWall() || isOnLeftWall()) && !isTouching(FLOOR)) play("CARRY_WALL");
				else if (velocity.y > 0) play("CARRY_JUMP");
				else if (velocity.x == 0) play("CARRY_IDLE");
				else play("CARRY_WALK");
			}
		}
		
	}
}