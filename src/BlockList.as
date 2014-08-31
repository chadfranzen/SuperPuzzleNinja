package
{
	import org.flixel.*;
	
	public class BlockList
	{
		public var blocks:Array;
		public var length:uint = 0;
		
		public function BlockList()
		{
			blocks = new Array();
		}
		
		/**
		 * 
		 * @param 	i	Index of blocks array to return
		 * @return 	Block object at index i (or null if undefined)
		 * 
		 */		
		public function getBlock(i:uint):Block
		{
			if (i < blocks.length) return blocks[i];
			else return null;
		}
		
		/** 
		 * Makes a new block and adds it to the list.
		 * @return The newly-created block
		 */		
		public function generateNewBlock():Block
		{
			var block:Block = new Block()
			blocks.push(block);
			length++;
			return block;
		}
		
		/**
		 * If the argument is true, marks for death every block that has isCounted set to true.
		 * If false, just sets isCounted to false.
		 */		
		public function clearCounted(kill:Boolean):void
		{
			for (var i:uint = 0; i < length; i++)
			{
				if (kill){
					if (blocks[i].isCounted){
						blocks[i].isCounted = false;
						blocks[i].markForDeath();
					}
				}
				else
					blocks[i].isCounted = false;
			}
		}
		
		/** 
		 * This function will update the death timers for blocks marked for death, kill blocks ready to die, and clean up the blocks array.
		 * Returns an array containing the blocks that have just been killed.
		 */		
		public function clearDead():Array
		{
			var killed:Array = new Array();
			
			for (var i:uint = 0; i < length; i++)
			{
				if (blocks[i].markedForDeath)
				{
					if (blocks[i].deathCounter <= 0){
						killed.push(blocks[i]);
						blocks[i].kill();
					}
					else 
						blocks[i].deathCounter--;
				}
			}
			blocks = blocks.filter(isAlive);
			length = blocks.length;
			
			return killed;
		}
		
		public function isAlive(block:Block, index:int, arr:Array):Boolean
		{
			return (block.alive);
		}
		
		/**
		 * Use in conjunction with PlayState.countContinuous(). Returns true if any of the blocks that have been counted are bombs.
		 */		
		public function bombCounted():Boolean
		{
			for (var i:uint = 0; i < length; i++)
			{
				if (blocks[i].isCounted && blocks[i].isBomb) return true;
			}
			return false;
		}
	
	}
}