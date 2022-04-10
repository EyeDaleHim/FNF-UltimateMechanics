package;

import flash.geom.Matrix;
import flash.geom.Point;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.util.FlxGradient;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.input.mouse.FlxMouseEventManager;
import openfl.filters.BlurFilter;

using StringTools;

class SettingsSubstate extends MusicBeatSubstate
{
	var options:Array<String> = ['options' /*, 'credits', 'changelog'*/];
	var optionsSub:Array<String> = ['gameplay', 'graphics', /*'audio',*/ 'back'];

	var gameplayCategory:Array<String> = ['downscroll', 'ghost tap', /*'controls',*/ 'back'];
	var graphicsCategory:Array<String> = ['graphic detail', 'animation detail', 'antialiasing', 'back'];
	var audioCategory:Array<String> = ['music', 'vocals', 'effects', 'test audio', 'back'];

	var currentCategory:String = 'default';

	var currentOptionsTxt:FlxTypedGroup<Alphabet>;
	var currentOptions:Array<Dynamic> = [];
	var audioTxt:FlxTypedGroup<AudioText>;
	var selectedOptionText:String = '';

	var background:FlxSprite;

	var lastSelections:FlxTypedGroup<Alphabet>;
	var selectables:FlxTypedGroup<Alphabet>;

	var cursor:FlxSprite;

	var descriptionTxt:FlxText;

	var arrow:FlxSprite;

	var isSelectingOption:Bool = false;

	override public function new()
	{
		super();

		background = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		background.scrollFactor.set();
		background.alpha = 0.5;
		background.updateHitbox();
		background.antialiasing = true;
		background.x = FlxG.width;
		add(background);

		lastSelections = new FlxTypedGroup<Alphabet>();
		add(lastSelections);

		selectables = new FlxTypedGroup<Alphabet>();
		add(selectables);

		addOptions();

		FlxTween.tween(background, {x: 0}, 1.1, {ease: FlxEase.quadOut});

		arrow = new FlxSprite(offset[0], offset[1]).loadGraphic(Paths.image('settingsArrow'));
		arrow.scrollFactor.set();
		arrow.antialiasing = true;
		arrow.updateHitbox();
		arrow.alpha = 0;
		add(arrow);

		currentOptionsTxt = new FlxTypedGroup<Alphabet>();
		add(currentOptionsTxt);

		audioTxt = new FlxTypedGroup<AudioText>();
		add(audioTxt);

		descriptionTxt = new FlxText(6, FlxG.height * 0.8, 0, "", 24);
		descriptionTxt.scrollFactor.set();
		descriptionTxt.antialiasing = true;
		descriptionTxt.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		add(descriptionTxt);

		cursor = new FlxSprite(-120, -120).loadGraphic(Paths.image('cursor', 'shared'));
		cursor.scrollFactor.set();
		cursor.antialiasing = true;
		add(cursor);

		#if debug
		var debug = true;
		#else
		var debug = false;
		#end

		if (FlxG.save.data.firstTimeInSettings == null || !FlxG.save.data.firstTimeInSettings || debug == true)
		{
			FlxG.save.data.firstTimeInSettings = true;
			FlxG.save.flush();

			var firstTxt:FlxText = new FlxText();
			firstTxt.setFormat(Paths.font("vcr", "ttf"), 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
			firstTxt.antialiasing = true;
			firstTxt.scrollFactor.set();
			firstTxt.text = 'Use the cursor to cycle through categories.\nUse the arrow keys to cycle through options.\n';
			firstTxt.screenCenter();
			firstTxt.y = FlxG.height * 0.1;
			firstTxt.alpha = 0;
			add(firstTxt);
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxTween.tween(firstTxt, {alpha: 1}, 0.35, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						FlxTween.tween(firstTxt, {alpha: 0}, 1.75, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								remove(firstTxt);
								firstTxt.destroy();
							},
							startDelay: 2.5
						});
					}
				});
			});
		}
	}

	var selectedOption:Int = 0;
	var offset:Array<Float> = [830, 570];
	var showOffset:Bool = false;
	var mouseCooldown:Int = 350;

	// for some reason it saves IF YOU DONT DO ANYTHING SO DO THIS
	var keyInput:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		currentOptionsTxt.forEachAlive(function(spr:Alphabet)
		{
			var scaledY = FlxMath.remapToRange(spr.ID - selectedOption, 0, 1, 0, 1.7);

			/* math
				spr.y = FlxMath.lerp(spr.y, (offset[1] + FlxMath.remapToRange(Math.abs(spr.ID - selectedOption), 0, 1, 0, 1.3) * 120) + (FlxG.height * 0.48), 0.16 * (60 / Main.framerate));
				spr.x = FlxMath.lerp(spr.x, (offset[0] + spr.ID * Math.pow(20, Math.abs(spr.ID - selectedOption))), 0.16 * (60 / Main.framerate));
			 */
			spr.x = FlxMath.lerp(spr.x, arrow.x + arrow.width + 4 + (Math.exp(scaledY * 0.8) * 20), 0.16 * (60 / Main.framerate));
			if (scaledY < 0)
				spr.x = FlxMath.lerp(spr.x, arrow.x + arrow.width + 4 + (Math.exp(scaledY * -0.8) * 20), 0.16 * (60 / Main.framerate));

			spr.y = FlxMath.lerp(spr.y, arrow.y + 4 - (arrow.height / 2) * ((scaledY * 0.7) * 3.5), 0.16 * (60 / Main.framerate));
		});

		arrow.x = offset[0];
		arrow.y = offset[1];

		if (controls.DOWN_P)
		{
			selectOption(-1);
		}
		else if (controls.UP_P)
		{
			selectOption(1);
		}

		cursor.setPosition(FlxG.mouse.getScreenPosition().x, FlxG.mouse.getScreenPosition().y);

		if (controls.BACK)
		{
			FlxTween.tween(background, {alpha: 0}, 0.7, {
				ease: FlxEase.quartOut,
				onComplete: function(twn:FlxTween)
				{
					MainMenuState.inOptionsState = false;
					close();
				}
			});

			Settings.saveData(null, null, true);

			FlxTween.cancelTweensOf(arrow);
			FlxTween.tween(arrow, {alpha: 0}, 0.45, {ease: FlxEase.quartOut});

			currentOptionsTxt.forEachAlive(function(spr:Alphabet)
			{
				FlxTween.cancelTweensOf(spr);
				FlxTween.tween(spr, {alpha: 0}, 0.45, {ease: FlxEase.quartOut, startDelay: 0.05 * (currentOptionsTxt.members.indexOf(spr))});
			});

			selectables.forEachAlive(function(spr:Alphabet)
			{
				FlxTween.cancelTweensOf(spr);
				FlxTween.tween(spr, {alpha: 0}, 0.45, {ease: FlxEase.quartOut, startDelay: 0.05 * (selectables.members.indexOf(spr))});
			});
		}
	}

	var curSelected:Int = 0;

	var description:Map<String, String> = [
		'downscroll' => 'Changes the vertical position of where the notes will go',
		'ghost tap' => 'Allow tapping with no punishments when there are no hittable notes',
		'controls' => 'Set your Controls to your preferences',
		'graphic detail' => 'How much details should be in the background',
		'animation detail' => 'Whether sprites should be animated based on its setting',
		'antialiasing' => 'Smoothens out jaggered lines',
		'music' => 'Control the background music and the music in-game',
		'vocals' => 'Control the vocals in-game',
		'effects' => 'Control the sound effects in-game and the menu',
		'test audio' => 'Is your audio working? Test your audio!',
		'debug mode' => 'Enable the use of Charting Menus.'
	];

	function addOptions(optionList:Array<String> = null):Void
	{
		if (optionList == null)
		{
			curSelected = -1;

			selectables.forEachAlive(function(spr:Alphabet)
			{
				selectables.remove(spr);
				FlxMouseEventManager.remove(spr);
			});

			for (i in 0...options.length)
			{
				var optionTxt:Alphabet = new Alphabet(0, 0, options[i], true, false);
				optionTxt.scrollFactor.set();
				optionTxt.antialiasing = true;
				optionTxt.alpha = 0;
				optionTxt.screenCenter();
				optionTxt.y += (100 * (i - (options.length / 2))) + 50;
				selectables.add(optionTxt);

				var doneTweening:Bool = false;

				FlxMouseEventManager.add(optionTxt, function(spr:Alphabet)
				{
					switch (optionTxt.text)
					{
						case 'options':
							{
								addOptions(optionsSub);
								currentCategory = 'categorySub';
								currentOptionsTxt.clear();
							}
						case 'gameplay':
							{
								addOptions(gameplayCategory);
								currentCategory = optionsSub[i];
								FlxTween.cancelTweensOf(arrow);
								FlxTween.tween(arrow, {alpha: 1}, 0.45, {ease: FlxEase.quadOut});
							}
						case 'graphics':
							{
								addOptions(graphicsCategory);
								currentCategory = optionsSub[i];
								FlxTween.cancelTweensOf(arrow);
								FlxTween.tween(arrow, {alpha: 1}, 0.45, {ease: FlxEase.quadOut});
							}
						case 'audio':
							{
								addOptions(audioCategory);
								currentCategory = optionsSub[i];
							}
						case 'back':
							{
								Settings.saveData(null, null, true);
								if (currentCategory == 'categorySub')
									addOptions();
								else
									addOptions(optionsSub);
								currentCategory = 'default';
								FlxTween.cancelTweensOf(arrow);
								FlxTween.tween(arrow, {alpha: 0}, 0.45, {ease: FlxEase.quadOut});
								currentOptionsTxt.clear();
							}
					}
				}, null, function(spr:Alphabet)
				{
					if (doneTweening)
						optionTxt.alpha = 1;

					curSelected = i;
				}, function(spr:Alphabet)
				{
					if (doneTweening)
						optionTxt.alpha = 0.6;

					curSelected = i;
				});

				FlxTween.tween(optionTxt, {alpha: 0.6}, 0.6, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						doneTweening = true;
						if (i == curSelected)
						{
							optionTxt.alpha = 1;
							if (description.exists(optionTxt.text))
								descriptionTxt.text = description.get(optionTxt.text);
							else
								descriptionTxt.text = '';
						}
					},
					startDelay: 0.3 + (0.1 * i)
				});
			}
		}
		else
		{
			curSelected = -1;

			selectables.forEachAlive(function(spr:Alphabet)
			{
				selectables.remove(spr);

				FlxMouseEventManager.remove(spr);
			});

			audioTxt.forEachAlive(function(txt:AudioText)
			{
				audioTxt.remove(txt);
			});

			for (i in 0...optionList.length)
			{
				var optionTxt:Alphabet = new Alphabet(0, 0, optionList[i], true, false);
				optionTxt.scrollFactor.set();
				optionTxt.antialiasing = true;
				optionTxt.alpha = 0;
				optionTxt.screenCenter();
				optionTxt.y += (100 * (i - (optionList.length / 2))) + 50;
				if (currentCategory == 'audio')
				{
					if (optionList[i] != 'test audio' && optionList[i] != 'back')
					{
						optionTxt.x -= 190;
						var attachableTxt:AudioText = new AudioText(optionTxt.x + 40, optionTxt.getGraphicMidpoint().y, 0, "0%", 24, false);
						attachableTxt.setFormat(Paths.font('vcr', 'ttf'), 24, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
						attachableTxt.sprTracker = optionTxt;
						audioTxt.add(attachableTxt);
					}
				}
				selectables.add(optionTxt);

				var doneTweening:Bool = false;

				FlxMouseEventManager.add(optionTxt, function(spr:Alphabet)
				{
					if (selectedOptionText == optionTxt.text)
						return;

					switch (optionTxt.text)
					{
						case 'options':
							{
								addOptions(optionsSub);
								currentCategory = 'categorySub';
								currentOptionsTxt.clear();
							}
						case 'gameplay':
							{
								addOptions(gameplayCategory);
								currentCategory = optionsSub[i];
								FlxTween.cancelTweensOf(arrow);
								FlxTween.tween(arrow, {alpha: 1}, 0.45, {ease: FlxEase.quadOut});
							}
						case 'graphics':
							{
								addOptions(graphicsCategory);
								currentCategory = optionsSub[i];
								FlxTween.cancelTweensOf(arrow);
								FlxTween.tween(arrow, {alpha: 1}, 0.45, {ease: FlxEase.quadOut});
							}
						case 'audio':
							{
								currentCategory = 'audio';
								addOptions(audioCategory);
							}
						case 'downscroll' | 'ghost tap' | 'graphic detail' | 'animation detail' | 'antialiasing':
							{
								changeOption(optionTxt.text);
								selectedOptionText = optionTxt.text;
							}
						case 'test audio':
							{
								// testAudio();
							}
						case 'back':
							{
								Settings.saveData(null, null, true);
								if (currentCategory == 'categorySub')
								{
									currentCategory = 'default';
									addOptions();
								}
								else
								{
									currentCategory = 'categorySub';
									addOptions(optionsSub);
								}
								currentOptionsTxt.clear();
								FlxTween.cancelTweensOf(arrow);
								FlxTween.tween(arrow, {alpha: 0}, 0.45, {ease: FlxEase.quadOut});
								selectedOptionText = '';
							}
					}
				}, null, function(spr:Alphabet)
				{
					if (doneTweening)
					{
						optionTxt.alpha = 1;
						if (description.exists(optionTxt.text))
							descriptionTxt.text = description.get(optionTxt.text);
						else
							descriptionTxt.text = '';
					}

					curSelected = i;
				}, function(spr:Alphabet)
				{
					if (doneTweening)
					{
						optionTxt.alpha = 0.6;
						descriptionTxt.text = '';
					}

					curSelected = -1;
				});

				FlxTween.tween(optionTxt, {alpha: 0.6}, 0.6, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						doneTweening = true;
						if (i == curSelected)
						{
							optionTxt.alpha = 1;
							if (description.exists(optionTxt.text))
								descriptionTxt.text = description.get(optionTxt.text);
							else
								descriptionTxt.text = '';
						}
					},
					startDelay: 0.3 + (0.1 * i)
				});
			}
		}
	}

	var changeableOptions:Map<String, Array<Dynamic>> = [
		'downscroll' => [true, false],
		'ghost tap' => [true, false],
		'graphic detail' => ['low', 'normal', 'high'],
		'animation detail' => ['static', 'partial', 'full'],
		'antialiasing' => [true, false]
	];

	var actualData:Map<String, Dynamic> = [
		'low' => 0,
		'normal' => 1,
		'high' => 2,
		'static' => 0,
		'partial' => 1,
		'full' => 2
	];

	function selectOption(change:Int):Void
	{
		if (currentOptionsTxt.members.length > 0)
		{
			selectedOption += change;

			if (selectedOption > currentOptionsTxt.members.length - 1)
				selectedOption = 0;
			if (selectedOption == -1)
				selectedOption = currentOptionsTxt.members.length - 1;

			var selOptionString:String = '';

			if (['gameplay', 'graphics'].contains(currentCategory))
				selOptionString = currentOptionsTxt.members[selectedOption].text;

			keyInput = true;

			try
			{
				if (['gameplay', 'graphics'].contains(currentCategory) && selOptionString != null)
				{
					var dataValue:Dynamic = null;

					switch (selOptionString)
					{
						case 'on':
							dataValue = true;
						case 'off':
							dataValue = false;
						default:
							dataValue = actualData.get(selOptionString);
					}

					if (dataValue == null && selectedOptionText == null)
						return;

					if (keyInput)
						Settings.saveData(selectedOptionText, dataValue, false);
				}
			}
		}
	}

	function changeOption(txt:String = null):Void
	{
		if (txt == null)
			return;

		Settings.saveData(null, null, true);

		currentOptionsTxt.clear();

		var arrayFetch:Array<String> = [];

		for (options in changeableOptions.get(txt))
		{
			var valueName:String = '';

			switch (Std.string(changeableOptions.get(txt)[changeableOptions.get(txt).indexOf(options)]))
			{
				case 'true':
					valueName = 'on';
				case 'false':
					valueName = 'off';
				default:
					valueName = Std.string(changeableOptions.get(txt)[changeableOptions.get(txt).indexOf(options)]);
			}

			var optionTxt:Alphabet = new Alphabet(0, FlxG.height * 1.1, valueName, true);
			optionTxt.x = FlxG.width + optionTxt.width + 32;
			optionTxt.y = FlxG.height * 0.85 + (35 * changeableOptions.get(txt).indexOf(options));
			optionTxt.antialiasing = true;
			optionTxt.scrollFactor.set();
			optionTxt.ID = changeableOptions.get(txt).indexOf(options);
			currentOptionsTxt.add(optionTxt);
			currentOptions = changeableOptions.get(txt);

			arrayFetch.push(changeableOptions.get(txt)[changeableOptions.get(txt).indexOf(options)]);
		}
		keyInput = false;

		selectedOption = Settings.fetchCurrentSelection(txt, arrayFetch);
	}

	function testAudio():Void
	{
		currentOptionsTxt.forEachAlive(function(txt:Alphabet)
		{
			txt.visible = false;
		});

		selectables.forEachAlive(function(txt:Alphabet)
		{
			txt.visible = false;
		});

		lastSelections.forEachAlive(function(txt:Alphabet)
		{
			txt.visible = false;
		});
	}
}

class AudioText extends FlxText
{
	public var sprTracker:FlxSprite;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
		{
			x = FlxMath.lerp(x, sprTracker.x + sprTracker.width + 50, 0.85 * (30 * Main.framerate));
			y = FlxMath.lerp(y, sprTracker.getGraphicMidpoint().y, 0.85 * (30 * Main.framerate));
		}
	}
}
