package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.system.FlxSound;

using StringTools;

class SettingsGraphics extends MusicBeatState
{
	var curOptions:Array<String> = ['graphics settings', 'graphic presets', 'antialiasing'];
	// note to self: null values should not be changed
	var changeableValues:Array<Dynamic> = [null, FlxG.save.data.quality, FlxG.save.data.antialiasing];
	var defaultValues:Array<Dynamic> = [null, 'medium', true];

	var curSelected:Int = 0;
	var grpItems:FlxTypedGroup<Alphabet>;

	var coolString:String = '';
	var dumbBitch:FlxText;

	var valueText:FlxText;
	var stringOfBool:String = '';

	override function create()
	{
		// Assuming settings wasn't initalized yet
		Settings.init();

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		menuBG.color = 0xFF5EBCFF;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		var bottomBG:FlxSprite = new FlxSprite(0, FlxG.height * 0.9).makeGraphic(Std.int(FlxG.width), Std.int(FlxG.height * 0.04), FlxColor.BLACK);
		bottomBG.alpha = 0.6;
		bottomBG.antialiasing = true;
		bottomBG.y = FlxG.height - bottomBG.height;

		dumbBitch = new FlxText(4, bottomBG.y, FlxG.width, "", Std.int(bottomBG.height - 2));
		dumbBitch.setFormat("assets/fonts/vcr.ttf", Std.int(bottomBG.height - 2), FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE,
			FlxColor.BLACK);

		valueText = new FlxText(FlxG.width * 0.8, dumbBitch.y - 36, 0, 32);
		valueText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		grpItems = new FlxTypedGroup<Alphabet>();
		add(grpItems);

		for (i in 0...curOptions.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, curOptions[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpItems.add(songText);
		}

		add(bottomBG);
		add(dumbBitch);

		add(valueText);

		super.create();
	}

	function changeSelection(change:Int = 0)
	{
		var realChange:Int = curSelected + change;

		if (curSelected != 0)
		{
			if (FlxG.save.data.soundVolume > 0.4)
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			else
				FlxG.sound.play(Paths.sound('scrollMenu'), FlxG.save.data.soundVolume);
		}

		curSelected += change;

		valueText.y -= 36;

		if (realChange == 0)
			curSelected = curOptions.length;
		if (curSelected >= curOptions.length)
			curSelected = 1;

		trace(curSelected + ", " + realChange);

		var bullShit:Int = 0;

		for (item in grpItems.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			switch (curSelected)
			{
				case 1:
					coolString = "Sets the quality of playing the game, higher is better but more performance-heavy.";
				case 2:
					coolString = "Smoothens jagged edges on curved lines or diagonals.";
			}

			if (item.text != 'graphics settings')
			{
				item.alpha = 0.6;
				item.selected = false;
			}

			if (item.targetY == 0)
			{
				item.selected = true;
				item.alpha = 1;
			}
		}
	}

	function changeItem(item:Dynamic, selected:Int, isOffset:Bool = false, dir:Bool = false)
	{
		if (item == null)
			changeableValues[selected] = defaultValues[selected];

		if ((item is Bool))
			item = !item;
		if ((item is String))
		{
			if (selected == 1)
			{
				if (item == 'low')
					item = 'medium';
				else if (item == 'medium')
					item = 'high';
				else if (item == 'high')
					item = 'low';
			}
		}

		trace(item);

		changeableValues[selected] = item;
		trace(changeableValues);

		saveSettings(selected);
	}

	function saveSettings(selected:Int)
	{
		var valueString:String = '';

		switch (selected)
		{
			case 1:
				valueString = 'quality';
			case 2:
				valueString = 'antialiasing';
		}

		Settings.save(changeableValues[selected], valueString);
	}

	var wasNotWarn:Bool = false;
	var fadeTime:Float = 0;
	var warningText:FlxText;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (wasNotWarn)
			fadeTime += elapsed * 10;

		var someString:String = changeableValues[curSelected];

		if ((changeableValues[curSelected] is Float))
			someString = "< " + changeableValues[curSelected] + " >";

		if (fadeTime > 30)
			warningText.alpha -= elapsed * 10;

		valueText.y = Math.floor(FlxMath.lerp(valueText.y, FlxG.height * 0.8, 0.2));

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;
		var rightP = controls.RIGHT_P;
		var accepted = controls.ACCEPT;
		var back = controls.BACK;

		dumbBitch.text = coolString;
		if (someString.startsWith('false'))
			someString = 'off';
		else if (someString.startsWith('true'))
			someString = 'on';

		valueText.text = someString.toUpperCase();

		if (curSelected == 0)
			changeSelection(1);

		if (upP)
		{
			changeSelection(-1);
		}

		if (downP)
		{
			changeSelection(1);
		}

		if (leftP)
		{
			changeItem(changeableValues[curSelected], curSelected, true, false);
		}

		if (rightP)
		{
			changeItem(changeableValues[curSelected], curSelected, true, true);
		}

		if (back)
			FlxG.switchState(new SettingsMenu());

		if (accepted)
		{
			changeItem(changeableValues[curSelected], curSelected);
			if (curSelected == 5)
				FlxG.switchState(new LatencyState());
		}
	}
}
