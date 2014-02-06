package flixel.addons.ui;

import flixel.addons.ui.FlxUI.NamedString;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IResizable;

/**
 * @author Lars Doucet
 */
class FlxUIInputText extends FlxInputText implements IResizable implements IFlxUIWidget
{
	public var id:String;
	public var uiEventCallback:String->Dynamic->Dynamic->Void;
	
	public static inline var CHANGE_EVENT:String = "change_input_text";		//change in any way
	public static inline var ENTER_EVENT:String = "enter_input_text";		//hit enter in this text field
	public static inline var INPUT_EVENT:String = "input_input_text";		//input text in this text field
	
	public function resize(w:Float, h:Float):Void {
		width = w;
		height = h;
		calcFrame();
	}
	
	public function forceCalcFrame():Void {
		calcFrame();
	}
	
	private override function onChange(action:String):Void {
		super.onChange(action);
		if (uiEventCallback != null) {
			switch(action) {
				case ENTER_ACTION:										//press enter
					uiEventCallback(ENTER_EVENT, this, text);
				case DELETE_ACTION, BACKSPACE_ACTION:					//deleted some text
					uiEventCallback(DELETE_EVENT, this, text);
					uiEventCallback(CHANGE_EVENT, this, text);
				case INPUT_ACTION:										//text was input
					uiEventCallback(INPUT_EVENT, this, text);
					uiEventCallback(CHANGE_EVENT, this, text);
			}
		}
	}
}