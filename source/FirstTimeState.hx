package;

import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.scaleModes.RatioScaleMode;

class FirstTimeState extends MusicBeatState
{
	var firstTime:Alphabet;
	var infoText:FlxText;

	var assetPaths:Array<Dynamic> =
	[
		['alphabet', 'image'],
		['alphabet', 'frames'],
		['bgGrid', 'image', 'shared'],
		['FNF_main_menu_assets', 'image'],
		['FNF_main_menu_assets', 'frames'],
		['mechanic/button0', 'image', 'shared'],
		['mechanic/button1', 'image', 'shared'],
		['mechanic/button2', 'image', 'shared'],
		['mechanic/button3', 'image', 'shared'],
		['mechanic/button4', 'image', 'shared'],
		['discord', 'image'],
		['cursor', 'image', 'shared']
	];

	override function create()
	{
		super.create();

        var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
        diamond.persist = true;
        diamond.destroyOnNoUse = false;

        FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, -1),
            {asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
        FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
            {asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

        transIn = FlxTransitionableState.defaultTransIn;

		FlxG.sound.playMusic(Paths.music('menuSong/menuSong${Std.string(FlxG.random.int(1, 4))}'));
		FlxG.sound.music.volume = 0;

		PlayerSettings.init();
		PlayerSettings.setBindingsFromSave();

		#if tester
		trace('man is a tester');
		#end

		// DEBUG BULLSHIT

		#if !web
		trace("User data is " + 'platinum-' + Sys.getEnv("USERNAME"));
		FlxG.save.bind(Main.modName, 'platinum-' + Sys.getEnv("USERNAME"));
		#end

		FlxG.mouse.visible = false;

		Highscore.load();

		if (FlxG.save.data.weekUnlocked != null)
		{
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

		// FlxG.scaleMode = new RatioScaleMode(true);

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#else
		#end

		new FlxTimer().start(1.5, function(tmr:FlxTimer)
		{
			firstTime = new Alphabet(0, 0, "DEMO BUILD", true);
			firstTime.screenCenter();
			firstTime.y -= 240;
			add(firstTime);

            infoText = new FlxText(0, 0, FlxG.width, "THE MOD IS CURRENTLY WORK IN PROGRESS, EXPECT BUGS DURING GAMEPLAY!\nPLEASE SUPPORT ME BY GIVING IT ATTENTION!");
            infoText.setFormat(Paths.font('funkin', 'otf'), 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
            infoText.screenCenter();
            add(infoText);

			var loadingText:FlxText = new FlxText(0, 0, FlxG.width, "LOADING...");
            loadingText.setFormat(Paths.font('funkin', 'otf'), 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
            loadingText.screenCenter();
			loadingText.y = FlxG.height * 0.9;
            add(loadingText);

			for (asset in assetPaths)
			{
				var library:String = null;

				if (asset[2] != null)
					library = asset[2];
				
				Paths.preloadAsset(asset[0], asset[1], library);
			}

			new FlxTimer().start(5, function(tmr:FlxTimer)
			{
				FlxG.switchState(new MainMenuState());
			});
		});
	}
}
