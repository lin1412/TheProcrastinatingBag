package {
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import starling.core.Starling;
	import starling.utils.RectangleUtil;
	
	//import flash.ui.Multitouch;
	//import flash.ui.MultitouchInputMode;
	
	/**
	 * ...
	 * @author FireAngelx
	 */
	public class Main extends Sprite 
	{
		private var _starling:Starling;
		
		public function Main():void 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			// touch or gesture?
			//Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			// entry point
			SetupStarling();
			
		}
		
		private function SetupStarling():void {
			// Create a new instance and pass our class and the stage
			var viewPort:Rectangle = RectangleUtil.fit(new Rectangle(0, 0, stage.stageWidth, stage.stageHeight), new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight), StageScaleMode.SHOW_ALL);
			_starling = new Starling(MyGameMain, stage, viewPort);
			
			// Show debug stats
			//_starling.showStats = true;
			
			// Define level of antialiasing, 
			_starling.antiAliasing = 1;
			
			_starling.start();
		}
		
		private function deactivate(e:Event):void 
		{
			// make sure the app behaves well (or exits) when in background
			NativeApplication.nativeApplication.exit();
		}
		
	}
	
}