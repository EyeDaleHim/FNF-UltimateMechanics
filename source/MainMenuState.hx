package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.FlxGradient;
import flixel.util.FlxStringUtil;
import flixel.system.FlxSound;
import flixel.math.FlxMath;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.addons.display.FlxBackdrop;
// import io.newgrounds.NG;
import lime.utils.Assets;
import lime.app.Application;
#if sys
import sys.FileSystem;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;
	var selectedMechanic:Int = -1;
	var selectedMenu:String = 'select';
	var menus:Array<String> = ['mechanics', 'select'];
	var mouseAction:Bool = true;
	var songs:Array<SongMetadata> = [];
	var displaySongs:FlxTypedGroup<Alphabet>;
	var iconArray:Array<HealthIcon> = [];

	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];

	public static var mechanics:Array<Mechanic> = [
		new Mechanic('Fire Notes', 'Pressing Fire Notes will reduce your health slightly!\nThe Level depends on how much it should spawn.', "tricky"),
		new Mechanic('Halo Notes', 'Pressing Halo Notes will kill you instantly.\nThe Level depends on how much it should spawn.', "expurgation"),
		new Mechanic('Randomizer', 'Notes can sometimes change their positions when on-screen. \nThis only affects normal notes.', "random1"),
		new Mechanic('Health Drain', 'Your health drains over time, the interval to decrease\nyour health depends on the level.', "healthdr1"),
		new Mechanic('Opponent Fights Back', 'Your opponent can fight back! They\'ll drain your\nhealth if they hit a note.', "healthdr2"),
		new Mechanic('Tricky Gremlin', 'A Tricky Gremlin will pop up and drag your health\nuntil you hit a note!', "gremlins"),
		new Mechanic('Note Speed', 'A Note will randomize it\'s speed.\nNot to a set value anymore.', "notespeed"),
		new Mechanic('Note Swap', 'The Strum Line will change it\'s position.\nMore frequently depending on the Level.', "noteswap"),
		new Mechanic('Randomizer 2', 'New Notes will generate by themselves!\nThis won\'t give you points however...', "random2"),
		new Mechanic('Strum Line Swap', 'Yours and the enemy\'s Strum Line will swap correspondingly!\nThe frequency depends on the Level.', 'strumswap'),
		new Mechanic('Sawblades', 'Sawblades will sometimes appear and will kill you instantly if\nyou don\'t dodge in time!', 'sawblade1'),
		new Mechanic('Double Sawblades',
			'Double Sawblades are more rarer than regular Sawblades.\nYou have to dodge the sawblades twice to avoid getting killed!', 'sawblade2')
	];

	public static var inOptionsState:Bool = false;

	var mechanicItems:FlxTypedGroup<FlxSprite>;

	var mechanicArrows:Array<FlxTypedGroup<FlxSprite>> = [new FlxTypedGroup<FlxSprite>(), new FlxTypedGroup<FlxSprite>()];
	var mechanicTxts:FlxTypedGroup<FlxText>;
	var mechanicBtn:FlxTypedGroup<FlxSprite>;
	var buttonAdds:Array<Int> = [0, 1, 5, 10, 20];

	var bg:FlxSprite;
	var gradient:FlxSprite;
	var magenta:FlxSprite;
	var discord:FlxSprite;
	var gridBG:FlxBackdrop;
	var grid:FlxBackdrop;
	var gridLine:FlxTypedGroup<FlxSprite>;
	var glowyLines:FlxTypedGroup<FlxSprite>;
	var camFollow:FlxObject;

	var offsetPosition:Array<Float> = [-1.9, -2.2];

	var funkinCursor:FlxSprite;

	var rightBG:FlxSprite;
	var descriptionTxt:FlxText;
	var moreButton:FlxSprite;

	var debugTxt:FlxText = new FlxText();
	var testSprite:FlxSprite;

	var readyBtn:Alphabet;
	var backBtn:Alphabet;
	var isReady:Bool = false;

	var multiplier:Float = 0;

	var regChars:Array<String> = [];
	var bgChars:FlxTypedGroup<Character>;

	var diff:Int = 1;

	var score:Int = 0;
	var lerpScore:Int = 0;
	var formattedScore:String = '';

	var scoreBG:FlxSprite;

	var scoreText:FlxText;
	var diffText:FlxText;

	var multiplyTxt:FlxText;

	var blacklistedMechanics:Array<Int> = [0, 1, 7, 9];

	var modLogo:FlxSprite = new FlxSprite();

	public static var readyTime:Float = 2.6;

	public static var notFirstTime:Bool = false;

	override function create()
	{
		Settings.init();

		inOptionsState = false;

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		PlayState.unspawnNotes = [];

		if (!notFirstTime)
		{
			FlxG.camera.zoom += 0.6;
			FlxG.camera.fade(FlxColor.BLACK, 1.5, true);
			FlxTween.tween(FlxG.camera, {zoom: 1}, 2, {ease: FlxEase.quartOut});
			notFirstTime = true;
		}

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		var randomSong:Int = FlxG.random.int(1, 4);

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('menuSong/menuSong${Std.string(randomSong)}'), 0.6);
		}

		FlxG.sound.music.loopTime = 20000;

		persistentUpdate = persistentDraw = true;

		addWeek(['Tutorial'], 1, ['gf'], [100]);

		// WEEK 1
		addWeek(['Bopeebo', 'Fresh', 'Dadbattle'], 1, ['dad', 'dad', 'dad'], [100]);

		// WEEK 2
		addWeek(['Spookeez', 'South', 'Monster'], 2, ['spooky', 'spooky', 'monster'], [100]);

		// WEEK 3
		addWeek(['Pico', 'Philly', 'Blammed'], 3, ['pico', 'pico', 'pico'], [100]);

		// WEEK 4
		addWeek(['Satin-Panties', 'High', 'Milf'], 4, ['mom', 'mom', 'mom'], [100]);

		// WEEK 5
		addWeek(['Cocoa', 'Eggnog', 'Winter-Horrorland'], 5, ['parents-christmas', 'parents-christmas', 'monster'], [100]);

		// WEEK 6
		addWeek(['Senpai', 'Roses', 'Thorns'], 6, ['senpai', 'senpai', 'spirit'], [144]);

		bg = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		/*testSprite = new FlxSprite().makeGraphic(2, 80, FlxColor.RED);
			testSprite.scrollFactor.set(); */

		gradient = FlxGradient.createGradientFlxSprite(Std.int(bg.width), Std.int(bg.height), [generateColor(), generateColor()], 180, 1);
		gradient.x = -80;
		gradient.scale.set(1.1, 1.5);
		gradient.scrollFactor.set();
		gradient.updateHitbox();
		gradient.screenCenter();
		gradient.antialiasing = true;
		gradient.blend = MULTIPLY;
		add(gradient);

		gridLine = new FlxTypedGroup<FlxSprite>();
		add(gridLine);

		gridBG = new FlxBackdrop(Paths.image('checker'), 0.2, 0.2, true, true);
		gridBG.scrollFactor.set(0.1, 0.1);
		gridBG.antialiasing = true;
		add(gridBG);
		colorBG();

		grid = new FlxBackdrop(Paths.image('bgGrid', 'shared'), 0.2, 0.2, true, true);
		grid.scrollFactor.set();
		grid.antialiasing = true;
		// grid.alpha = 0.6;
		add(grid);

		glowyLines = new FlxTypedGroup<FlxSprite>();
		add(glowyLines);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		camFollow.y = 900;

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		mechanicItems = new FlxTypedGroup<FlxSprite>();
		add(mechanicItems);

		mechanicTxts = new FlxTypedGroup<FlxText>();
		add(mechanicTxts);

		add(mechanicArrows[0]);
		add(mechanicArrows[1]);

		bgChars = new FlxTypedGroup<Character>();
		add(bgChars);

		displaySongs = new FlxTypedGroup<Alphabet>();
		add(displaySongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			songText.scrollFactor.set();
			songText.alpha = 0;
			displaySongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			icon.alpha = 0;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.65, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr", "ttf"), 32, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		scoreText.alpha = 0;
		scoreText.text = 'PERSONAL BEST: 0, 0%';
		scoreText.scrollFactor.set();
		// scoreText.alignment = RIGHT;

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.60), 66, FlxColor.BLACK);
		scoreBG.alpha = 0;
		scoreBG.scrollFactor.set();

		diffText = new FlxText(scoreText.x + 128, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		diffText.setFormat(Paths.font("vcr", "ttf"), 24, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		diffText.scrollFactor.set();
		diffText.alpha = 0;
		diffText.text = '< ${['easy', 'normal', 'hard'][diff]} >'.toUpperCase();

		multiplyTxt = new FlxText(FlxG.width * 0.85, FlxG.height * 0.65);
		multiplyTxt.scrollFactor.set();
		multiplyTxt.setFormat(Paths.font('funkin', 'otf'), 56, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		multiplyTxt.borderSize = 2;
		multiplyTxt.text = '1X';

		rightBG = new FlxSprite(FlxG.width - FlxG.width * (1 - 0.75), 0);
		rightBG.makeGraphic(Std.int(FlxG.width * 0.25), FlxG.height, FlxColor.fromRGB(0, 0, 0));
		rightBG.alpha = 0.3;
		rightBG.scrollFactor.set();
		add(rightBG);
		add(multiplyTxt);

		moreButton = new FlxSprite();
		moreButton.loadGraphic(Paths.image('mechanic/moreButton', 'shared'));
		moreButton.screenCenter();
		moreButton.x = rightBG.x - moreButton.width;
		moreButton.alpha = 0.3;
		moreButton.scrollFactor.set();
		moreButton.antialiasing = true;
		add(moreButton);

		FlxMouseEventManager.add(moreButton, function(spr:FlxSprite)
		{
			if (!inOptionsState && mouseAction)
			{
				inOptionsState = true;
				funkinCursor.alpha = 0;
				FlxTween.cancelTweensOf(spr);
				FlxTween.tween(spr, {alpha: 0.3}, 0.25, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						spr.alpha = 0.3;
					}
				});
				openSubState(new SettingsSubstate());
				fixSelectors();
			}
		}, null, function(spr:FlxSprite)
		{
			if (!inOptionsState && mouseAction)
			{
				FlxTween.cancelTweensOf(spr);
				FlxTween.tween(spr, {alpha: 0.6}, 0.25, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						spr.alpha = 0.6;
					}
				});
			}
		}, function(spr:FlxSprite)
		{
			if (!inOptionsState && mouseAction)
			{
				FlxTween.cancelTweensOf(spr);
				FlxTween.tween(spr, {alpha: 0.3}, 0.25, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						spr.alpha = 0.3;
					}
				});
			}
		});

		mechanicBtn = new FlxTypedGroup<FlxSprite>();
		add(mechanicBtn);

		descriptionTxt = new FlxText(FlxG.width * 0.15, FlxG.height * 0.85, 0, "");
		descriptionTxt.setFormat(Paths.font('funkin', 'otf'), 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		descriptionTxt.scrollFactor.set();
		descriptionTxt.updateHitbox();
		descriptionTxt.antialiasing = true;
		add(descriptionTxt);

		add(testSprite);

		debugTxt.x = 30;
		debugTxt.y = 30;
		debugTxt.scrollFactor.set();
		debugTxt.size = 22;
		debugTxt.setFormat(Paths.font('vcr', 'ttf'), 22, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		add(debugTxt);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		// BRO IM BAD AT THIS IM JUST SETTING THE VALUES MANUALLY
		// x = 40 + (200 * i) y = 180 + (340 * ???)
		// x, can reset, y, difference of 360
		var mechanicPositions:Array<Array<Float>> = [
			[40, 180], // 0
			[240, 180], // 1
			[440, 180], // 2
			[640, 180], // 3
			[40, 540], // 4
			[240, 540], // 5
			[440, 540], // 6
			[640, 540], // 7
			[40, 900], // 8
			[240, 900], // 9
			[440, 900], // 10
			[640, 900] // 11
		];

		for (pos in mechanicPositions)
		{
			pos[0] -= 5; // offset
		}

		for (i in 0...mechanics.length)
		{
			if (mechanicPositions[i] == null)
			{
				mechanicPositions.push([-FlxG.width, -FlxG.height]);
				trace('UNKNOWN POS: $i');
			}
			var mechanicPort:FlxSprite = new FlxSprite(mechanicPositions[i][0], mechanicPositions[i][1]);
			// mechanicPort.x += 200 * i;
			mechanicPort.ID = i;

			// mechanicPort.x -= 600;
			// mechanicPort.y += 380 * mechanicPort.point;

			if (Assets.exists(Paths.image('portraits/' + mechanics[i].image, 'shared', true)))
			{
				mechanicPort.loadGraphic(Paths.image('portraits/' + mechanics[i].image, 'shared', true));
			}
			else
			{
				mechanicPort.loadGraphic(Paths.image('portraits/' + 'blank', 'shared', true));
			}
			mechanicPort.updateHitbox();
			mechanicPort.scrollFactor.x = 0;
			mechanicPort.scrollFactor.y = 0.3;
			mechanicPort.antialiasing = true;
			mechanicItems.add(mechanicPort);

			mechanicPort.setColorTransform(0.3, 0.3, 0.3);
			if (mechanics[mechanicPort.ID].points > 0)
				mechanicPort.setColorTransform(0.6, 0.6, 0.6, 1);

			var mechanicArrowL:FlxSprite = new FlxSprite();
			mechanicArrowL.loadGraphic(Paths.image('mechanicArr', 'shared'));
			mechanicArrowL.x = mechanicPort.x + 8;
			mechanicArrowL.y = (mechanicPort.y + mechanicPort.height) - 60;
			mechanicArrowL.scrollFactor.set(0, 0.3);
			mechanicArrowL.antialiasing = true;
			mechanicArrows[0].add(mechanicArrowL);

			var mechanicArrowR:FlxSprite = new FlxSprite();
			mechanicArrowR.loadGraphic(Paths.image('mechanicArr', 'shared'));
			mechanicArrowR.x = (mechanicPort.x + mechanicPort.width) - 40;
			mechanicArrowR.y = (mechanicPort.y + mechanicPort.height) - 60;
			mechanicArrowR.scrollFactor.set(0, 0.3);
			mechanicArrowR.flipX = true;
			mechanicArrowR.antialiasing = true;
			mechanicArrows[1].add(mechanicArrowR);

			var mechanicTxt:FlxText = new FlxText();
			mechanicTxt.x = mechanicPort.getGraphicMidpoint().x - 20;
			mechanicTxt.y = mechanicPort.getGraphicMidpoint().y;
			mechanicTxt.y += 110;
			mechanicTxt.scrollFactor.set(0, 0.3);
			mechanicTxt.setFormat(Paths.font('funkin', 'otf'), 48, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
			mechanicTxt.borderSize = 2;
			mechanicTxt.antialiasing = true;
			mechanicTxt.height = Std.int(mechanicTxt.height * 1.1);
			mechanicTxts.add(mechanicTxt);

			mechanicTxts.members[mechanicPort.ID].text = '${mechanics[mechanicPort.ID].points}';

			FlxMouseEventManager.add(mechanicArrowL, function(spr:FlxSprite)
			{
				if (blacklistedMechanics.contains(mechanicPort.ID) || inOptionsState)
					return;

				if (selectedMenu == menus[1] && mouseAction)
				{
					mechanics[mechanicPort.ID].points -= 1;

					if (mechanics[mechanicPort.ID].points < 0)
						mechanics[mechanicPort.ID].points = 0;

					mechanicTxts.members[mechanicPort.ID].text = '${mechanics[mechanicPort.ID].points}';
					mechanicTxt.updateHitbox();
					if (mechanicTxts.members[mechanicPort.ID].text.length == 2)
						mechanicTxt.x = (mechanicPort.getGraphicMidpoint().x - 20) - (2 * mechanicTxt.text.length);
					else
						mechanicTxt.x = mechanicPort.getGraphicMidpoint().x - 20;

					if (mechanics[mechanicPort.ID].points - 1 != -1
						|| (mechanics[mechanicPort.ID].points + 1 == 1 && mechanics[mechanicPort.ID].points == 0))
						FlxG.sound.play(Paths.sound('mechanicSel'), 0.6);
					checkHold(mechanicPort.ID, false);
					calculateMulti();
				}
			}, null, function(spr:FlxSprite)
			{
				if (blacklistedMechanics.contains(mechanicPort.ID) || inOptionsState)
					return;
				spr.scale.set(1.1, 1.1);
				spr.setColorTransform(0.6, 0.6, 0.6, 1);
				camFollow.velocity.y = 0;
			}, function(spr:FlxSprite)
			{
				if (blacklistedMechanics.contains(mechanicPort.ID) || inOptionsState)
					return;
				spr.scale.set(1, 1);
				spr.setColorTransform(1, 1, 1, 1);
			}, true);

			FlxMouseEventManager.add(mechanicArrowR, function(spr:FlxSprite)
			{
				if (blacklistedMechanics.contains(mechanicPort.ID) || inOptionsState)
					return;

				if (selectedMenu == menus[1] && mouseAction)
				{
					mechanics[mechanicPort.ID].points += 1;

					if (mechanics[mechanicPort.ID].points > 20)
						mechanics[mechanicPort.ID].points = 20;

					mechanicTxts.members[mechanicPort.ID].text = '${mechanics[mechanicPort.ID].points}';
					mechanicTxt.updateHitbox();
					if (mechanicTxts.members[mechanicPort.ID].text.length == 2)
						mechanicTxt.x = (mechanicPort.getGraphicMidpoint().x - 20) - (2 * mechanicTxt.text.length);
					else
						mechanicTxt.x = mechanicPort.getGraphicMidpoint().x - 20;
					if (mechanics[mechanicPort.ID].points + 1 != 21
						|| (mechanics[mechanicPort.ID].points - 1 == 19 && mechanics[mechanicPort.ID].points == 20))
						FlxG.sound.play(Paths.sound('mechanicSel'), 0.6);
					checkHold(mechanicPort.ID, true);
					calculateMulti();
				}
			}, null, function(spr:FlxSprite)
			{
				if (blacklistedMechanics.contains(mechanicPort.ID) || inOptionsState)
					return;
				spr.scale.set(1.1, 1.1);
				spr.setColorTransform(0.6, 0.6, 0.6, 1);
				camFollow.velocity.y = 0;
			}, function(spr:FlxSprite)
			{
				if (blacklistedMechanics.contains(mechanicPort.ID) || inOptionsState)
					return;
				spr.scale.set(1, 1);
				spr.setColorTransform(1, 1, 1, 1);
			}, true);

			FlxMouseEventManager.add(mechanicPort, null, null, function(spr:FlxSprite)
			{
				if (blacklistedMechanics.contains(mechanicPort.ID) || inOptionsState)
					return;
				if (selectedMenu == menus[1] && mouseAction)
				{
					selectedMechanic = spr.ID;
					spr.setColorTransform(1.0, 1.0, 1.0);
					descriptionTxt.text = mechanics[spr.ID].description;
					descriptionTxt.text += '\n';
				}
			}, function(spr:FlxSprite)
			{
				if (blacklistedMechanics.contains(mechanicPort.ID))
					return;
				selectedMechanic = -1;
				spr.setColorTransform(0.7, 0.7, 0.7);
				if (mechanics[spr.ID].points == 0)
					spr.setColorTransform(0.3, 0.3, 0.3);
				descriptionTxt.text = '';
			}, true);
		}

		for (i in 0...buttonAdds.length)
		{
			var button:FlxSprite = new FlxSprite(rightBG.getGraphicMidpoint().x - 60, 40 + (70 * i));
			button.loadGraphic(Paths.image('mechanic/button' + i, 'shared'));
			button.scale.set(0.65, 0.65);
			button.updateHitbox();
			button.centerOrigin();

			var hitbox:FlxObject = new FlxObject(button.x, button.y, button.width, button.height);
			hitbox.scrollFactor.set();
			add(hitbox);

			button.scrollFactor.set();
			button.antialiasing = true;
			mechanicBtn.add(button);

			// for some reason scaling is messy in FlxMouseEventManager
			var realSpr = button;

			FlxMouseEventManager.add(hitbox, function(spr:FlxObject)
			{
				if (inOptionsState)
					return;

				if (selectedMenu == menus[1] && mouseAction)
				{
					FlxTween.cancelTweensOf(realSpr.colorTransform);
					realSpr.setColorTransform(1, 1, 1, 1, 255, 255, 255, 255);
					FlxTween.tween(realSpr.colorTransform, {redOffset: 0, blueOffset: 0, greenOffset: 0}, 0.1, {
						ease: FlxEase.smoothStepInOut,
						onComplete: function(twn:FlxTween)
						{
							FlxTween.tween(realSpr.colorTransform, {redOffset: 0, blueOffset: 0, greenOffset: 0}, 0.8,
								{ease: FlxEase.smoothStepInOut, type: PINGPONG});
						}
					});

					var soundPlay:Bool = false;
					for (mechanic in mechanics)
					{
						var isNotBlacklisted:Bool = false;
						var index = mechanics.indexOf(mechanic);

						if (blacklistedMechanics.contains(index))
							isNotBlacklisted = true;

						if (!isNotBlacklisted)
						{
							if (i == 1)
							{
								if (mechanic.points + 1 != 21)
									mechanic.points += buttonAdds[i];
							}
							else
							{
								mechanic.points = buttonAdds[i];
							}

							mechanicTxts.members[index].text = '${mechanic.points}';

							if (mechanicTxts.members[index].text.length == 2)
								mechanicTxts.members[index].x = (mechanicItems.members[index].getGraphicMidpoint().x - 20)
									- (2 * mechanicTxts.members[index].text.length);
							else
								mechanicTxts.members[index].x = mechanicItems.members[index].getGraphicMidpoint().x - 20;

							if (i == 0)
								mechanicItems.members[index].setColorTransform(0.3, 0.3, 0.3, 1);
							else
								mechanicItems.members[index].setColorTransform(0.7, 0.7, 0.7, 1);

							if (!soundPlay)
							{
								FlxG.sound.play(Paths.sound('mechanicSel'), 0.6);
								soundPlay = true;
							}
						}
					}
					calculateMulti();
				}
			}, null, function(spr:FlxObject)
			{
				if (inOptionsState)
					return;

				realSpr.setColorTransform(1, 1, 1, 1, 50, 50, 50, 255);
				FlxTween.tween(realSpr.colorTransform, {redOffset: 0, blueOffset: 0, greenOffset: 0}, 0.8, {ease: FlxEase.smoothStepInOut, type: PINGPONG});
			}, function(spr:FlxObject)
			{
				if (inOptionsState)
					return;

				FlxTween.cancelTweensOf(realSpr.colorTransform);
				realSpr.setColorTransform(1, 1, 1, 1, 0, 0, 0, 255);
			});
		}

		readyBtn = new Alphabet(0, FlxG.height * 0.8, "READY", true, false);
		readyBtn.x += FlxG.width * 0.78;
		readyBtn.scrollFactor.set();
		readyBtn.alpha = 0.6;
		readyBtn.antialiasing = true;
		add(readyBtn);

		backBtn = new Alphabet(0, FlxG.height * 0.8, "BACK", true, false);
		backBtn.x += FlxG.width * 0.78;
		backBtn.scrollFactor.set();
		backBtn.alpha = 0;
		backBtn.antialiasing = true;
		add(backBtn);

		add(scoreBG);
		add(scoreText);
		add(diffText);

		var readyClick:Alphabet->Void = function(spr:Alphabet)
		{
			if (!isReady && selectedMenu == 'select' && !inOptionsState)
			{
				isReady = true;
				FlxMouseEventManager.remove(readyBtn);
				mouseAction = false;
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.6);
				new FlxTimer().start(0.04, function(tmr:FlxTimer)
				{
					spr.visible = !spr.visible;
				}, 60);

				new FlxTimer().start(readyTime, function(tmr:FlxTimer)
				{
					spr.visible = true;
					isReady = false;
					multiplier = 1;
					spr.alpha = 0.6;
					readyTime = 2.6;
					// var groups:Array<Dynamic> = [mechanicItems, mechanicTxts, mechanicArrows];

					var easing = FlxEase.quadIn;
					var position:Float = 1000;
					var duration:Float = 1.5;

					calculateMulti();

					transitionOut(function()
					{
						var black:FlxSprite = new FlxSprite(-80, -80).makeGraphic(Std.int(FlxG.width * 1.2), Std.int(FlxG.height * 1.2), FlxColor.BLACK);
						black.scrollFactor.set();
						add(black);

						rightBG.visible = false;
						moreButton.x = FlxG.width - moreButton.width;

						for (i in 0...mechanicBtn.members.length)
						{
							mechanicBtn.members[i].visible = false;
						}

						curSelected = 0;
						changeSong();

						new FlxTimer().start(0.6, function(tmr:FlxTimer)
						{
							remove(black);
							black.destroy();
							gridBG.scrollFactor.set();

							backBtn.alpha = 0.6;
							readyBtn.alpha = 0;

							selectedMenu = 'freeplay';
							for (songs in displaySongs)
							{
								songs.alpha = 0.6;
							}
							for (icon in iconArray)
							{
								icon.alpha = 0.6;
							}

							multiplyTxt.alpha = 0;

							scoreText.alpha = 1;
							scoreBG.alpha = 0.6;
							diffText.alpha = 1;

							iconArray[0].alpha = 1;
							displaySongs.members[0].alpha = 1;

							transitionIn();
							mouseAction = true;
						});
					});

					for (i in 0...mechanicItems.members.length)
					{
						FlxTween.tween(mechanicItems.members[i], {x: mechanicItems.members[i].x - position}, duration, {
							ease: easing,
							onComplete: function(spr:Dynamic)
							{
								selectedMenu = 'freeplay';
							}
						});
					}

					for (i in 0...mechanicTxts.members.length)
					{
						FlxTween.tween(mechanicTxts.members[i], {x: mechanicTxts.members[i].x - position}, duration, {
							ease: easing,
							onComplete: function(spr:Dynamic)
							{
								selectedMenu = 'freeplay';
							}
						});
					}

					for (i in 0...2)
					{
						if (mechanicArrows[i] == null)
							continue;
						for (j in 0...mechanicArrows[i].members.length)
						{
							FlxTween.tween(mechanicArrows[i].members[j], {x: mechanicArrows[i].members[j].x - position}, duration, {
								ease: easing,
								onComplete: function(spr:Dynamic)
								{
									selectedMenu = 'freeplay';
								}
							});
						}
					}
				});
			}
		};

		var readyDown:Alphabet->Void = function(spr:Alphabet)
		{
			if (spr.alpha != 0 && !inOptionsState)
				spr.alpha = 1;
		}
		var readyOff:Alphabet->Void = function(spr:Alphabet)
		{
			if (spr.alpha != 0 && !inOptionsState)
			{
				spr.alpha = 0.6;
				if (isReady)
					spr.alpha = 1;
			}
		}

		FlxMouseEventManager.add(backBtn, function(spr:Alphabet)
		{
			if (!isReady && selectedMenu == 'freeplay' && !inOptionsState)
			{
				isReady = true;
				mouseAction = false;
				FlxMouseEventManager.add(readyBtn, readyClick, null, readyDown, readyOff);
				FlxG.sound.play(Paths.sound('cancelMenu'), 0.6);

				readyTime = 2.6;

				new FlxTimer().start(0.04, function(tmr:FlxTimer)
				{
					spr.visible = !spr.visible;
				}, 60);

				calculateMulti();

				transitionOut(function()
				{
					var black:FlxSprite = new FlxSprite(-80, -80).makeGraphic(Std.int(FlxG.width * 1.2), Std.int(FlxG.height * 1.2), FlxColor.BLACK);
					black.scrollFactor.set();
					add(black);

					rightBG.visible = true;
					moreButton.x = rightBG.x - moreButton.width;

					for (i in 0...mechanicBtn.members.length)
					{
						mechanicBtn.members[i].visible = true;
					}

					curSelected = 0;
					changeSong();

					for (i in 0...mechanicItems.members.length)
					{
						mechanicItems.members[i].x += 1000;
					}

					for (i in 0...mechanicTxts.members.length)
					{
						mechanicTxts.members[i].x += 1000;
					}

					for (i in 0...2)
					{
						if (mechanicArrows[i] == null)
							continue;
						for (j in 0...mechanicArrows[i].members.length)
						{
							mechanicArrows[i].members[j].x += 1000;
						}
					}

					new FlxTimer().start(0.6, function(tmr:FlxTimer)
					{
						remove(black);
						black.destroy();
						transitionIn();
						gridBG.scrollFactor.set(0.1, 0.1);
						selectedMenu = 'select';

						for (songs in displaySongs)
						{
							songs.alpha = 0;
						}
						for (icon in iconArray)
						{
							icon.alpha = 0;
						}

						scoreBG.alpha = 0;
						scoreText.alpha = 0;
						diffText.alpha = 0;
						multiplyTxt.alpha = 1;

						backBtn.alpha = 0;
						readyBtn.alpha = 0.6;
						isReady = false;
						mouseAction = true;
					});
				});
			}
		}, null, function(spr:Alphabet)
		{
			if (spr.alpha != 0 && !inOptionsState)
				spr.alpha = 1;
		}, function(spr:Alphabet)
		{
			if (spr.alpha != 0 && !inOptionsState)
			{
				spr.alpha = 0.6;
				if (isReady)
					spr.alpha = 1;
			}
		});

		FlxMouseEventManager.add(readyBtn, readyClick, null, readyDown, readyOff);

		/*
			for (i in 0...optionShit.length)
			{
				var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
				menuItem.frames = tex;
				menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
				menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
				menuItem.animation.play('idle');
				menuItem.ID = i;
				menuItem.screenCenter(X);
				menuItems.add(menuItem);
				menuItem.scrollFactor.set();
				menuItem.antialiasing = true;
		}*/

		for (i in 0...3)
		{
			new FlxTimer().start(2 - (0.15 * i), function(tmr:FlxTimer)
			{
				for (j in 0...FlxG.random.int(1, 6))
				{
					var isVertical:Bool = FlxG.random.bool(50);

					var scanLine:FlxSprite;

					if (isVertical)
						scanLine = new FlxSprite().makeGraphic(2, 80, FlxColor.BLACK);
					else
						scanLine = new FlxSprite().makeGraphic(80, 2, FlxColor.BLACK);

					scanLine.scrollFactor.set();

					scanLine.x = (80 - offsetPosition[0]) * FlxG.random.int(1, 17);
					scanLine.y = (80 - offsetPosition[1]) * FlxG.random.int(1, 10);
					if (!isVertical)
						scanLine.x += 3;

					gridLine.add(scanLine);

					if (!isVertical)
					{
						FlxTween.tween(scanLine, {y: scanLine.y - 80}, 4 - (0.25 * FlxG.random.int(1, 3)), {
							ease: FlxEase.circOut,
							onComplete: function(twn:FlxTween)
							{
								gridLine.remove(scanLine);
								scanLine.destroy();
							}
						});
					}
					else
					{
						FlxTween.tween(scanLine, {x: scanLine.x - 80}, 4 - (0.25 * FlxG.random.int(1, 3)), {
							ease: FlxEase.circOut,
							onComplete: function(twn:FlxTween)
							{
								gridLine.remove(scanLine);
								scanLine.destroy();
							}
						});
					}

					FlxTween.tween(scanLine, {alpha: 0}, 2, {ease: FlxEase.quintOut, startDelay: 1.6});
				}

				tmr.reset(2 - (0.15 * FlxG.random.int(0, 3)));
			});
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		var coolString:String = "Mod Created by EyeDaleHim\nRoyalty Free Music by TeknoAXE\n";

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, coolString, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.y = FlxG.height - 34;
		#if tester
		versionShit += '-TESTER';
		#end
		add(versionShit);

		discord = new FlxSprite(rightBG.x - 16, FlxG.height * 0.85);
		discord.loadGraphic(Paths.image('discord'));
		discord.scrollFactor.set();
		discord.scale.set(0.5, 0.5);
		discord.updateHitbox();
		discord.antialiasing = true;
		discord.x = rightBG.x - discord.width - 16;
		discord.y = FlxG.height * 0.85;
		add(discord);

		var discordHitbox:FlxObject = new FlxObject(discord.x, discord.y, discord.width, discord.height);
		discordHitbox.scrollFactor.set();
		add(discordHitbox);

		FlxMouseEventManager.add(discordHitbox, function(spr:FlxObject)
		{
			if (!inOptionsState)
			{
				FlxG.openURL('https://discord.gg/dbFAXabYnn');
				discord.scale.set(0.5, 0.5);
				discord.setColorTransform(1, 1, 1);
			}
		}, null, function(spr:FlxObject)
		{
			if (!inOptionsState)
			{
				discord.scale.set(0.6, 0.6);
				discord.setColorTransform(0.8, 0.8, 0.8);
			}
		}, function(spr:FlxObject)
		{
			if (!inOptionsState)
			{
				discord.scale.set(0.5, 0.5);
				discord.setColorTransform(1, 1, 1);
			}
		});

		// NG.core.calls.event.logEvent('swag').send();

		/*modLogo = new FlxSprite();
			modLogo.loadGraphic(Paths.image('logoBumpAlt'));
			modLogo.updateHitbox();
			modLogo.screenCenter();
			modLogo.y -= 70;
			modLogo.scrollFactor.set();
			modLogo.antialiasing = true;
			add(modLogo); */

		funkinCursor = new FlxSprite(-120, -120).loadGraphic(Paths.image('cursor', 'shared'));
		funkinCursor.scrollFactor.set();
		funkinCursor.antialiasing = true;
		add(funkinCursor);

		changeItem();

		/*for (char in regChars)
			{
				var isPlayer:Bool = false;
				// how fix
				if (char == 'gf')
					continue;

				if (char == 'bf')
					isPlayer = true;
				
				var character:Character = new Character(-1, -1, char, isPlayer);
				character.scrollFactor.set();
				character.scale.set(0.5, 0.5);
				character.updateHitbox();
				character.centerOrigin();
				character.visible = false;
				if (char == 'gf')
					character.playAnim('danceRight');
				bgChars.add(character);
		}*/

		//	musicVideo();

		super.create();
	}

	var selectedSomethin:Bool = false;
	var camMoveCooldown:Float = 500;

	var lastClick:Array<Float> = [];

	var const1:Float = 0;
	var const2:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.O && !inOptionsState)
		{
			inOptionsState = true;
			funkinCursor.alpha = 0;
			openSubState(new SettingsSubstate());
		}
		else
		{
			funkinCursor.x = FlxG.mouse.getScreenPosition().x;
			funkinCursor.y = FlxG.mouse.getScreenPosition().y;

			funkinCursor.scale.set(1 / FlxG.camera.zoom, 1 / FlxG.camera.zoom);
		}

		if (inOptionsState)
		{
			camMoveCooldown = 500;
		}

		if (enabledMusicVideo)
		{
			FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 1, 0.025);
			if (FlxG.keys.justPressed.V)
				FlxG.camera.zoom += 0.03;

			Conductor.songPosition = FlxG.sound.music.time;
		}

		var formattedLerpScore:String = '';

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, score, 0.4 * (30 / Main.framerate)));

		if (lerpScore <= 10)
			lerpScore = score;

		formattedLerpScore = FlxStringUtil.formatMoney(lerpScore, false);

		scoreText.text = 'PERSONAL BEST: $formattedLerpScore';

		const1 += 2 * FlxG.elapsed;
		const2 += 2 * FlxG.elapsed;

		if (Settings.graphicDetail == 0)
		{
			gridBG.x -= 2.2 * FlxMath.fastSin(const1) * (30 / Main.framerate);
			gridBG.y -= 1.6 * FlxMath.fastCos(const2) * (30 / Main.framerate);
		}
		else
		{
			gridBG.x -= 2.2 * Math.sin(const1) * (30 / Main.framerate);
			gridBG.y -= 1.6 * Math.cos(const2) * (30 / Main.framerate);
		}
		multiplyTxt.text = '${1 + (MathUtils.truncateFloat(multiplier / 100, 2))}X';

		if (!inOptionsState)
		{
			if (FlxG.mouse.justPressed)
			{
				lastClick = [funkinCursor.x, funkinCursor.y];
			}

			if (mouseAction)
			{
				camFollow.y -= FlxG.mouse.wheel * 60;

				if (FlxG.mouse.pressed)
					camMoveCooldown = 500;

				camMoveCooldown -= elapsed * 1000;

				if ((camMoveCooldown >= 5 || FlxG.mouse.getScreenPosition().x > rightBG.x) && inOptionsState)
				{
					camFollow.velocity.y = 0;
				}
				else
				{
					if (!inOptionsState)
					{
						camFollow.velocity.y = (funkinCursor.y - FlxG.height * 0.5) * 4;

						if (Math.abs(camFollow.velocity.y) < moreButton.height)
							camFollow.velocity.y = 0;

						camFollow.velocity.y = MathUtils.clamp(-860, 860, camFollow.velocity.y);
					}

					camMoveCooldown = 0;
				}
			}
			else
			{
				camFollow.velocity.y = 0;
			}
		}

		if (camFollow.y > 2140)
			camFollow.y = 2140;
		if (camFollow.y < 900)
			camFollow.y = 900;

		if (curTimer != null)
		{
			if (!FlxG.mouse.pressed && isHolding)
			{
				curTimer.cancel();
				isHolding = false;
				curTimer = null;
			}
		}

		#if debug
		if (selectedMechanic != -1)
		{
			debugTxt.text = 'selected: '
				+ selectedMechanic
				+ '\npoints: '
				+ mechanics[selectedMechanic].points
					+ '\n\n'
					+ 'POSITION: \n'
					+ '\ny: ${Math.round(camFollow.y)}'
					+ '\noffset: (x: ${offsetPosition[0]}, y: ${offsetPosition[1]})'
					+ '\n';
		}
		else
		{
			debugTxt.text = 'POSITION: \n'
				+ '\ny: ${Math.round(camFollow.y)}'
				+ '\noffset: (x: ${offsetPosition[0]}, y: ${offsetPosition[1]})'
				+ '\n';
		}

		debugTxt.text += '\nMultiplier: $multiplier (${MathUtils.truncateFloat(multiplier / 10, 2)})\n';
		debugTxt.text += '\nGlowy Offset: x: ${lastClick[0]}, y: ${lastClick[1]}\n';
		#end

		if (FlxG.save.data.musicVolume == 100)
		{
			if (FlxG.sound.music.volume < 0.8)
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		else
		{
			if (FlxG.sound.music.volume < FlxG.save.data.musicVolume / 100)
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!inOptionsState)
		{
			if (selectedMenu == 'freeplay')
			{
				if (controls.UP_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), FlxG.save.data.soundVolume);
					changeSong(-1);
					score = Highscore.getScore(songs[curSelected].songName, diff);
				}
				else if (controls.DOWN_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), FlxG.save.data.soundVolume);
					changeSong(1);
					score = Highscore.getScore(songs[curSelected].songName, diff);
				}

				if (controls.RIGHT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), FlxG.save.data.soundVolume);
					changeDiff(1);
					score = Highscore.getScore(songs[curSelected].songName, diff);
				}
				else if (controls.LEFT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), FlxG.save.data.soundVolume);
					changeDiff(-1);
					score = Highscore.getScore(songs[curSelected].songName, diff);
				}
			}

			/*
				#if debug
				if (controls.RIGHT_P)
				{
					var code:Int = 0;
					
					trace('exited game with code of ' + code);
					Sys.exit(code);
				}
				#end */

			if (controls.BACK)
			{
				TitleState.initialized = true;
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (selectedMenu == 'freeplay')
				{
					/*FlxTransitionableState.skipNextTransIn = false;
						FlxTransitionableState.skipNextTransOut = false; */

					var coolSong:String = '';
					switch (songs[curSelected].songName.toLowerCase())
					{
						case 'philly-nice':
							coolSong = 'philly';
						case 'dad-battle':
							coolSong = 'dadbattle';
						default:
							coolSong = songs[curSelected].songName.toLowerCase();
					}

					var poop:String = Highscore.formatSong(coolSong, diff);

					trace(coolSong);
					trace(poop);

					PlayState.SONG = Song.loadFromJson(poop, coolSong);
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = diff;
					PlayState.multiplier = 1 + (MathUtils.truncateFloat(multiplier / 100, 2));

					PlayState.storyWeek = songs[curSelected].week;
					trace('CUR WEEK' + PlayState.storyWeek);
					trace(poop, songs[curSelected].songName.toLowerCase());

					transitionOut(function()
					{
						var black:FlxSprite = new FlxSprite(-80, -80).makeGraphic(Std.int(FlxG.width * 1.2), Std.int(FlxG.height * 1.2), FlxColor.BLACK);
						black.scrollFactor.set();
						add(black);

						LoadingState.loadAndSwitchState(new PlayState());
					});
				}
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	override function closeSubState()
	{
		funkinCursor.alpha = 1;

		// check collisions, will probably be laggy if i add too many
		if (funkinCursor.overlaps(moreButton))
		{
			FlxTween.cancelTweensOf(moreButton);
			FlxTween.tween(moreButton, {alpha: 0.6}, 0.25, {
				ease: FlxEase.quadOut,
				onComplete: function(twn:FlxTween)
				{
					moreButton.alpha = 0.6;
				}
			});
		}

		var itemOverlapped:Bool = false;

		mechanicItems.forEachAlive(function(spr:FlxSprite)
		{
			if (!itemOverlapped)
			{
				if (spr.overlaps(funkinCursor))
				{
					if (!blacklistedMechanics.contains(spr.ID))
					{
						itemOverlapped = true;

						if (selectedMenu == menus[1] && mouseAction)
						{
							selectedMechanic = spr.ID;
							spr.setColorTransform(1.0, 1.0, 1.0);
							descriptionTxt.text = mechanics[spr.ID].description;
							descriptionTxt.text += '\n';
						}

						// do a check for arrows
						var arrowOverlaps:Bool = false;

						for (i in 0...mechanicArrows.length)
						{
							mechanicArrows[i].forEachAlive(function(arr:FlxSprite)
							{
								if (!arrowOverlaps)
								{
									if (arr.overlaps(funkinCursor))
									{
										if (!blacklistedMechanics.contains(spr.ID))
										{
											arrowOverlaps = true;
											arr.scale.set(1.1, 1.1);
											arr.setColorTransform(0.6, 0.6, 0.6, 1);
											camFollow.velocity.y = 0;
										}
										else
										{
											return;
										}
									}
								}
							});
						}
					}
					else
					{
						// ez, just don't go over the overlapping hence the mouse is on a blacklisted portrait
						return;
					}
				}
			}
		});

		super.closeSubState();
	}

	var isHolding:Bool = false;
	var curTimer:FlxTimer;

	function checkHold(id:Int, right:Bool):Void
	{
		// whoops! prevent double clicks!
		if (isHolding || !mouseAction)
			return;

		if (!right)
		{
			if (mechanics[id].points == 20)
				return;
		}
		else
		{
			if (mechanics[id].points == 0)
				return;
		}

		var selTmr:FlxTimer;

		var selector:Int = 0;

		if (right)
			selector = 1;

		selTmr = new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			if (FlxG.mouse.pressed && ((mechanics[id].points != 0) && (mechanics[id].points != 20)))
			{
				for (i in 0...mechanicArrows[selector].members.length)
				{
					if (id != i)
						continue;
					else
					{
						if (mechanicArrows[selector].members[i].scale.x == 1)
						{
							isHolding = false;
							curTimer = null;
							return;
						}
					}
				}

				if (right)
					mechanics[id].points += 1;
				else
					mechanics[id].points -= 1;

				mechanicTxts.members[id].text = '${mechanics[id].points}';

				calculateMulti();

				if (mechanicTxts.members[id].text.length == 2)
					mechanicTxts.members[id].x = (mechanicItems.members[id].getGraphicMidpoint().x - 20) - (2 * mechanicTxts.members[id].text.length);
				else
					mechanicTxts.members[id].x = mechanicItems.members[id].getGraphicMidpoint().x - 20;
				FlxG.sound.play(Paths.sound('mechanicSel'), 0.6);
				tmr.reset(0.05);
				isHolding = true;
			}
			else
			{
				isHolding = false;
				curTimer = null;
				return;
			}
		});

		if (curTimer != null)
		{
			selTmr.cancel();
			curTimer = null;
		}
		curTimer = selTmr;
	}

	function colorBG():Void
	{
		var color = FlxColor.fromRGB(FlxG.random.int(120, 255), FlxG.random.int(120, 255), FlxG.random.int(120, 255));

		FlxTween.tween(gridBG.colorTransform, {redOffset: color.red, blueOffset: color.blue, greenOffset: color.green}, 3, {
			ease: FlxEase.linear,
			onComplete: function(twn:FlxTween)
			{
				colorBG();
			}
		});
	}

	function changeItem(change:Int = 0)
	{
		curSelected += change;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}

	// make this a function cuz apparently the color is super long
	function generateColor():FlxColor
	{
		var color:FlxColor;

		color = FlxColor.fromRGB(FlxG.random.int(165, 255), FlxG.random.int(165, 255), FlxG.random.int(165, 255), 255);

		return color;
	}

	function changeSong(change:Int = 0):Void
	{
		var freeplaySong:FlxSound;

		var bullShit:Int = 0;

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		/*freeplaySong = new FlxSound().loadEmbedded(Paths.music('freeplayTrack/${songs[curSelected].songName.toLowerCase()}'));
			freeplaySong.play();
			freeplaySong.time = FlxG.sound.music.time; */
		/*bgChars.forEach(function(spr:Character)
			{
				spr.visible = false;
				
				if (songs[curSelected].songCharacter == spr.curCharacter)
					spr.visible = true;
		});*/

		for (i in 0...iconArray.length)
		{
			if (selectedMenu == 'freeplay')
				iconArray[i].alpha = 0.6;
		}

		if (selectedMenu == 'freeplay')
			iconArray[curSelected].alpha = 1;

		if (selectedMenu != 'freeplay')
			iconArray[curSelected].alpha = 0;

		for (item in displaySongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			item.selected = false;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.selected = true;
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	function changeDiff(change:Int):Void
	{
		var diffs:Array<String> = ['easy', 'normal', 'hard'];

		diff += change;

		if (diff <= 0)
			diff = 2;
		if (diff >= diffs.length)
			diff = 0;

		diffText.text = '< ${diffs[diff]} >'.toUpperCase();
	}

	function addWeek(name:Array<String>, week:Int, char:Array<String>, bpm:Array<Int>)
	{
		for (i in 0...name.length)
		{
			if (name[i] == null)
				continue;

			if (char.length == 1)
			{
				char[i] == char[0];
			}

			if (!regChars.contains(char[i]))
				regChars.push(char[i]);

			if (bpm[i] == 0)
				bpm[i] = 100;

			songs.push(new SongMetadata(name[i], week, char[i], bpm[i]));
		}
	}

	function calculateMulti():Void
	{
		multiplier = 0;

		for (mechanic in mechanics)
		{
			if (mechanic.points != 0)
				multiplier += 1 * mechanic.points;
		}

		multiplier /= 2;
	}

	var enabledMusicVideo:Bool = false;

	function musicVideo():Void
	{
		new FlxTimer().start(5 + 0.1, function(tmr:FlxTimer)
		{
			enabledMusicVideo = true;

			mechanicItems.forEachAlive(function(spr:FlxSprite)
			{
				spr.visible = false;
			});

			mechanicArrows[0].forEachAlive(function(spr:FlxSprite)
			{
				spr.visible = false;
			});

			mechanicArrows[1].forEachAlive(function(spr:FlxSprite)
			{
				spr.visible = false;
			});

			mechanicTxts.forEachAlive(function(spr:FlxSprite)
			{
				spr.visible = false;
			});

			mechanicBtn.forEachAlive(function(spr:FlxSprite)
			{
				spr.visible = false;
			});

			rightBG.visible = false;
			readyBtn.visible = false;
			multiplyTxt.visible = false;
			moreButton.visible = false;
			discord.visible = false;
			debugTxt.visible = false;

			FlxG.sound.playMusic(Paths.music('freeplayTrack/bopeebo'));

			for (i in 0...20)
			{
				var daGradient:FlxSprite = FlxGradient.createGradientFlxSprite(Std.int(bg.width), Std.int(bg.height), [generateColor(), generateColor()], 180,
					1);
				daGradient.x = -80;
				daGradient.scale.set(1.1, 1.5);
				daGradient.scrollFactor.set();
				daGradient.updateHitbox();
				daGradient.screenCenter();
				daGradient.antialiasing = true;
				daGradient.blend = MULTIPLY;
				if (i != 0)
					daGradient.alpha = 0;
				insert(members.indexOf(gradient) + 1, daGradient);
				if (i != 0)
				{
					FlxTween.tween(daGradient, {alpha: 1}, (FlxG.sound.music.length / 1000) / 20, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							// spr.destroy();
							FlxTween.tween(daGradient, {alpha: 0}, (FlxG.sound.music.length / 1000) / 20, {
								ease: FlxEase.linear,
								onComplete: function(twn:FlxTween)
								{
									daGradient.destroy();
								}
							});
						},
						startDelay: (FlxG.sound.music.length / 1000) / (20 - i)
					});
				}
				else
				{
					FlxTween.tween(daGradient, {alpha: 0}, FlxG.sound.music.length / 20, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							daGradient.destroy();
						}
					});
				}
			}

			var titleTxt:Alphabet = new Alphabet(0, 1 - (FlxG.height * 0.15), "audio test", true, false);
			titleTxt.scrollFactor.set();
			titleTxt.antialiasing = true;
			// titleTxt.updateHitbox();
			titleTxt.screenCenter();
			titleTxt.y = FlxG.height - (FlxG.height * 0.15);
			titleTxt.y -= 70;
			add(titleTxt);

			var progressBarOutline:FlxSprite = new FlxSprite();
			progressBarOutline.makeGraphic(1, 1, FlxColor.BLACK);
			progressBarOutline.updateHitbox();
			progressBarOutline.scale.y = 44;
			progressBarOutline.scale.x = FlxG.width * 2;
			progressBarOutline.scrollFactor.set();
			progressBarOutline.y = FlxG.height - 43;
			add(progressBarOutline);

			var progressBar:FlxSprite = new FlxSprite();
			progressBar.makeGraphic(1, 1, FlxColor.WHITE);
			progressBar.updateHitbox();
			progressBar.scale.y = 40;
			progressBar.scrollFactor.set();
			progressBar.y = progressBarOutline.getGraphicMidpoint().y;
			add(progressBar);

			new FlxTimer().start(1 / 120, function(tmr:FlxTimer)
			{
				progressBar.scale.x = FlxMath.remapToRange(Conductor.songPosition, 0, FlxG.sound.music.length, 0, FlxG.width * 2);
			}, 0);
		});
	}

	function fixSelectors():Void
	{
		for (i in 0...1)
		{
			mechanicArrows[i].forEachAlive(function(spr:FlxSprite)
			{
				if (spr.scale.x > 1)
				{
					spr.scale.set(1, 1);
					spr.setColorTransform(1, 1, 1, 1);
				}
			});
		}
	}

	override public function beatHit():Void
	{
		/*bgChars.forEach(function(spr:Character)
			{
				if (spr.curCharacter == 'gf' || spr.curCharacter == 'spooky')
				{
					if (spr.animation.curAnim.name == 'danceRight')
						spr.playAnim('danceLeft');
					else
						spr.playAnim('danceRight');
				}
				else
				{
					spr.playAnim('idle');
				}
		});*/

		if (enabledMusicVideo && modLogo != null)
		{
			FlxTween.cancelTweensOf(modLogo);
			modLogo.scale.set(1.15, 1.15);
			FlxTween.tween(modLogo.scale, {x: 1, y: 1}, 0.35, {ease: FlxEase.quadOut});
		}
	}
}

class Mechanic
{
	public var name:String = '';
	public var description:String = '';
	public var image:String = '';
	public var points:Int = 0;

	public function new(name:String, description:String, image:String)
	{
		this.name = name;
		this.description = description;
		this.image = image;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var difficulty:Float = 0;
	public var bpm:Int = 0;

	public function new(song:String, week:Int, songCharacter:String, bpm:Int = 100)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.bpm = bpm;
	}
}
