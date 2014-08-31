package
{
	import org.flixel.*;
	
	public class Block extends FlxSprite
	{
		[Embed(source = "data/redBlock.png")] public static var redBlockPng:Class;
		[Embed(source = "data/blueBlock.png")] public static var blueBlockPng:Class;
		[Embed(source = "data/purpleBlock.png")] public static var purpleBlockPng:Class;
		[Embed(source = "data/greenBlock.png")] public static var greenBlockPng:Class;
		[Embed(source = "data/redBomb.png")] public static var redBombPng:Class;
		[Embed(source = "data/blueBomb.png")] public static var blueBombPng:Class;
		[Embed(source = "data/yellowBomb.png")] public static var yellowBombPng:Class;
		[Embed(source = "data/greenBomb.png")] public static var greenBombPng:Class;
		
		public static const MAX_FREEFALL_VELOCITY:uint = 110;
		
		//Block states
		/**
		 *When a block is in freefall, it falls towards the bottom of the screen 
		 */		
		public static const FREEFALL:uint = 0;
		public static const LOCKED:uint = 1;
		public static const STACKED:uint = 2;
		
		//Block colors
		public static const RED:uint = 10;
		public static const BLUE:uint = 11;
		public static const PURPLE:uint = 12;
		public static const GREEN:uint = 13;
		
		//Block attributes
		/**
		 * Possible states are FREEFALL, LOCKED, and STACKED 
		 */		
		public var state:uint;
		/**
		 * Bomb blocks are special round blocks that allow the player to remove blocks from the board.
		 */		
		public var isBomb:Boolean;
		public var gridX:uint;
		public var gridY:uint;
		public var blockColor:uint;
		
		//Death-related stuff
		/**
		 * Used by the recursive PlayState.countContinuous(...) as well as BlockStack.clearStackedBlocks() 
		 * to denote whether a block has already been counted.
		 * Managed by BlockList.clearCounted(...).
		 */		
		public var isCounted:Boolean = false;
		/**
		 * A block that is marked for death will have kill() called on it by the game loop 
		 */		
		public var markedForDeath:Boolean = false;
		/**
		 * The number of frames that a block stays on screen before disappearing, once it is marked for death 
		 */		
		public var deathCounter:uint = 10;
		
		public function Block()
		{
			super(pickStartPos(), 0, pickBlockColor());
			var pos:FlxPoint = PlayState.getGridPos(this);
			freefall(60);
		}
		
		public function pickStartPos():Number
		{
			
			//try it the easy way
			var pos:Number = Math.random() * PlayState.BOARD_WIDTH_BLOCKS;
			pos = Math.floor(pos);
			var clear:Boolean = true;
			if (PlayState.OCCUPIED_GRID[pos][0] != null) clear = false;
			else
			{
				for (var i:uint = 0; i < PlayState.blockStack.length; i++)
				{
					if (PlayState.overlapsPos(PlayState.blockStack.getBlock(i), pos, 0)) clear = false;
				}
			}
			if (clear)
			{
				gridX = pos;
				return PlayState.BOARD_GRID[pos][0].x;
			}
			
			//if that doesn't work...
			else
			{
				var clearSpots:Array = new Array();
				for (i = 0; i < PlayState.OCCUPIED_GRID.length; i++)
				{
					clear = true;
					if (PlayState.OCCUPIED_GRID[i][0] != null) clear = false;
					else
					{
						for (var j:uint = 0; j < PlayState.blockStack.length; j++)
						{
							if (PlayState.overlapsPos(PlayState.blockStack.getBlock(j), i, 0)) clear = false;
						}
					}
					if (clear)
						clearSpots.push(i);
				}
				if (clearSpots.length == 0)
				{
					PlayState.fullBoard = true;
					return FlxG.width;
				}
				else
				{
					pos = Math.random() * clearSpots.length;
					pos = Math.floor(pos);
					pos = clearSpots[pos];
					gridX = pos;
					return PlayState.BOARD_GRID[pos][0].x;
				}
				
			}
		}
		
		public function pickBlockColor():Class
		{
			var bomb:Number = Math.floor(Math.random() * 4.5);
			var choice:Number = Math.floor(Math.random() * 4);
			if (bomb > 0)
			{
				isBomb = false;
				if (choice == 0){
					blockColor = RED;
					return redBlockPng;
				}
				else if (choice == 1){
					blockColor = BLUE;
					return blueBlockPng;
				}
				else if (choice == 2){
					blockColor = PURPLE;
					return purpleBlockPng;
				}
				blockColor = GREEN;
				return greenBlockPng;
			}
			else
			{
				isBomb = true;
				if (choice == 0){
					blockColor = RED;
					return redBombPng;
				}
				else if (choice == 1){
					blockColor = BLUE;
					return blueBombPng;
				}
				else if (choice == 2){
					blockColor = PURPLE;
					return yellowBombPng;
				}
				blockColor = GREEN;
				return greenBombPng;
			}
		}
		
		
		/**
		 * 
		 * Places block in the specified space on the board grid (see BOARD_GRID in PlayState for more details)
		 * The block becomes immobile, and collision is turned off between it an other blocks.
		 * 
		 */		
		public function lockTo(gridX:uint, gridY:uint):void
		{
			state = LOCKED;
			this.maxVelocity.y = 0;
			this.acceleration.y = 0;
			this.gridX = gridX;
			this.gridY = gridY;
			this.x = PlayState.BOARD_GRID[gridX][gridY].x;
			this.y = PlayState.BOARD_GRID[gridX][gridY].y;
			PlayState.OCCUPIED_GRID[gridX][gridY] = this;
			
			PlayState.clearLockedBlocks(gridX, gridY);
		}
		
		/** 
		 * Warning: this function is meant to be called by BlockStack upon adding this block to the block stack.
		 */		
		public function stackTo(x:uint, y:uint):void
		{
			if (state == LOCKED){
				PlayState.OCCUPIED_GRID[gridX][gridY] = null;
			}
			state = STACKED;
			this.maxVelocity.y = 0;
			this.acceleration.y = 0;
			this.x = x;
			this.y = y;
		}
		
		/**
		 * Sets the block to freefall
		 * Note: Parameter currently does nothing, but it's included in case a fall delay gets added in the future
		 */		
		public function freefall(delay:uint = 0):void
		{
				if (state == LOCKED){
					PlayState.OCCUPIED_GRID[gridX][gridY] = null;
				}
				state = FREEFALL;
				this.maxVelocity.y = MAX_FREEFALL_VELOCITY;
				this.velocity.y = MAX_FREEFALL_VELOCITY;
		}
		
		/** 
		 * Does typical kill stuff, but also updates OCCUPIED_GRID and sets blocks above it to freefall.
		 * When dealing with stacked blocks, just does usual kill.
		 */		
		override public function kill():void
		{
			if (state == LOCKED){
				PlayState.OCCUPIED_GRID[gridX][gridY] = null;
				for(var i:int = gridY; i >= 0; i--)
				{
					var block:Block = PlayState.OCCUPIED_GRID[gridX][i];
					if (block != null && block.alive) {
						block.freefall(20);
					}
				}
			} else if (state == STACKED){
				PlayState.blockStack.removeBlock(this);
			}
			super.kill();
		}
		
		public function markForDeath():void
		{
			markedForDeath = true;
		}
		
		public function isLocked():Boolean{return (state == LOCKED);}
		public function isInFreefall():Boolean{return (state == FREEFALL);}
		public function isStacked():Boolean{return (state == STACKED);}
	}
}