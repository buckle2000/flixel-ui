package flixel.addons.ui;

import flixel.addons.ui.FlxUI.NamedBool;
import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.addons.ui.interfaces.IHasParams;
import flixel.addons.ui.interfaces.ILabeled;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxTimer;

/**
 * @author Lars Doucet
 */
class FlxUICheckBox extends FlxUIGroup implements ILabeled implements IFlxUIButton implements IHasParams
{
	public var box:FlxSprite;
	public var mark:FlxSprite;
	public var button:FlxUIButton;
	public var max_width:Float = -1;
	
	public var checked(default, set):Bool = false;
	public var params(default, set):Array<Dynamic>;
	
	//Set this to false if you just want the checkbox itself to be clickable
	public var textIsClickable:Bool = true;
	
	public var checkbox_dirty:Bool = false;
	
	public var textX(default, set):Float = 0;
	public var textY(default, set):Float = 0;
	
	public var box_space:Float = 2;
	
	public var skipButtonUpdate(default, set):Bool = false;
	
	public static inline var CLICK_EVENT:String = "click_check_box";
	
	public function set_skipButtonUpdate(b:Bool):Bool {
		skipButtonUpdate = b;
		button.skipButtonUpdate = skipButtonUpdate;
		return skipButtonUpdate;
	}
	public function set_params(p:Array <Dynamic>):Array<Dynamic>{
		params = p;
		if (params == null) 
		{ 
			params = [];
		}
		var nb:NamedBool = { name:"checked", value:false };
		params.push(nb);
		return params;
	}
	
	
	public function new(X:Float = 0, Y:Float = 0, ?Box:Dynamic, ?Check:Dynamic, ?Label:String, LabelW:Int=100, ?Params:Array<Dynamic>)
	{
		super();
		
		params = Params;
		
		box = new FlxSprite();
		if (Box == null) {
			//if null create a simple checkbox outline
			Box = FlxUIAssets.IMG_CHECK_BOX;
		}
		
		box.loadGraphic(Box, true, false);
		
		button = new FlxUIButton(0, 0, Label, _clickCheck);
		
		//set default checkbox label format
		button.label.setFormat(null, 8, 0xffffff, "left", FlxText.BORDER_OUTLINE);
		button.up_color = 0xffffff;
		button.down_color = 0xffffff;
		button.over_color = 0xffffff;
		button.up_toggle_color = 0xffffff;
		button.down_toggle_color = 0xffffff;
		button.over_toggle_color = 0xffffff;
		
		//TODO:
		//the +2 is a magic number, possibly should be a user-set parameter
		button.loadGraphicSlice9(["", "", ""], Std.int(box.width + 2 + LabelW), Std.int(box.height));
		
		max_width = Std.int(box.width + box_space + LabelW);
		
		button.onUp.callback = _clickCheck;    //for internal use, check/uncheck box, bubbles up to _externalCallback
				
		mark = new FlxSprite();
		if (Check == null) {
			//if null load from default assets:
			Check = FlxUIAssets.IMG_CHECK_MARK;
		}		
		
		mark.loadGraphic(Check);
		
		add(box);
		add(mark);
		add(button);
		
		anchorLabelX();
		anchorLabelY();
		
		checked = false;
		
		//set all these to 0
		button.labelOffsets[FlxButton.NORMAL].x = 0;
		button.labelOffsets[FlxButton.NORMAL].y = 0;
		button.labelOffsets[FlxButton.PRESSED].x = 0;
		button.labelOffsets[FlxButton.PRESSED].y = 0;
		button.labelOffsets[FlxButton.HIGHLIGHT].x = 0;
		button.labelOffsets[FlxButton.HIGHLIGHT].y = 0;
		
		x = X;
		y = Y;
		
		textX = 0;
		textY = 0;	//forces anchorLabel() to be called and upate correctly
	}
	
	/**For ILabeled:**/
	
	public function set_label(t:FlxUIText):FlxUIText { if (button == null) { return null;} button.label = t; return button.label; }
	public function get_label():FlxUIText { if (button == null) { return null;} return button.label; }
	
	/**/
	
	private override function set_visible(Value:Bool):Bool
	{
		//don't cascade to my members
		visible = Value;
		return visible;
	}
	
	private function anchorTime(f:FlxTimer):Void {
		anchorLabelY();
	}
	
	public function set_textX(n:Float):Float {
		textX = n;
		anchorLabelX();
		return textX;
	}
	
	public function set_textY(n:Float):Float {
		textY = n;
		anchorLabelY();
		return textY;
	}
	
	public function anchorLabelX():Void {
		if (button != null) {
			button.label.offset.x = -((box.width + box_space) + textX);
		}
	}
	
	public function anchorLabelY():Void{
		if (button != null) {
			button.y = box.y + (box.height - button.height) / 2 + textY;
		}
	}
	
	public override function destroy():Void 
	{
		super.destroy();
		if (mark != null) {
			mark.destroy();
			mark= null;
		}
		if (box != null) {
			box.destroy();
			box = null;
		}
		if (button != null) {
			button.destroy();
			button = null;
		}
	}
	
	public var text(get, set):String;
	public function get_text():String { return button.label.text;}
	public function set_text(value:String):String
	{
		button.label.text = value;
		checkbox_dirty = true;
		return value;
	}
	
	public override function update():Void{
		super.update();
		
		if (checkbox_dirty) {
			if (button.label != null) {
				if (Std.is(button.label, FlxUIText)) {
					var ftu:FlxUIText = cast button.label;
					ftu.drawFrame(); //force update
				}
				anchorLabelX();
				anchorLabelY();
				button.width = box.frameWidth + button.label.textField.textWidth + (button.label.x - (button.x + box.frameWidth));
				checkbox_dirty = false;
			}
		}
	}
		
	/*****GETTER/SETTER***/
	
	public function set_checked(b:Bool):Bool { 
		mark.visible = b; 
		return checked = b; 
	}
	
	/*****PRIVATE******/
	
	private function _clickCheck():Void 
	{
		checked = !checked;
		if (uiEventCallback == null) {
			return;
		}
		
		var nb:NamedBool = cast params[params.length - 1];
		nb.value = checked;
		
		uiEventCallback(CLICK_EVENT, this, params);
	}
	
}