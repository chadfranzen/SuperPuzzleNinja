package
{
	import org.flixel.*;
	
	public class BlockStack
	{
		public var blocks:Array;
		public var length:uint = 0;
		
		public function BlockStack()
		{
			blocks = new Array();
		}
		
		/**
		 * Adds the specified block to the top of the block stack, and changes the state of the block to "STACKED"
		 */		
		public function addBlock(block:Block):void
		{	
			blocks.push(block);
			length++;
			
			var x:uint = PlayState.player.x + (PlayState.player.width / 2) - (PlayState.BLOCK_SIZE / 2)
			var y:uint = PlayState.player.y - (PlayState.BLOCK_SIZE * length);
			
			block.stackTo(x, y);
		}
		
		/**
		 * Removes the specified block from the block stack, if it is in the stack.
		 */		
		public function removeBlock(block:Block):void
		{
			var index:int = -1;
			for (var i:uint = 0; i < length; i++)
			{
				if (blocks[i] == block) index = i;
			}
			if (index != -1)
			{
				blocks.splice(index, 1);
				length--;
			}
		}
		
		/**
		 * Checks to see if any of the stacked blocks meet the conditions to be removed from the board, and handles it if so.
		 */		
		public function clearStackedBlocks():void
		{
			var continuous:uint = 0;
			var targetColor:uint = blocks[length - 1].blockColor;
			var done:Boolean = false;
			for (var i:int = length - 1; !done; i--)
			{
				if (blocks[i].blockColor == targetColor){
					continuous++;
					blocks[i].isCounted = true;
				}
				else done = true;
				if (i == 0) done = true;
			}
			if (continuous >= 4  && PlayState.blockList.bombCounted()) {
				PlayState.blockList.clearCounted(true);
			}
			else
				PlayState.blockList.clearCounted(false);
		}
		
		/**
		 * Returns true if the block stack is empty (i.e. the player isn't holding any blocks)
		 */		
		public function isEmpty():Boolean
		{
			return (length == 0);
		}
		
		/**
		 * Takes the block stack and places it so that the bottom block is at the specified game grid location (e.g. (3, 2))
		 * The block stack is then emptied.
		 */		
		public function placeOn(x:uint, y:uint):void
		{
			for (var i:uint = 0; i < length; i++)
			{
				blocks[i].lockTo(x, y - i);
			}
			blocks = new Array();
			length = 0;
		}
		
		/** 
		 * Centers the block stack on top of the player.
		 */		
		public function updatePosition():void
		{
			for (var i:uint = 0; i < length; i++)
			{
				blocks[i].x = PlayState.player.x + (PlayState.player.width / 2) - (PlayState.BLOCK_SIZE / 2)
				blocks[i].y = PlayState.player.y - (PlayState.BLOCK_SIZE * (i + 1));
			}
		}
		
		/**
		 * Returns the block at the specified index (0 is the bottom of the stack)
		 */		
		public function getBlock(i:uint):Block
		{
			if (i >= 0 && i < length) return blocks[i];
			return null;
		}
		
		/**
		 * Returns the block at the top of the stack
		 */		
		public function getTopBlock():Block
		{
			if (this.isEmpty()) return null;
			else return blocks[length - 1];
		}
		
		/**
		 * Alters the x position of the entire stack to the provided location
		 */		
		public function changeX(x:Number):void
		{
			for (var i:uint = 0; i < length; i++)
			{
				blocks[i].x = x;
			}
		}
	}
}