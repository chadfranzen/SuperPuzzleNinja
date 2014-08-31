package
{
	import org.flixel.*;
	
	public class PlayState extends FlxState
	{
		// Measurements
		/**
		 * The width of the screen in FlxTiles
		 */		
		static public const X_TILES:Number = 24;
		
		/**
		 * The height of the screen in FlxTiles
		 */		
		static public const Y_TILES:Number = 21;
		
		/**
		 * Width of a Block, in FlxTiles 
		 */		
		static public const TILES_PER_BLOCK:Number = 2;
		
		/**
		 * The width of the buffer between the left edge of the screen and the game board, in FlxTiles 
		 */		
		static public const LEFT_BOARD_BUFFER:Number = 1;
		
		/**
		 * The height of the buffer between the bottom of the screen and the game board, in FlxTiles 
		 */		
		static public const BOTTOM_BOARD_BUFFER:Number = 1;
		
		/**
		 * The width of the game board in FlxTiles 
		 */		
		static public const BOARD_WIDTH_TILES:Number = 14;
		
		/**
		 * The width of the game board in Blocks 
		 */		
		static public const BOARD_WIDTH_BLOCKS:Number = BOARD_WIDTH_TILES / TILES_PER_BLOCK;
		
		/**
		 * The height of the game board in FlxTiles 
		 */		
		static public const BOARD_HEIGHT_TILES:Number = Y_TILES - BOTTOM_BOARD_BUFFER;
		
		/**
		 * The height of the game board in Blocks
		 */		
		static public const BOARD_HEIGHT_BLOCKS:Number = BOARD_HEIGHT_TILES / TILES_PER_BLOCK;
		
		/**
		 * Both the width and height of an FlxTile, in pixels 
		 */		
		static public var TILE_SIZE:Number; //set this during create() because FlxG.width isn't initialized yet
		
		/**
		 * Both the width and height of a Block, in pixels 
		 */		
		static public var BLOCK_SIZE:Number; //same as above
		
		//Game over stuff
		
		/**
		 * If it is impossible to spawn more blocks, this gets set to true.
		 */		
		static public var fullBoard:Boolean;
		
		/**
		 * Whether the game over screen is currently displayed. 
		 */		
		static public var gameOver:Boolean;
		
		//Block spawning stuff
		
		/**
		 * The initial value of timeToSpawn
		 */		
		static public const INITIAL_TIME_TO_SPAWN:Number = 1.8;
		
		/**
		 * How frequently the block spawn time decreases, in seconds
		 */		
		static public const TIME_TO_SPAWN_INCREASE:Number = 30;
		
		/**
		 * How many seconds the spawn time decreases by, when it is decreased. 
		 */		
		static public const SPAWN_TIME_DECREMENT:Number = 0.1;
		
		/**
		 * How frequently blocks spawn, in seconds. 
		 */		
		static public var timeToSpawn:Number;
		
		/**
		 * The time since the last block spawn, in seconds. 
		 */		
		static public var spawnCounter:Number;
		
		/**
		 * The time since timeToSpawn was last decreased.
		 */		
		static public var spawnTimeCounter:Number;
		
		/**
		 * Debug variable. Whether blocks are currently spawning. 
		 */		
		static public var blockSpawn:Boolean = true;
		
		//Collision helpers
		
		/**
		 *A collision helper 
		 */		
		public static var wallBox:FlxSprite;
		/**
		 *A collision helper 
		 */		
		public static var floorBox:FlxSprite;
		/**
		 *A collision helper 
		 */		
		public static var ceilingBox:FlxSprite;
		
		/**
		 *The line near the top of the game board that blocks player movement
		 */		
		public static var boundaryMarker:FlxSprite;
		
		//Score-related stuff & sidebar
		
		/**
		 * The box that the score goes in, dummy! 
		 */		
		public static var scoreBoard:FlxSprite;
		
		/**
		 * The graphical text version of the score 
		 */		
		public static var scoreText:FlxText;
		
		/**
		 * The numerical version of the score 
		 */		
		public static var score:uint;
		
		/**
		 * The graphical text version of the high score 
		 */		
		public static var highScoreText:FlxText;
		
		/**
		 * The text in the bottom right saying if the sound is on or not 
		 */		
		public static var soundText:FlxText;
		
		//Gameplay utilities
		
		/**
		 *A structure for managing the Blocks currently in play 
		 */		
		public static var blockList:BlockList;
		
		/**
		 *A structure for managing the ghost stack when the player is holding blocks
		 */		
		public static var ghostStack:GhostStack;
		
		/**
		 *A structure for managing the Blocks currently being carried by the player 
		 */		
		public static var blockStack:BlockStack;
		
		/**
		 *Holds all the particle emitters that the game generates 
		 */		
		public static var emitters:Array;
		
		/**
		 *Contains FlxPoints with the pixel values for each game grid position 
		 */		
		static public var BOARD_GRID:Array; //set during create()
		
		/**
		 *Contains references to the block objects locked to each grid location, or null if there isn't one locked there
		 */		
		static public var OCCUPIED_GRID:Array;//same as above
		
		public var level:FlxTilemap;
		public static var player:Player;
		
		FlxG.debug = false;
		
		
		[Embed(source = "data/tilemap.png")] public var tilemapPng:Class;
		[Embed(source = "data/background.png")] public var backgroundPng:Class;
		[Embed(source = "data/boundaryMarker.png")] public var boundaryMarkerPng:Class;
		[Embed(source = "data/boardWall.png")] public var boardWallPng:Class;
		[Embed(source = "data/scoreBoard.png")] public var scoreBoardPng:Class;
		[Embed(source = "data/PressStart2P.ttf", fontFamily="PIXEL", embedAsCFF="false")] public var fontPixel:String;
		[Embed(source = "data/04B_03__.TTF", fontFamily="TINY", embedAsCFF="false")] public var fontTiny:String;
		[Embed(source = "data/beep.mp3")] public var beepSound:Class;
		[Embed(source = "data/jump.mp3")] public var jumpSound:Class;
		[Embed(source = "data/fall.mp3")] public var fallSound:Class;
		[Embed(source = "data/explode.mp3")] public var explodeSound:Class;
		[Embed(source = "data/pickUp.mp3")] public var pickUpSound:Class;
		[Embed(source = "data/putDown.mp3")] public var putDownSound:Class;
		[Embed(source = "data/death.mp3")] public var deathSound:Class;
		
		override public function create():void
		{
				FlxG.play(beepSound);
				
				//setting general stuff
			
				FlxG.bgColor = 0xffaaaaaa;
				
				TILE_SIZE = Number(FlxG.width) / X_TILES;
				BLOCK_SIZE = TILE_SIZE * TILES_PER_BLOCK;
				BOARD_GRID = buildBoardGrid();
				OCCUPIED_GRID = buildOccupiedGrid();
				
				gameOver = false;
				fullBoard = false;
				
				score = 0;
				
				timeToSpawn = INITIAL_TIME_TO_SPAWN;
				spawnCounter = 0;
				spawnTimeCounter = 0;
				
				//creating level & graphics
				
				var data:Array = buildTileMap();
				
				level = new FlxTilemap();
				level.loadMap(FlxTilemap.arrayToCSV(data,X_TILES), tilemapPng);
				add(level);
				
				var bg:FlxSprite = new FlxSprite(BOARD_GRID[0][0].x, BOARD_GRID[0][0].y, backgroundPng);
				add(bg);
				
				boundaryMarker = new FlxSprite(TILE_SIZE,TILE_SIZE * 2, boundaryMarkerPng);
				boundaryMarker.immovable = true;
				add(boundaryMarker);
				
				var boardWall:FlxSprite = new FlxSprite(BOARD_GRID[0][0].x - 4, BOARD_GRID[0][0].y, boardWallPng);
				add(boardWall);
				
				scoreBoard = new FlxSprite((LEFT_BOARD_BUFFER + BOARD_WIDTH_TILES +0.5) * TILE_SIZE, TILE_SIZE * 2, scoreBoardPng);
				add(scoreBoard);
				
				var scoreSign:FlxText = new FlxText(scoreBoard.x - 1, scoreBoard.y + 7, scoreBoard.width, "SCORE");
				scoreSign.setFormat("PIXEL", 8, 0xffffffff, "center");
				add(scoreSign);
				
				scoreText = new FlxText(scoreBoard.x - 1, scoreSign.y + 10, scoreBoard.width, "00000000");
				scoreText.setFormat("PIXEL", 8, 0xffffffff, "center");
				add(scoreText);
				
				var highScoreSign:FlxText = new FlxText(scoreBoard.x - 3, scoreText.y + 14, scoreBoard.width + 4, "HIGH SCORE");
				highScoreSign.setFormat("PIXEL", 8, 0xffffffff, "center");
				add(highScoreSign);
				
				highScoreText = new FlxText(scoreBoard.x - 1, highScoreSign.y + 10, scoreBoard.width, "00000000");
				highScoreText.setFormat("PIXEL", 8, 0xffffffff, "center");
				add(highScoreText);
				
				var tempHighScoreText:String = (HighScore.highScore).toString();
				while (tempHighScoreText.length < 8) tempHighScoreText = "0" + tempHighScoreText;
				highScoreText.text = tempHighScoreText;
				
				soundText = new FlxText(0, FlxG.height - 10, FlxG.width, "(S)ound: On");
				soundText.setFormat("TINY", 8, 0xffffffff, "right");
				if (FlxG.mute) soundText.text = "(S)ound: Off";
				add(soundText);
				
				
				//Create player
				player = new Player(FlxG.width/2 - 5, FlxG.width/2);
				
				//Creating movement helpers (mostly for walljump and wallslide detection)
				wallBox = new FlxSprite(player.x, player.y);
				wallBox.makeGraphic(player.width + 2, player.height);
				wallBox.visible = false;
				add(wallBox);
				
				floorBox = new FlxSprite(player.x + 1, player.y + player.height);
				floorBox.makeGraphic(player.width - 2, 2, 0xff00ff00);
				floorBox.visible = false;
				add(floorBox);
				
				ceilingBox = new FlxSprite(player.x + 1, player.y - 2);
				ceilingBox.makeGraphic(player.width - 2, 2, 0xff00ff00);
				ceilingBox.visible = false;
				add(ceilingBox);
				
				//player added later so it shows up on top
				add(player);
				
				//Create gameplay structures
				blockList = new BlockList();
				
				blockStack = new BlockStack();
				
				ghostStack = new GhostStack();
				for (var i:uint = 0; i < ghostStack.stack.length; i++)
					add(ghostStack.stack[i]);
				
				emitters = new Array();
				
		}
		
		override public function update():void
		{	
			movePlayer();
			
			super.update();
			
			//updating locations for movement helpers
			wallBox.x = player.x - (wallBox.width - player.width)/2;
			wallBox.y = player.y - (wallBox.height - player.height)/2;
			
			floorBox.x = player.x + (player.width - floorBox.width)/2;
			floorBox.y = player.y + player.height;
			
			ceilingBox.x = player.x + (player.width - floorBox.width)/2;
			ceilingBox.y = player.y - ceilingBox.height;
			
			//easy collisions
			FlxG.collide(level,player);
			FlxG.collide(player, boundaryMarker);
			FlxG.collide(level,wallBox);
			
			blockStack.updatePosition();
			
			//checking block collision
			for (var i:uint = 0; i < blockList.length; i++)
			{
				var block:Block = blockList.getBlock(i);
				
				if (!block.isStacked() && FlxG.collide(level, block)){ //any level collision results in locking
					block.lockTo(block.gridX, BOARD_HEIGHT_BLOCKS - 1);
				}//note that more complex block stack collision would probably require that this get changed
				
				if (FlxG.overlap(block, player) && block.isLocked() && FlxG.overlap(block,wallBox) && !FlxG.overlap(block,floorBox) && !FlxG.overlap(block, ceilingBox)){
					block.immovable = true;
					FlxObject.separateX(block, player);
					FlxObject.separateX(block, wallBox);
					block.immovable = false;
				}
				else if (!block.isStacked()) {
					block.immovable = true;
					FlxG.collide(block, player);
					FlxG.collide(block, wallBox);
					block.immovable = false;
				}
				if (block.isInFreefall()){
					for (var j:uint = 0; j < blockList.length && block.isInFreefall(); j++)
					{
						if (i != j)
						{
							var otherBlock:Block = blockList.getBlock(j);
							if (otherBlock.isLocked() && otherBlock.gridX == block.gridX)
							{
								otherBlock.immovable = true;
								if (FlxG.collide(block, otherBlock))
									block.lockTo(block.gridX, otherBlock.gridY - 1);
								otherBlock.immovable = false;
							}
							else if (otherBlock.isStacked() && FlxG.overlap(block, otherBlock))
							{
								if (blockStack.getTopBlock() == otherBlock && FlxObject.separateY(block, otherBlock))
								{
									blockStack.addBlock(block);
									blockStack.clearStackedBlocks();
								}
								else
								{
									block.immovable = true;
									FlxObject.separateX(block, otherBlock);
									blockStack.changeX(otherBlock.x);
									player.placeUnder(otherBlock);
									block.immovable = false;
								}
							}				
						}
					}
				}
			}
			
			//updating particles
			for (var k:uint = 0; k < emitters.length; k++)
			{
				var emitter:FlxEmitter = emitters[k];
				if (emitter.countDead() == 0)
				{
					FlxG.collide(emitter, level);
					for (var l:uint = 0; l < blockList.length; l++)
					{
						blockList.getBlock(l).immovable = true;
						FlxG.collide(emitter, blockList.getBlock(l));
						blockList.getBlock(l).immovable = false;
					}
				}
				else
				{
					emitter.kill();
					emitter.destroy();
				}
			}
			
			emitters = emitters.filter(isAlive);
			
			
			//checking walljump state
			if (player.isTouching(FlxObject.LEFT))
				player.wallState = player.LEFT_WALL;
			else if (player.isOnLeftWall() && !wallBox.isTouching(FlxObject.LEFT))
				player.wallState = player.NO_WALL;
			if (player.isTouching(FlxObject.RIGHT))
				player.wallState = player.RIGHT_WALL;
			else if (player.isOnRightWall() && !wallBox.isTouching(FlxObject.RIGHT))
				player.wallState = player.NO_WALL;
			
			//clearing blocks
			clearDead();
			
			checkForFull();
			
			//checking for block generation
			if (!fullBoard)
			{
				spawnCounter += FlxG.elapsed;
				spawnTimeCounter += FlxG.elapsed;
				
				if (!gameOver && spawnCounter >= timeToSpawn && blockSpawn)
				{
					add(blockList.generateNewBlock());
					
					spawnCounter = 0;
				}
				
				if (spawnTimeCounter >= TIME_TO_SPAWN_INCREASE)
				{
					timeToSpawn -= SPAWN_TIME_DECREMENT;
					
					spawnTimeCounter = 0;
				}
				
				
			}
			
			updateGhostStack();
			
			checkForDeath();
			
			if (!gameOver) bringStackedToFront();
			
			if ((!player.alive || fullBoard) && !gameOver)
			{
				FlxG.play(deathSound);
				displayGameOver();
			}
			
			FlxG.log(FlxG.elapsed);
		}
		
		public function movePlayer():void
		{
			player.acceleration.x = 0;
			
			if(!gameOver)
			{
				if(FlxG.keys.LEFT){
					player.acceleration.x = -player.maxVelocity.x*30;
					player.facing = FlxObject.LEFT;
				}
				if(FlxG.keys.RIGHT){
					player.acceleration.x = player.maxVelocity.x*30;
					player.facing = FlxObject.RIGHT;
				}
				
				if(FlxG.keys.justPressed("SPACE") && player.isTouching(FlxObject.FLOOR))
				{
					player.velocity.y = -player.maxVelocity.y/2;
					FlxG.play(jumpSound);
				}
				
				if(FlxG.keys.justPressed("SPACE") && player.isOnLeftWall() && !player.isTouching(FlxObject.FLOOR))
				{
					player.velocity.y = -player.maxVelocity.y/2;
					player.velocity.x = player.maxVelocity.x;
					FlxG.play(jumpSound);
				}
				if(FlxG.keys.justPressed("SPACE") && player.isOnRightWall() && !player.isTouching(FlxObject.FLOOR))
				{
					player.velocity.y = -player.maxVelocity.y/2;
					player.velocity.x = -player.maxVelocity.x;
					FlxG.play(jumpSound);
				}
				if(FlxG.keys.justReleased("SPACE") && player.velocity.y < 0)
					player.velocity.y = player.velocity.y/2;
			
				if (FlxG.debug)
				{
					if(FlxG.keys.justPressed("Z"))
						blockSpawn = !blockSpawn;
					if(FlxG.keys.justPressed("C"))
						printGrid();
				}
			
				var pos:FlxPoint = getGridPos(player);
				if (FlxG.keys.justPressed("X"))
				{
					if (blockStack.isEmpty() && player.isTouching(FlxObject.FLOOR))
					{
						if (player.isOnRightWall() && pos.x < BOARD_GRID.length - 1){
							if (isClearFromFreefalling(pos, pos.y - firstEmptyPos(pos.x + 1).y))
							{
								stack(pos.x + 1, pos.y);
								FlxG.play(pickUpSound);
							}
						}
						else if (player.isOnLeftWall() && pos.x > 0){
							if (isClearFromFreefalling(pos, pos.y - firstEmptyPos(pos.x - 1).y))
							{
								stack(pos.x - 1, pos.y);
								FlxG.play(pickUpSound);
							}
						}
					}
					else if (!blockStack.isEmpty())
					{
						var stackPos:FlxPoint;
						if(player.isFacingRight() && pos.x < BOARD_GRID.length - 1)
						{
							stackPos = firstEmptyPos(pos.x + 1);
							if (stackPos.y >= (pos.y - 1) && isClear(stackPos, blockStack.length)){
								blockStack.placeOn(stackPos.x, stackPos.y);
								if (player.x + player.width > BOARD_GRID[stackPos.x][stackPos.y].x)
									player.x = BOARD_GRID[stackPos.x][stackPos.y].x - player.width;
								FlxG.play(putDownSound);
							}
						}
						else if (player.isFacingLeft() && pos.x > 0)
						{
							stackPos = firstEmptyPos(pos.x - 1);
							if (stackPos.y >= (pos.y - 1) && isClear(stackPos, blockStack.length)){
								blockStack.placeOn(stackPos.x, stackPos.y);
								if (player.x < BOARD_GRID[stackPos.x][stackPos.y].x + BLOCK_SIZE)
									player.x = BOARD_GRID[stackPos.x][stackPos.y].x + BLOCK_SIZE;
								FlxG.play(putDownSound);
							}
						}
					}
				}
			
			}
			
			if(FlxG.keys.justPressed("R") && gameOver)
			{
				FlxG.resetState();
			}
			if(FlxG.keys.justPressed("ENTER") && gameOver)
			{
				FlxG.switchState(new MenuState());
			}
			
			if (FlxG.keys.justPressed("S"))
			{
				FlxG.mute = !FlxG.mute;
				if (FlxG.mute) soundText.text = "(S)ound: Off";
				else soundText.text = "(S)ound: On";
			}
			
			player.selectAnimation();
			
		}
		
		/**
		 * Adds blocks to the player's block stack, starting at the indicated position and moving up the column
		 */		
		public function stack(x:uint, y:uint):void
		{
			var finished:Boolean = false;
			while (!finished) {
				var block:Block = OCCUPIED_GRID[x][y];
				if (block != null){
					blockStack.addBlock(block);
					y--;
				}
				else
					finished = true;
			}
		}
		
		/**
		 * Builds the game board based on the constants up at the top
		 */		
		public function buildTileMap():Array
		{
			var array:Array = new Array();
			for (var i:uint = 0; i < Y_TILES - BOTTOM_BOARD_BUFFER; i++)
			{
				for (var j:uint = 0; j < LEFT_BOARD_BUFFER; j++)
					array.push(1);
				for (var k:uint = 0; k < BOARD_WIDTH_TILES; k++)
					array.push(0);
				for (var l:uint = 0; l < X_TILES - BOARD_WIDTH_TILES - LEFT_BOARD_BUFFER; l++)
					array.push(1);
			}
			for (var m:uint = 0; m < BOTTOM_BOARD_BUFFER; m++)
			{
				for (var n:uint = 0; n < X_TILES; n++)
					array.push(1);
			}
			
			return array;
		}
		/**
		 * 
		 * Builds an array of board coordinates based on the constants up at the top
		 * The grid is built in (x,y) format, with the (0,0) point being the upper left grid location
		 * Values are the pixel coordinates of the upper left corner of that grid location
		 * 
		 */		
		public function buildBoardGrid():Array
		{
			var array:Array = new Array();
			for (var i:uint = 0; i < BOARD_WIDTH_BLOCKS; i++)
			{
				var subArray:Array = new Array();
				for (var j:uint = 0; j < BOARD_HEIGHT_BLOCKS; j++)
				{
					var x:Number = (BLOCK_SIZE * i) + (TILE_SIZE * LEFT_BOARD_BUFFER);
					var y:Number = (BLOCK_SIZE * j);
					subArray.push(new FlxPoint(x, y));
				}
				array.push(subArray);
			}
			return array;
		}
		
		/**
		 * Just makes a 2D array of all null references
		 */		
		public function buildOccupiedGrid():Array
		{
			var array:Array = new Array();
			for (var i:uint = 0; i < BOARD_WIDTH_BLOCKS; i++)
			{
				var subArray:Array = new Array();
				for (var j:uint = 0; j < BOARD_HEIGHT_BLOCKS; j++)
				{
					subArray.push(null);
				}
				array.push(subArray);
			}
			return array;
		}
		
		/**
		 * 
		 * Determines the approximate game grid position of the sprite, based on the midpoint of the sprite's location.
		 * Returns (-1, -1) if the sprite is not on the grid
		 * @return An FlxPoint containing the index for the grid position, as defined by BOARD_GRID
		 * 
		 */		
		public static function getGridPos(object:FlxSprite):FlxPoint
		{
			var pos:FlxPoint = new FlxPoint(-1, -1);
			
			var midX:Number = object.x + (object.width / 2);
			var midY:Number = object.y + (object.height / 2);
			for (var i:uint = 0; i < BOARD_GRID.length; i++)
			{
				if (midX >= BOARD_GRID[i][0].x && midX < (BOARD_GRID[i][0].x + BLOCK_SIZE)) pos.x = i;
			}
			for (var j:uint = 0; j < BOARD_GRID[0].length; j++)
			{
				if (midY >= BOARD_GRID[0][j].y && midY < (BOARD_GRID[0][j].y + BLOCK_SIZE)) pos.y = j;
			}
			
			return pos;
		}
		
		/**
		 * Checks to see if any part of the FlxSprite is in the given grid square (grid based off BOARD_GRID)
		 */		
		public static function overlapsPos(object:FlxSprite, gridX:uint, gridY:uint):Boolean
		{
			var pos:FlxSprite = new FlxSprite(BOARD_GRID[gridX][gridY].x, BOARD_GRID[gridX][gridY].y);
			pos.makeGraphic(BLOCK_SIZE, BLOCK_SIZE);
			return object.overlaps(pos);
		}
		
		/**
		 * Checks that there is enough room to place the block stack at the given position, and that there are no freefalling blocks in the way
		 * 
		 * @param startPos The grid position of where the bottom block of the stack should be
		 * @param height The height of the block stack (should just be blockStack.length)
		 * 
		 */		
		public static function isClear(startPos:FlxPoint, height:uint):Boolean
		{
			if ((startPos.y - height + 1) < 0) return false;
			
			return isClearFromFreefalling(startPos, height);
		}
		
		/**
		 * Checks to ensure that there are no freefalling blocks in the given section of the given column
		 */		
		public static function isClearFromFreefalling(startPos:FlxPoint, height:uint):Boolean
		{
			var clear:Boolean = true;
			for(var i:uint = 0; i < blockList.length; i++)
			{
				var block:Block = blockList.getBlock(i);
				if (block.isInFreefall())
				{
					for(var j:uint = 0; j < height; j++)
					{
						if (startPos.y - j >= 0 && overlapsPos(block, startPos.x, startPos.y - j)) clear = false;
					}
				}
			}
			
			return clear;
		}
		
		/**
		 * Returns the first grid location (i.e. closest to the bottom on the board) in the provided column that doesn't contain a locked block
		 * Will return (x, -1) if the entire column is full.
		 * 
		 * @param x The x-coordinate of the grid column in question
		 * 
		 */		
		public static function firstEmptyPos(x:uint):FlxPoint
		{
			var y:int = OCCUPIED_GRID[x].length - 1;
			while(y >= 0 && OCCUPIED_GRID[x][y] != null)
			{
				y--;
			}
			return new FlxPoint(x, y);
		}
		
		public static function countContinuous(x:uint, y:uint, targetColor:uint = 0):uint
		{
			if (x < 0 || x >= BOARD_WIDTH_BLOCKS || y < 0 || y >= BOARD_HEIGHT_BLOCKS) return 0;
			var block:Block = OCCUPIED_GRID[x][y];
			if (block == null || block.isCounted) return 0;
			
			if (targetColor == 0){
				block.isCounted = true;
				var result:uint = 1 + countContinuous(x - 1, y, block.blockColor) + countContinuous(x + 1, y, block.blockColor) + countContinuous(x, y - 1, block.blockColor) + countContinuous(x, y + 1, block.blockColor);
				return result;
			}
			
			else
			{
				if (block.blockColor != targetColor) return 0;
				block.isCounted = true;
				return 1 + countContinuous(x - 1, y, targetColor) + countContinuous(x + 1, y, targetColor) + countContinuous(x, y - 1, targetColor) + countContinuous(x, y + 1, targetColor);
			}
		}
		
		/**
		 * This function gets called whenever a block locks into place. It checks whether any blocks meet the conditions to be removed
		 * from the board, and marks it for death if so. Note that it does NOT remove it from the board. You'll need blockList.clearDead() for that.
		 */		
		public static function clearLockedBlocks(x:uint, y:uint):void
		{
			var size:uint = countContinuous(x, y);
			if (size >= 4  && blockList.bombCounted()) {
				blockList.clearCounted(true);
			}
			else
				blockList.clearCounted(false);
		}
		
		/**
		 * Updates the size, color, and position of the ghost stack 
		 */		
		public static function updateGhostStack():void
		{
			var pos:FlxPoint = getGridPos(player);
			if ((player.isFacingRight() && pos.x >= BOARD_WIDTH_BLOCKS - 1) || (player.isFacingLeft() && pos.x <= 0))
				ghostStack.killAll(); //ghost stack shouldn't appear
			else
			{
				var stackPos:FlxPoint; //find position
				if(player.isFacingRight())
				{
					stackPos = firstEmptyPos(pos.x + 1);
				}
				else if (player.isFacingLeft())
				{
					stackPos = firstEmptyPos(pos.x - 1);
				}
				if (stackPos.y >= 0 && stackPos.y >= (pos.y - 1))
				{
					ghostStack.setLength(blockStack.length);
					
					if (isClear(stackPos, ghostStack.length)) //set color
					{
						ghostStack.changeColor(GhostStack.WHITE);
					}
					else
					{
						ghostStack.changeColor(GhostStack.RED);
					}
					ghostStack.placeOn(stackPos);
				}
				else
				{
					ghostStack.killAll(); //don't show if there's not enough room or it's too far up
				}
				
			}
			
		}
		
		/**
		 * Calls blockList.clearDead(), makes particle effects for any killed blocks, and updates score.
		 */		
		public function clearDead():void
		{
			var killed:Array = blockList.clearDead();
			for (var i:uint = 0; i < killed.length; i++)
			{
				var block:Block = killed[i];
				if (killed.length >= 10) //particles reduced if necessary to keep framerate up
					makeParticles(block.x + (block.width / 2), block.y + (block.height / 2), block.blockColor, 2);
				else if (killed.length >= 8)
					makeParticles(block.x + (block.width / 2), block.y + (block.height / 2), block.blockColor, 3);
				else
					makeParticles(block.x + (block.width / 2), block.y + (block.height / 2), block.blockColor);
			}
			
			if (killed.length > 0) FlxG.play(explodeSound);
			
			var justScored:uint = 0;
			justScored += (100 * killed.length);
			if (killed.length > 4)
			{
				justScored += (killed.length - 4) * 50;
			}
			updateScores(justScored);
		}
		
		/**
		 * Generates a particle effect for cleared blocks at the given grid position, with the given color
		 */		
		public function makeParticles(x:uint, y:uint, color:uint = 0, numParticles:uint = 4):void
		{
			var emitter:FlxEmitter = new FlxEmitter(x,y);
			emitter.gravity = 400;
			emitter.bounce = 0.5;
			
			for(var t:int = 0; t < numParticles; t++)
			{
				var particle:FlxParticle = new FadingParticle();
				if (color == Block.RED)
					particle.makeGraphic(2, 2, 0xffff4c00);
				else if (color == Block.BLUE)
					particle.makeGraphic(2, 2, 0xff2367e4);
				else if (color == Block.GREEN)
					particle.makeGraphic(2, 2, 0xff6bbb00);
				else if (color == Block.PURPLE)
					particle.makeGraphic(2, 2, 0xfff1cc41);
				else
					particle.makeGraphic(2, 2, 0xff111111);
				particle.exists = false;
				emitter.add(particle);
			}
			
			add(emitter);
			emitter.start(true);
			emitters.push(emitter);
		}
		
		/**
		 * Sets the player to dead if conditions are met.
		 */		
		public function checkForDeath():void
		{
			if (player.alive && player.isTouching(FlxObject.UP) && player.isTouching(FlxObject.DOWN))
			{
				player.kill();		
				var mid:FlxPoint = player.getMidpoint();
				makeParticles(mid.x, mid.y, 0, 20);
			}
		}
		
		/** 
		 * Sets fullBoard to true if it is impossible to spawn new blocks.
		 */		
		public function checkForFull():void
		{
			if (blockStack.length < OCCUPIED_GRID.length) return;
			for (var i:uint = 0; i < OCCUPIED_GRID.length; i++)
			{
				if (OCCUPIED_GRID[i][0] == null)
				{
					for (var j:uint = 0; j < blockStack.length; j++)
					{
						if (!overlapsPos(blockStack.getBlock(j), i, 0))
							return;
					}
				}
			}
			fullBoard = true;
		}
		
		/**
		 * Updates the text representation of the current score, and updates both versions of the high score
		 */		
		public static function updateScores(justScored:uint = 0):void
		{
			score += justScored;
			
			var newScore:String = score.toString();
			while (newScore.length < 8) newScore = "0" + newScore;
			
			if (newScore != scoreText.text)
				scoreText.text = newScore;
			
			if (score > HighScore.highScore)
			{
				HighScore.highScore = score;
				highScoreText.text = newScore;
			}
			
		}
		
		
		public function displayGameOver():void
		{
			var greyScreen:FlxSprite = new FlxSprite(BOARD_GRID[0][0].x, BOARD_GRID[0][0].y);
			greyScreen.makeGraphic(BOARD_WIDTH_TILES * TILE_SIZE, BOARD_HEIGHT_TILES * TILE_SIZE, 0xff000000);
			greyScreen.alpha = 0.7;
			add(greyScreen);
			
			var gameOverText:FlxText = new FlxText(BOARD_GRID[0][0].x, BOARD_GRID[0][0].y + (BOARD_WIDTH_TILES * TILE_SIZE) / 2, BOARD_WIDTH_TILES * TILE_SIZE, "GAME OVER\n\n\nPRESS R TO RESTART\n\nOR ENTER FOR MENU");
			gameOverText.setFormat("PIXEL", 8, 0xffffffff, "center");
			add(gameOverText);

			
			gameOver = true;
		}
		
		public function isAlive(obj:FlxBasic, index:int, arr:Array):Boolean
		{
			return (obj.alive);
		}
			
		/** 
		 * Debug function. Prints OCCUPIED_GRID to the log.
		 */		
		public static function printGrid():void
		{
			for(var i:uint = 0; i < BOARD_HEIGHT_BLOCKS; i++)
			{
				var line:String = "";
				for(var j:uint = 0; j < BOARD_WIDTH_BLOCKS; j++)
				{
					if (OCCUPIED_GRID[j][i] == null) line += "0";
					else line += "1";
				}
				FlxG.log(line);
			}
		}
		
		/**
		 * Sorts the members array to place stacked blocks on top. 
		 */		
		public function bringStackedToFront():void
		{
			if (blockStack.isEmpty()) return;
			else
			{
				var block:Block;
				var index:int;
				for (var i:uint = 0; i < blockStack.length; i++)
				{
					block = blockStack.getBlock(i);
					index = members.indexOf(block);
					
					var basic:FlxBasic;
					var swapped:Boolean = false;
					for(var j:uint = length - 1; j > index && !swapped; j--) //swap with topmost member that's not a stacked block, if possible
					{
						basic = members[j];
						if (basic is Block)
						{
							if (!(basic as Block).isStacked())
								swap(members, index, j);
						}
					}
				}
			}
		}
		
		/**
		 * Simple swapping function used for sorting
		 */		
		public function swap(arr:Array, index1:uint, index2:uint):void
		{
			var temp:* = arr[index1];
			arr[index1] = arr[index2];
			arr[index2] = temp;
		}
	
	}
}