package;

import flixel.FlxG;
import flixel.util.FlxSave;
import haxe.Json;

class Settings
{
	public static var initiated:Bool = false;

	public static var downscroll:Bool;
	public static var ghostTap:Bool;

	public static var graphicDetail:Int;
	public static var animDetail:Int;
	public static var antialiasing:Bool;

	public static var musicVolume:Float;
	public static var effectVolume:Float;
	public static var vocalVolume:Float;

	public static var saveSettings:FlxSave;

	public static function init():Void
	{
		saveSettings = new FlxSave();
		saveSettings.bind('FNFUM', 'platinum-engine');

		initiated = true;

		if (saveSettings.data.downscroll == null)
			saveSettings.data.downscroll = downscroll = false;

		if (saveSettings.data.ghostTap == null)
			saveSettings.data.ghostTap = ghostTap = false;

		if (saveSettings.data.graphicDetail == null)
			saveSettings.data.graphicDetail = graphicDetail = 2;

		if (saveSettings.data.animDetail == null)
			saveSettings.data.animDetail = animDetail = 2;

		if (saveSettings.data.antialiasing == null)
			saveSettings.data.antialiasing = antialiasing = true;

		if (saveSettings.data.musicVolume == null)
			saveSettings.data.musicVolume = musicVolume = 1;

		if (saveSettings.data.effectVolume == null)
			saveSettings.data.effectVolume = effectVolume = 1;

		if (saveSettings.data.vocalVolume == null)
			saveSettings.data.vocalVolume = vocalVolume = 1;

		downscroll = saveSettings.data.downscroll;
		ghostTap = saveSettings.data.ghostTap;
		graphicDetail = saveSettings.data.graphicDetail;
		animDetail = saveSettings.data.animDetail;
		antialiasing = saveSettings.data.antialiasing;
		musicVolume = saveSettings.data.musicVolume;
		effectVolume = saveSettings.data.effectVolume;
		vocalVolume = saveSettings.data.vocalVolume;

		dataMap = [
			[
				'downscroll',
				'ghostTap',
				'graphicDetail',
				'animDetail',
				'antialiasing',
				'musicVolume',
				'effectVolume',
				'vocalVolume'
			],
			[
				[saveSettings.data.downscroll, downscroll],
				[saveSettings.data.ghostTap, ghostTap],
				[saveSettings.data.graphicDetail, graphicDetail],
				[saveSettings.data.animDetail, animDetail],
				[saveSettings.data.antialiasing, antialiasing],
				[saveSettings.data.musicVolume, musicVolume],
				[saveSettings.data.effectVolume, effectVolume],
				[saveSettings.data.vocalVolume, vocalVolume]
			]
		];

		saveSettings.flush();
	}

	public static var dataMap:Array<Dynamic> = [];

	public static function saveData(data:String, value:Dynamic, flush:Bool = false)
	{
		if (!initiated)
			init();

		if (!flush)
		{
			if (data == null && value == null)
			{
				trace('null error');
				return;
			}

			// in case formatting is bad
			switch (value)
			{
				case 'on':
					value = true;
				case 'off':
					value = false;
			}

			// crap, old code does not work that way! do this instead and redo later!
			switch (data)
			{
				case 'downscroll':
					downscroll = value;
				case 'ghostTap' | 'ghost tap':
					ghostTap = value;
				case 'antialiasing':
					antialiasing = value;
				case 'graphic detail':
					graphicDetail = value;
				case 'animation detail' | 'animDetail':
					animDetail = value;
			}
		}
		else
		{
			saveSettings.data.downscroll = downscroll;
			saveSettings.data.ghostTap = ghostTap;
			saveSettings.data.antialiasing = antialiasing;
			saveSettings.data.graphicDetail = graphicDetail;
			saveSettings.data.animDetail = animDetail;
			saveSettings.data.musicVolume = musicVolume;
			saveSettings.data.effectVolume = effectVolume;
			saveSettings.data.vocalVolume = vocalVolume;

			saveSettings.flush();
		}
	}

	public static function fetchCurrentSelection(option:String, txt:Array<String>):Int
	{		
		trace(option);
		trace(txt);
		
		for (i in 0...txt.length)
		{
			var type:Int = -1;
			
			switch (txt[i])
			{
				case 'low' | 'static':
					txt[i] = '0';
					type = 0;
				case 'normal' | 'partial':
					txt[i] = '1';
					type = 0;
				case 'high' | 'full':
					txt[i] = '2';
					type = 0;
			}

			var formatted:Dynamic = null;

			if (type != -1)
			{
				switch (type)
				{
					case 0:
					{
						formatted = Std.parseInt(txt[i]);
					}
				}
			}
			else
			{
				formatted = txt;
			}

			switch (option.toLowerCase())
			{
				case 'downscroll':
				{
					if (formatted == saveSettings.data.downscroll)
						return i;
				}
				case 'ghost tap' | 'ghosttap':
				{
					if (formatted == saveSettings.data.ghostTap)
						return i;
				}
				case 'antialiasing':
				{
					if (formatted == saveSettings.data.antialiasing)
						return i;
				}
				case 'graphic detail' | 'graphicdetail':
				{
					if (formatted == saveSettings.data.graphicDetail)
						return i;
				}
				case 'animation detail' | 'animdetail':
				{
					if (formatted == saveSettings.data.animDetail)
						return i;
				}
			}
		}
		return 0;
	}
}
