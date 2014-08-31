package
{
	import org.flixel.*;
	
	public class GhostStack
	{
		[Embed(source = "data/whiteGhost.png")] public var whiteGhostPng:Class;
		[Embed(source = "data/redGhost.png")] public var redGhostPng:Class;

		/**
		 *Holds all the ghost stack sprites
		 */		
		public var stack:Array = new Array();
		
		/**
		 * A constant used along with changeColor() 
		 */		
		public static const WHITE:uint = 0;
		
		/**
		 * A constant used along with changeColor() 
		 */		
		public static const RED:uint = 1;
		
		/**
		 * The current color of the stack, either WHITE or RED
		 */		
		public var currentColor:uint = WHITE;
		
		/**
		 * The number of blocks that are currently alive in the stack 
		 */		
		public var length:uint;
		
		public function GhostStack()
		{
			//array is long enough that you shouldn't ever run into issues, even if stacking mechanics change
			for (var i:uint = 0; i < PlayState.BOARD_HEIGHT_BLOCKS * 2; i++)
			{
				stack.push(new FlxSprite(0,0,whiteGhostPng));
				stack[i].kill();
				length = 0;
			}
		}
		
		/**
		 * Sets the height of the ghost stack in blocks
		 */		
		public function setLength(endLength:uint):void
		{
			killAll();
			if (endLength > stack.length) return;
			for(var i:uint = 0; i < endLength; i++)
			{
				stack[i].revive();
			}
			length = endLength;
		}
		
		/** 
		 * Places the ghost stack s.t. the bottom block is in at the given grid position
		 */		
		public function placeOn(pos:FlxPoint):void
		{
			for(var i:uint = 0; i < stack.length; i++)
			{	
				var block:FlxSprite = stack[i];
				if (block.alive)
				{
					if (pos.y - i < 0) block.y = 0 - block.height;
					else
					{
						block.x = PlayState.BOARD_GRID[pos.x][pos.y - i].x;
						block.y = PlayState.BOARD_GRID[pos.x][pos.y - i].y;
					}
				}
			}
		}
		
		/**
		 * Kills the whole ghost stack
		 */		
		public function killAll():void
		{
			for (var i:uint = 0; i < length; i++)
			{
				stack[i].kill();
			}
			length = 0;
		}
		
		/**
		 * Changes color of stack. Use constants for the argument.
		 */		
		public function changeColor(color:uint):void
		{
			if (color == currentColor) return;
			if (color != WHITE && color != RED) return;
			for (var i:uint = 0; i < stack.length; i++)
			{
				if (color == WHITE)
					stack[i].loadGraphic(whiteGhostPng);
				else if (color == RED)
					stack[i].loadGraphic(redGhostPng);
			}
			currentColor = color;
		}
	}
}