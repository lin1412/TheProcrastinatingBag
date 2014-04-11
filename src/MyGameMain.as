package {
	import adobe.utils.CustomActions;
    import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
    import starling.display.Image;
    import starling.display.Quad;
    import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
    import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchPhase;
	import starling.text.TextField;
    import starling.textures.Texture;
	import starling.events.TouchEvent;



    public class MyGameMain extends Sprite {
		public static var sharedObject:SharedObject;
		public static const DATA_SHARED_OBJECT:String = "dataSharedObject";
		
		
        [Embed(source = "lib.png")]
		private static const MyLibClass:Class;
		private var _libImage:Image;
		private var _libImage2:Image;
		
		[Embed(source="startButton.png")]
        private static const MyStartClass:Class;
        private var _startImage:Image;
		
		[Embed(source="msg.png")]
        private static const MyMsgClass:Class;
        private var _msgImage:Image;
		
        [Embed(source="backPack1.png")]
        private static const MyPlayerClass:Class;
        private var _playerImage:Image;
		
		[Embed(source="backPack2.png")]
        private static const MyPlayerLostClass:Class;
        private var _playerLostImage:Image;
		
		[Embed(source = "notebook.png")]
		private static const MyNoteClass:Class;
        private var _noteImage:Image;
		
		[Embed(source="textbook.png")]
		private static const MyTextClass:Class;
        private var _textImage:Image;
		
		private var guide:TextField;
		private var timeLapse:TextField;
		private var highScore:TextField;
		private var highScoreS:TextField;
		private var hS:int;

		private var lvNum:int;
		private var teleport: Boolean;
		private var teleportNum: int;
		private var frame:int;
		private var timer:Number;
		private var seconds:int;
		private var lost:Boolean;
		private var hitBox:Rectangle;
		private var noteArray:Vector.<Image>;
		private var textArray:Vector.<Image>;
		private var speedArray:Vector.<int>;
         
        public function MyGameMain() {
            super();
            
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            
        }
		public static function save(string:String, value:*):void {
			sharedObject = SharedObject.getLocal(DATA_SHARED_OBJECT);
			sharedObject.data[string] = (value);
			sharedObject.flush();
		}
		
		 public static function load(string:String):* {
			sharedObject = SharedObject.getLocal(DATA_SHARED_OBJECT);
			return sharedObject.data[string];
		}
        
        private function onAddedToStage(e:Event):void {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			addBG();
			
			//add guide
			//var string:String = "Guide the backpack to avoid the books and keep procrastinating for as long as possible.";
			guide = new TextField(600, 200, "Guide the backpack to avoid the books/borders and keep procrastinating for as long as possible.", "Verdana", 20, 0xF50000, true);
			guide.x = stage.stageWidth / 2 - 300;
			guide.y = stage.stageHeight - 150;
			addChild(guide);
			
			//add timers to stage
			timeLapse = new TextField(300, 50, "Time Procrastinated:", "Verdana", 20, 0xFFFFFF, true);
			timeLapse.x = stage.stageWidth / 2 - 150;
			timeLapse.y = 5;
			addChild(timeLapse);
			
			highScore = new TextField(250, 30, "Longest Time Procrastinated:", "Verdana", 15, 0xF50000, true);
			highScore.x = stage.stageWidth - 250;
			highScore.y = 5;
			addChild(highScore);
			
			hS = load("highScore");
			if (isNaN(hS)) {
				save("highScore", 0);
				hS = 0;
			}
            highScoreS = new TextField(30, 30, String(hS), "Verdana", 15, 0xF50000, true);
			highScoreS.x = stage.stageWidth - 50;
			highScoreS.y = 35;
			addChild(highScoreS);
			
			//add players
            var myBitmap:Bitmap = new MyPlayerClass();
            _playerImage = Image.fromBitmap(myBitmap);
       
            // Change images origin to it's center
            // (Otherwise by default it's top left)
            _playerImage.pivotX = _playerImage.width / 2;
            _playerImage.pivotY = _playerImage.height / 2;
            // Where to place the image on screen
            _playerImage.x = stage.stageWidth / 2;
            _playerImage.y = stage.stageHeight / 2;
            
            // Add image to display in order to show it
            addChild(_playerImage);
			
			//make the losing image
			var myBitmap2:Bitmap = new MyPlayerLostClass();
            _playerLostImage = Image.fromBitmap(myBitmap2);
			_playerLostImage.x = stage.stageWidth / 2;
            _playerLostImage.y = stage.stageHeight - _playerImage.height;
			addChild(_playerLostImage);
			_playerLostImage.visible = false;
			
			//add the msg after losing
			var myMsgBitmap:Bitmap = new MyMsgClass();
            _msgImage = Image.fromBitmap(myMsgBitmap);
			_msgImage.x = stage.stageWidth / 2;
            _msgImage.y = stage.stageHeight - _playerImage.height -  _msgImage.height;
			addChild(_msgImage);
			_msgImage.visible = false;
			
			//add the start button
			var myStartBitmap:Bitmap = new MyStartClass();
            _startImage = Image.fromBitmap(myStartBitmap);
			_startImage.x = stage.stageWidth / 2 - _startImage.width/2;
			_startImage.y = stage.stageHeight / 2 - _startImage.height / 2;
			_startImage.addEventListener(TouchEvent.TOUCH, onStartButtonClick);
			addChild(_startImage);
			
			
        }
		
		private function onStartButtonClick(event:TouchEvent):void
		{
			var touchB:Touch = event.getTouch(this, TouchPhase.BEGAN);
			if (touchB) {
				
				_startImage.visible = false;
				removeEventListener(TouchEvent.TOUCH, onStartButtonClick);
				addBG();
				setUp();
				guide.visible = false;
				addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
			}
		}
		private function addBG():void {
			//1st time
			if (_libImage == null || _libImage2 == null) {
				//background
				var myBGBitmap:Bitmap = new MyLibClass();6
				_libImage = Image.fromBitmap(myBGBitmap);
				addChild(_libImage);
				_libImage2 = Image.fromBitmap(myBGBitmap);
				_libImage2.x = 854;
				addChild(_libImage2);
			}
			//reset bg
			else{
				_libImage.x = 0;
				_libImage2.x = 854;
			}
			
		}
        
        private function setUp():void {  
			//init
			this.addEventListener(TouchEvent.TOUCH, onTouch);
			lvNum = 1;
			teleport = false;
			teleportNum = 0;
			frame = 0;
			timer = 0;
			lost = false;
			hitBox = new Rectangle(_playerImage.x - _playerImage.width/2, _playerImage.y - _playerImage.height/2, _playerImage.width - 4, _playerImage.width - 4);
			noteArray = new Vector.<Image>();
			textArray = new Vector.<Image>();
			speedArray = new Vector.<int>();
			
			_playerLostImage.visible = false;
			_msgImage.visible = false;
			_playerImage.x = stage.stageWidth / 2;
            _playerImage.y = stage.stageHeight / 2;
			_playerImage.visible = true;
			
						
			//set up object speeds
			speedArray.push(3);
			speedArray.push(3.5);
			speedArray.push(4);
			speedArray.push(4.5);
			speedArray.push(5);
			

			addObject(lvNum);
			
        }
		
		private function onTouch(event:TouchEvent):void {
			var touchB:Touch = event.getTouch(this, TouchPhase.BEGAN);
			var touchM:Touch = event.getTouch(this, TouchPhase.MOVED);
			if( (touchB || touchM) && !teleport){
				_playerImage.x -= (_playerImage.x - event.getTouch(stage).globalX + 40) * .3;
				_playerImage.y -= (_playerImage.y - event.getTouch(stage).globalY) * .3;
			}
			else if (touchB && teleport) {
				_playerImage.x = event.getTouch(stage).globalX - 40;
				_playerImage.y = event.getTouch(stage).globalY;
			}
			//left
			if (_playerImage.x < _playerImage.width / 2 - 2 ) {
				lose();
			}
			//right
			if (_playerImage.x > stage.stageWidth - (_playerImage.width / 2) + 2) {
				lose();
			}
			//top
			if (_playerImage.y < _playerImage.height / 2 - 2) {
				lose();
			}
			//bottom
			if (_playerImage.y > stage.stageHeight - (_playerImage.height / 2) + 2) {
				lose();
			}
			
		}
		
		private function lose():void {
			//change player image and bring up start menu after pausing game
			lost = true;
			_playerImage.visible = false;
			removeEventListener(TouchEvent.TOUCH, onTouch)
			_playerLostImage.x = _playerImage.x;
			_playerLostImage.visible = true;
			_msgImage.x = _playerImage.x
			_msgImage.visible = true;
			
			_startImage.visible = true;
			_startImage.addEventListener(TouchEvent.TOUCH, onStartButtonClick);
			setChildIndex(_startImage, numChildren - 1);
			
			for ( var i:int = 0; i < noteArray.length; i++) {
				removeChild(noteArray[i]);
				removeChild(textArray[i]);
			}
			noteArray = null;
			textArray = null;
			
			//update high score and save
			if (seconds > int(highScoreS.text)) {
				highScoreS.text = "" + seconds;
				hS = seconds;
				save("highScore", seconds);
			}
			
		}
		
		private function addObject(lv: int):void {
			var addMore:int = (lv * 7) - noteArray.length;
			//add objects
			for ( var i:int = 0; i < addMore; i++) {
				//add can
				var myNoteBitmap:Bitmap = new MyNoteClass();
				_noteImage = Image.fromBitmap(myNoteBitmap);
				_noteImage.pivotX = _noteImage.width / 2;
				_noteImage.pivotY = _noteImage.height / 2;
				_noteImage.y = 50 + Math.random() * 400;
				_noteImage.x = (Math.random() * -900) + (Math.random() * -900);
				addChild(_noteImage);
				noteArray.push(_noteImage);
				
				//add bottle
				var myTextBitmap:Bitmap = new MyTextClass();
				_textImage = Image.fromBitmap(myTextBitmap);
				_textImage.pivotX = _textImage.width / 2;
				_textImage.pivotY = _textImage.height / 2;
				_textImage.y = 50 + Math.random() * 400;
				_textImage.x = (Math.random() * -900) + (Math.random() * -900);
				addChild(_textImage);
				textArray.push(_textImage);
			}
			setChildIndex(timeLapse, numChildren - 1);
			setChildIndex(highScore, numChildren - 1);
			setChildIndex(highScoreS, numChildren - 1);
		}
        
        private function onEnterFrame(e:EnterFrameEvent):void {
			
			if (!lost) {
				
				//update timer
				frame++;
				timer += e.passedTime;
				seconds = int(timer * 1 );
				timeLapse.text = "Time Procrastinated: " + seconds + " seconds";
				
			
				// moves background
				_libImage.x += -1;
				_libImage2.x += -1;
			
				if (_libImage.x <= -854) {
					_libImage.x = _libImage2.x + 854;
				}
				if (_libImage2.x <= -854) {
					_libImage2.x = _libImage.x + 854;
				}
			
				//hit collision and object movement
				for ( var i:int = 0; i < noteArray.length; i++) {
					hitBox.x = _playerImage.x - _playerImage.width/2;
					hitBox.y = _playerImage.y - _playerImage.height/2;
					if ( (noteArray[i].bounds.intersects(hitBox)) || (textArray[i].bounds.intersects(hitBox))) {
						lose();
						break;
					}
					
					noteArray[i].x += speedArray[i%5] * 45 *e.passedTime;
					noteArray[i].rotation += .07;
					
					textArray[i].x += speedArray[i%5] * 45 *e.passedTime;
					textArray[i].rotation += .09;
					
					//if they did their job, reset them
					if ( noteArray[i].x >= 860 ) {
						noteArray[i].y = 50 + Math.random() * 400;
						noteArray[i].x = (Math.random() * -900) + (Math.random() * -900);
					}
					if ( textArray[i].x >= 860 ) {
						textArray[i].y = 50 + Math.random() * 400;
						textArray[i].x = (Math.random() * -900) + (Math.random() * -900);
					}
				}
			
				//add more objects
				if ( frame >= 1800 ) {
					frame = 0;
					lvNum++;
					//addObject(lvNum);
				}
			}
		}
	}
}
