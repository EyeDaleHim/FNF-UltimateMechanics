package;

import flixel.input.actions.FlxAction.FlxActionDigital;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.FlxSoundGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionInputDigital;
import flixel.input.keyboard.FlxKeyboard.FlxKeyInput;
import flixel.input.keyboard.FlxKey;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var isPaused:Bool = false;
	public static var lastSelected:Int = 0;

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;

	private var enemy:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	private static var notes:FlxTypedGroup<Note>;

	public static var unspawnNotes:Array<Note> = [];

	// unspawnNotes but without the enemies
	// not much anyways its just for the accuracy
	public var tweenInstances:Array<FlxTween> = [];

	private var playerAccuracy:Int = 0;

	private var strumLine:FlxSprite;

	private static var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var speedCam:Float;

	private var strumLineNotes:FlxTypedGroup<StrumLine>;
	private var playerStrums:FlxTypedGroup<StrumLine>;
	private var enemyStrums:FlxTypedGroup<StrumLine>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;

	public static var camHUD:FlxCamera;

	private var camGame:FlxCamera;

	private var keysText:FlxText;

	// the sprites were grouped was because to make it easier to control the grouped stuff
	public static var bgSprites:FlxTypedGroup<FlxSprite>;
	public static var characterSprites:FlxTypedGroup<Character>;

	public static var multiplier:Float = 1;

	var camSpeed:Float = 1;
	var noPressTime:Float = 5;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var forceBeat:Array<Int> = [];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;
	var spookySmokeBG:FlxSprite;
	var spookySmokeFG:FlxSprite;
	var spookOverlay:FlxSprite;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;
	var overlayRoof:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	var songScore:Int = 0;
	var fixedSongScore:String = '';
	var scoreTxt:FlxText;
	var timerText:FlxText;

	var animOrder:Map<String, Int> = new Map();

	var accuracy:Float = 0.00;
	var ratingList:Array<Float> = [0, 0, 0, 0];
	var lastNoteDiff:Float = 0;
	var totalRanksHit:Float = 0;
	var totalNotesHit:Float = 0;

	var botplayTxt:FlxText;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	var timerLeft:Float = 0;
	var curLight:Int = 0;

	// use this to fix timer
	var fakeInst:FlxSound;
	var songHasStarted:Bool = false;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#else
	var songLength:Float = 0;
	#end

	public var misses:Int = 0;

	public var downscroll:Bool;
	public var ghostTap:Bool;
	public var accuracyType:String;
	public var debugCutscene:Bool;
	public var antialiasing:Bool;
	public var quality:String;
	public var scoreType:String;

	var healthDrainInterval:Float = 2000 - (100 * MainMenuState.mechanics[3].points) + 100;

	var warningSprite:FlxSprite;
	var sawBladeSprite:FlxSprite;
	var trickyGremlin:FlxSprite;
	var playerDead:Bool = false;

	public static var instance:PlayState;

	override public function create()
	{
		// initalize settings
		downscroll = Settings.downscroll;
		ghostTap = Settings.ghostTap;
		quality = FlxG.save.data.quality;
		antialiasing = Settings.antialiasing;

		animOrder = ['singLEFT' => 0, 'singDOWN' => 1, 'singUP' => 2, 'singRIGHT' => 3];

		dumbStrums = [];

		#if debug
		debugCutscene = true;
		#else
		debugCutscene = false;
		#end

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		fakeInst = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		// assume that you cant beat songs without hitting a single note
		/*for (song in storyPlaylist)
			{

		}*/

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		switch (SONG.song.toLowerCase())
		{
			case 'senpai' | 'roses' | 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('${SONG.song.toLowerCase()}/${SONG.song.toLowerCase()}' + 'Dialogue'));
		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end

		bgSprites = new FlxTypedGroup<FlxSprite>();
		add(bgSprites);

		switch (SONG.song.toLowerCase())
		{
			case 'spookeez' | 'monster' | 'south':
				{
					curStage = 'spooky';
					halloweenLevel = true;

					var hallowTex = Paths.getSparrowAtlas('halloween_bg');

					halloweenBG = new FlxSprite(-200, -100);
					halloweenBG.frames = hallowTex;
					halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
					halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
					halloweenBG.animation.play('idle');
					halloweenBG.antialiasing = Settings.antialiasing;
					bgSprites.add(halloweenBG);

					if (quality == 'high')
					{
						spookySmokeBG = new FlxSprite(-400, -100).loadGraphic(Paths.image('smokeBG'));
						spookySmokeBG.antialiasing = Settings.antialiasing;
						tweenInstances.push(FlxTween.tween(spookySmokeBG, {x: -500}, (Conductor.crochet / 1000) * 12,
							{ease: FlxEase.smoothStepInOut, type: PINGPONG}));
						bgSprites.add(spookySmokeBG);

						spookySmokeFG = new FlxSprite(-300, -100).loadGraphic(Paths.image('smokeFG'));
						spookySmokeFG.antialiasing = Settings.antialiasing;
						tweenInstances.push(FlxTween.tween(spookySmokeFG, {x: -200}, (Conductor.crochet / 1000) * 12,
							{ease: FlxEase.smoothStepInOut, type: PINGPONG}));
						spookySmokeFG.setGraphicSize(Std.int(spookySmokeFG.width * 1.6));

						spookOverlay = new FlxSprite(-1000, -1000).makeGraphic(FlxG.width * 10, FlxG.height * 10, 0xFF164987);
						spookOverlay.antialiasing = Settings.antialiasing;
						spookOverlay.alpha = 0.15;
					}

					isHalloween = true;
				}
			case 'pico' | 'blammed' | 'philly':
				{
					curStage = 'philly';

					var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
					bg.scrollFactor.set(0.1, 0.1);
					bg.antialiasing = Settings.antialiasing;
					bgSprites.add(bg);

					if (quality != 'medium' && quality != 'low')
					{
						var cityBG:FlxSprite = new FlxSprite(-25, 150).loadGraphic(Paths.image('philly/city_bg'));
						cityBG.scrollFactor.set(0.25, 0.25);
						cityBG.setGraphicSize(Std.int(cityBG.width * 0.9));
						cityBG.updateHitbox();
						cityBG.antialiasing = Settings.antialiasing;
						bgSprites.add(cityBG);
					}

					var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
					city.scrollFactor.set(0.3, 0.3);
					city.setGraphicSize(Std.int(city.width * 0.85));
					city.updateHitbox();
					city.antialiasing = Settings.antialiasing;
					bgSprites.add(city);

					phillyCityLights = new FlxTypedGroup<FlxSprite>();
					add(phillyCityLights);

					for (i in 0...5)
					{
						var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i));
						light.scrollFactor.set(0.3, 0.3);
						light.visible = false;
						light.setGraphicSize(Std.int(light.width * 0.85));
						light.updateHitbox();
						light.antialiasing = Settings.antialiasing;
						phillyCityLights.add(light);
					}

					var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
					streetBehind.antialiasing = Settings.antialiasing;
					add(streetBehind);

					phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
					phillyTrain.antialiasing = Settings.antialiasing;
					add(phillyTrain);

					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
					trainSound.volume = FlxG.save.data.soundVolume / 100;
					FlxG.sound.list.add(trainSound);

					// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

					var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
					street.antialiasing = Settings.antialiasing;
					add(street);

					if (quality == 'high')
					{
						var poster:FlxSprite = new FlxSprite(1210, 440).loadGraphic(Paths.image('philly/pico_poster'));
						poster.antialiasing = Settings.antialiasing;
						add(poster);
					}
				}
			case 'milf' | 'satin-panties' | 'high':
				{
					curStage = 'limo';
					defaultCamZoom = 0.90;

					var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
					skyBG.scrollFactor.set(0.1, 0.1);
					bgSprites.add(skyBG);

					if (quality == 'high')
					{
						var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
						overlayShit.alpha = 0.5;
						bgSprites.add(overlayShit);
					}

					var bgLimo:FlxSprite = new FlxSprite(-200, 480);
					bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
					bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
					bgLimo.animation.play('drive');
					bgLimo.scrollFactor.set(0.4, 0.4);
					bgSprites.add(bgLimo);

					if (quality != 'low')
					{
						grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
						add(grpLimoDancers);

						for (i in 0...5)
						{
							var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
							dancer.scrollFactor.set(0.4, 0.4);
							grpLimoDancers.add(dancer);
						}
					}

					var limoTex = Paths.getSparrowAtlas('limo/limoDrive');

					limo = new FlxSprite(-120, 550);
					limo.frames = limoTex;
					limo.animation.addByPrefix('drive', "Limo stage", 24);
					limo.animation.play('drive');
					limo.antialiasing = Settings.antialiasing;

					fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
					// add(limo);

					if (quality == 'high')
					{
						var glowy:FlxSprite = new FlxSprite(0, 40).loadGraphic(Paths.image('limo/glowy'));
						glowy.cameras = [camHUD];
						glowy.antialiasing = Settings.antialiasing;
						glowy.alpha = 0.2;
						glowy.scrollFactor.set();
						tweenInstances.push(FlxTween.tween(glowy, {alpha: 0.8}, Conductor.crochet / 1000 * 4, {ease: FlxEase.quadInOut, type: PINGPONG}));
						bgSprites.add(glowy);
					}
				}
			case 'cocoa' | 'eggnog':
				{
					curStage = 'mall';

					defaultCamZoom = 0.80;

					var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
					bg.antialiasing = Settings.antialiasing;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					bgSprites.add(bg);

					if (quality != 'low')
					{
						upperBoppers = new FlxSprite(-240, -90);
						upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
						upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
						upperBoppers.antialiasing = Settings.antialiasing;
						upperBoppers.scrollFactor.set(0.33, 0.33);
						upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
						upperBoppers.updateHitbox();
						bgSprites.add(upperBoppers);
					}

					var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
					bgEscalator.antialiasing = Settings.antialiasing;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.active = false;
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					bgSprites.add(bgEscalator);

					var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
					tree.antialiasing = Settings.antialiasing;
					tree.scrollFactor.set(0.40, 0.40);
					bgSprites.add(tree);

					if (quality != 'low')
					{
						bottomBoppers = new FlxSprite(-300, 140);
						bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
						bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
						bottomBoppers.antialiasing = Settings.antialiasing;
						bottomBoppers.scrollFactor.set(0.9, 0.9);
						bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
						bottomBoppers.updateHitbox();
						bgSprites.add(bottomBoppers);
					}

					var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
					fgSnow.active = false;
					fgSnow.antialiasing = Settings.antialiasing;
					bgSprites.add(fgSnow);

					santa = new FlxSprite(-840, 150);
					santa.frames = Paths.getSparrowAtlas('christmas/santa');
					santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
					santa.antialiasing = Settings.antialiasing;

					if (quality == 'high')
					{
						overlayRoof = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgSkyGradient'));
						overlayRoof.antialiasing = Settings.antialiasing;
						overlayRoof.setGraphicSize(Std.int(overlayRoof.width), Std.int(overlayRoof.height * 1.4));
						overlayRoof.updateHitbox();
						overlayRoof.scrollFactor.set(0.05, 0.05);
					}
				}
			case 'winter-horrorland':
				{
					curStage = 'mallEvil';
					var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
					bg.antialiasing = Settings.antialiasing;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					bgSprites.add(bg);

					var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
					evilTree.antialiasing = Settings.antialiasing;
					evilTree.scrollFactor.set(0.2, 0.2);
					bgSprites.add(evilTree);

					var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
					evilSnow.antialiasing = Settings.antialiasing;
					bgSprites.add(evilSnow);
				}
			case 'senpai' | 'roses':
				{
					curStage = 'school';

					// defaultCamZoom = 0.9;

					var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
					bgSky.scrollFactor.set(0.1, 0.1);
					bgSprites.add(bgSky);

					var repositionShit = -200;

					if (quality == 'high')
					{
						var bgMountain:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebMountain'));
						bgMountain.scrollFactor.set(0.5, 0.80);
						bgSprites.add(bgMountain);
					}

					var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
					bgSchool.scrollFactor.set(0.6, 0.90);
					bgSprites.add(bgSchool);

					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
					bgStreet.scrollFactor.set(0.95, 0.95);
					bgSprites.add(bgStreet);

					var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
					fgTrees.scrollFactor.set(0.9, 0.9);
					bgSprites.add(fgTrees);

					var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
					var treetex = Paths.getPackerAtlas('weeb/weebTrees');
					bgTrees.frames = treetex;
					bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
					bgTrees.animation.play('treeLoop');
					bgTrees.scrollFactor.set(0.85, 0.85);
					bgSprites.add(bgTrees);

					var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);

					if (quality != 'low')
					{
						treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
						treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
						treeLeaves.animation.play('leaves');
						treeLeaves.scrollFactor.set(0.85, 0.85);
						bgSprites.add(treeLeaves);
					}

					var widShit = Std.int(bgSky.width * 6);

					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);
					bgTrees.setGraphicSize(Std.int(widShit * 1.4));
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					treeLeaves.setGraphicSize(widShit);

					fgTrees.updateHitbox();
					bgSky.updateHitbox();
					bgSchool.updateHitbox();
					bgStreet.updateHitbox();
					bgTrees.updateHitbox();
					treeLeaves.updateHitbox();

					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					if (SONG.song.toLowerCase() == 'roses')
					{
						bgGirls.getScared();
					}

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					bgSprites.add(bgGirls);
				}
			case 'thorns':
				{
					curStage = 'schoolEvil';

					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

					var posX = 400;
					var posY = 200;

					var bg:FlxSprite = new FlxSprite(posX, posY);
					bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
					bg.animation.addByPrefix('idle', 'background 2', 24);
					if (quality != 'low')
						bg.animation.play('idle');
					bg.scrollFactor.set(0.8, 0.9);
					bg.scale.set(6, 6);
					bgSprites.add(bg);

					/* 
						var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
						bg.scale.set(6, 6);
						// bg.setGraphicSize(Std.int(bg.width * 6));
						// bg.updateHitbox();
						add(bg);

						var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
						fg.scale.set(6, 6);
						// fg.setGraphicSize(Std.int(fg.width * 6));
						// fg.updateHitbox();
						add(fg);

						wiggleShit.effectType = WiggleEffectType.DREAMY;
						wiggleShit.waveAmplitude = 0.01;
						wiggleShit.waveFrequency = 60;
						wiggleShit.waveSpeed = 0.8;
					 */

					// bg.shader = wiggleShit.shader;
					// fg.shader = wiggleShit.shader;

					/* 
						var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
						var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);

						// Using scale since setGraphicSize() doesnt work???
						waveSprite.scale.set(6, 6);
						waveSpriteFG.scale.set(6, 6);
						waveSprite.setPosition(posX, posY);
						waveSpriteFG.setPosition(posX, posY);

						waveSprite.scrollFactor.set(0.7, 0.8);
						waveSpriteFG.scrollFactor.set(0.9, 0.8);

						// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
						// waveSprite.updateHitbox();
						// waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
						// waveSpriteFG.updateHitbox();

						add(waveSprite);
						add(waveSpriteFG);
					 */
				}
			default:
				{
					defaultCamZoom = 0.9;
					curStage = 'stage';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
					bg.antialiasing = Settings.antialiasing;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					bgSprites.add(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = Settings.antialiasing;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					bgSprites.add(stageFront);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = Settings.antialiasing;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;

					bgSprites.add(stageCurtains);
				}
		}

		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
		}

		if (curStage == 'limo')
			gfVersion = 'gf-car';

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		enemy = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(enemy.getGraphicMidpoint().x, enemy.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				enemy.setPosition(gf.x, gf.y);
				gf.visible = false;

			case "spooky":
				enemy.y += 200;
			case "monster":
				enemy.y += 100;
			case 'monster-christmas':
				enemy.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				enemy.y += 300;
			case 'parents-christmas':
				enemy.x -= 500;
			case 'senpai':
				enemy.x += 150;
				enemy.y += 360;
				camPos.set(enemy.getGraphicMidpoint().x + 310, enemy.getGraphicMidpoint().y);
			case 'senpai-angry':
				enemy.x += 150;
				enemy.y += 360;
				camPos.set(enemy.getGraphicMidpoint().x + 310, enemy.getGraphicMidpoint().y);
			case 'spirit':
				enemy.x -= 150;
				enemy.y += 100;
				camPos.set(enemy.getGraphicMidpoint().x + 300, enemy.getGraphicMidpoint().y);
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				enemy.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(enemy, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
		}

		characterSprites = new FlxTypedGroup<Character>();
		add(characterSprites);

		characterSprites.add(gf);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		characterSprites.add(enemy);
		// do this cuz he's behind it
		if (curStage != 'limo')
			characterSprites.add(boyfriend);
		else
			add(boyfriend);

		if (curStage == 'spooky' && quality == 'high')
		{
			bgSprites.add(spookySmokeFG);
			add(spookOverlay);
			// idk
			// boyfriend.setColorTransform(1, 1, 1, 1, 0, Std.int(74 / 4), 88, 0);
		}

		// layering shit for santa duwb
		if (curStage == 'mall')
		{
			bgSprites.add(santa);
			bgSprites.add(overlayRoof);
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		if (downscroll)
			strumLine = new FlxSprite(0, 550).makeGraphic(FlxG.width, 10);
		else
			strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);

		strumLine.scrollFactor.set();
		if (downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<StrumLine>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<StrumLine>();
		enemyStrums = new FlxTypedGroup<StrumLine>();

		// startCountdown();

		generateSong(SONG.song);
		trace(swapNote1);

		if (MainMenuState.mechanics[10].points != 0 || MainMenuState.mechanics[11].points != 0)
		{
			warningSprite = new FlxSprite();
			warningSprite.frames = Paths.getSparrowAtlas('termination/attack_alert_NEW', null, false);
			warningSprite.animation.addByPrefix('alertSINGLE', 'kb_attack_animation_alert-single', 24, false);
			warningSprite.animation.addByPrefix('alertDOUBLE', 'kb_attack_animation_alert-double', 24, false);
			warningSprite.setGraphicSize(Std.int(warningSprite.width * 1.5));
			warningSprite.screenCenter();
			warningSprite.antialiasing = true;
			warningSprite.x = FlxG.width - 700;
			warningSprite.y = 205;
			warningSprite.cameras = [camHUD];
			warningSprite.visible = false;

			sawBladeSprite = new FlxSprite();
			sawBladeSprite.frames = Paths.getSparrowAtlas('termination/attackv6', null, false);
			sawBladeSprite.animation.addByPrefix('prepare', 'kb_attack_animation_prepare', 24, false);
			sawBladeSprite.animation.addByPrefix('attack', 'kb_attack_animation_fire', 24, false);
			sawBladeSprite.setGraphicSize(Std.int(sawBladeSprite.width * 1.15));
			sawBladeSprite.setPosition(-860, 615);
			// sawBladeSprite.screenCenter();
			sawBladeSprite.visible = false;

			add(warningSprite);
			add(sawBladeSprite);
		}

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y - 15);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, (0.04 * (30 / Main.framerate)) / camSpeed);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, downscroll ? FlxG.height * 0.1 : FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(CharacterColor.color(enemy.curCharacter), CharacterColor.color(boyfriend.curCharacter));
		if (quality == 'high')
			healthBar.numDivisions = 1000;
		add(healthBar);

		scoreTxt = new FlxText(healthBarBG.x - 105, healthBarBG.y + healthBarBG.height + 10, 800, "", 22);
		scoreTxt.setFormat("assets/fonts/vcr.ttf", 22, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.antialiasing = true;

		timerText = new FlxText(healthBarBG.x - 105, downscroll ? FlxG.height * 0.9 : FlxG.height * 0.1, 800, "", 30);
		timerText.y = strumLine.y + 45;
		timerText.x -= 40;
		timerText.setFormat("assets/fonts/vcr.ttf", 30, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timerText.scrollFactor.set();
		timerText.antialiasing = true;

		botplayTxt = new FlxText(0, downscroll ? scoreTxt.y + 45 : scoreTxt.y - 45, 0, "BOTPLAY", 22);
		botplayTxt.setFormat("assets/fonts/vcr.ttf", 22, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.screenCenter(X);
		botplayTxt.alpha = 0;

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.antialiasing = true;
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.antialiasing = true;
		add(iconP2);

		add(scoreTxt);
		add(timerText);
		add(botplayTxt);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		timerText.cameras = [camHUD];
		doof.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode || debugCutscene)
		{
			switch (curSong.toLowerCase())
			{
				case 'monster':
					camHUD.alpha = 0;

					var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
					black.scrollFactor.set();
					add(black);

					FlxG.camera.zoom = 2.6;
					FlxG.camera.focusOn(camFollow.getPosition());
					camFollow.x += 800;
					camFollow.y -= 350;

					new FlxTimer().start(0.7, function(tmr:FlxTimer)
					{
						tweenInstances.push(FlxTween.tween(black, {alpha: 0}, 0.3, {ease: FlxEase.quintOut}));
					});

					new FlxTimer().start(1.4, function(tmr:FlxTimer)
					{
						tweenInstances.push(FlxTween.tween(camFollow, {x: gf.getGraphicMidpoint().x, y: gf.getGraphicMidpoint().y - 15}, 3.4,
							{ease: FlxEase.quintInOut}));
						tweenInstances.push(FlxTween.tween(camHUD, {alpha: 1}, 2.5, {ease: FlxEase.quintInOut}));
						tweenInstances.push(FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 3, {
							ease: FlxEase.quintInOut,
							onComplete: function(twn:FlxTween)
							{
								startCountdown();
							}
						}));
					});

				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.alpha = 0;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'), FlxG.save.data.soundVolume / 100);
						camFollow.y = -2050;
						camFollow.x = gf.getGraphicMidpoint().x;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							tweenInstances.push(FlxTween.tween(camHUD, {alpha: 1}, 2.5, {ease: FlxEase.quintInOut}));
							remove(blackScreen);
							tweenInstances.push(FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							}));
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					if (isStoryMode || debugCutscene)
						FlxG.sound.play(Paths.sound('ANGRY'), FlxG.save.data.soundVolume / 100);
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		super.create();

		PlayState.instance = this;
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		timerText.alpha = 0;
		iconP1.alpha = 0;
		iconP2.alpha = 0;
		healthBarBG.alpha = 0;
		healthBar.alpha = 0;
		scoreTxt.alpha = 0;

		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var blackT:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		blackT.scrollFactor.set();
		if (curSong.toLowerCase() != 'roses')
			add(blackT);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if ((SONG.song.toLowerCase() == 'thorns'))
			add(blackT);

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.15, function(fadeTimer:FlxTimer)
		{
			blackT.alpha -= 0.1;
			fadeTimer.reset(0.15);
		});

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			var coolFades:Array<Float> = [0.15, 0.3];
			black.alpha -= coolFades[0];

			if (black.alpha > 0)
			{
				tmr.reset(coolFades[1]);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), FlxG.save.data.soundVolume / 100, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									remove(blackT);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		new FlxTimer().start(0.15, function(fadeTimer:FlxTimer)
		{
			timerText.alpha += 0.1;
			iconP1.alpha += 0.1;
			iconP2.alpha += 0.1;
			healthBarBG.alpha += 0.1;
			healthBar.alpha += 0.1;
			scoreTxt.alpha += 0.1;
			if (timerText.alpha < 1)
				fadeTimer.reset(0.15);
		});

		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			enemy.dance();
			gf.dance();
			boyfriend.playAnim('idle');
			if (curStage == 'mall')
				santa.animation.play('idle', true);

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
				}
			}

			if (curStage.startsWith('school'))
				altSuffix = '-pixel';

			switch (swagCounter)

			{
				case 0:
					if (FlxG.save.data.soundVolume > 60)
						FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
					else
						FlxG.sound.play(Paths.sound('intro3' + altSuffix), FlxG.save.data.soundVolume / 100);
					if (curStage == 'mallEvil' && debugCutscene || curStage == 'mallEvil' && isStoryMode)
						updateCam(3);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					if (!curStage.endsWith('school'))
						ready.antialiasing = true;
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					tweenInstances.push(FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					}));
					if (FlxG.save.data.soundVolume > 60)
						FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
					else
						FlxG.sound.play(Paths.sound('intro2' + altSuffix), FlxG.save.data.soundVolume / 100);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();
					if (!curStage.endsWith('school'))
						set.antialiasing = true;
					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					if (FlxG.save.data.soundVolume > 60)
						FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
					else
						FlxG.sound.play(Paths.sound('intro1' + altSuffix), FlxG.save.data.soundVolume / 100);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();
					if (!curStage.endsWith('school'))
						go.antialiasing = true;

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					if (FlxG.save.data.soundVolume > 60)
						FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
					else
						FlxG.sound.play(Paths.sound('introGo' + altSuffix), FlxG.save.data.soundVolume / 100);
				case 4:
					songHasStarted = true;
					if (curStage == 'mallEvil' && debugCutscene || curStage == 'mallEvil' && isStoryMode)
						updateCam(1);
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end
	}

	var curNoteType:String = '';

	function updateAccuracy():Float
	{
		var truncateAccuracy = 0.00;

		accuracy = totalRanksHit / (misses + (playerAccuracy)) * 100;

		if (accuracy > 100)
			accuracy = 100;

		if (accuracy < 0)
			accuracy = 0;

		truncateAccuracy = MathUtils.truncateFloat(accuracy, 2);

		if (truncateAccuracy < 0)
			truncateAccuracy = 0;
		if (truncateAccuracy > 100)
			truncateAccuracy = 100;

		return truncateAccuracy;
	}

	function truncateFloat(number:Float, precision:Int):Float
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	var debugNum:Int = 0;

	var sawBlades:Array<Dynamic> = [];

	static var swapNote1:Array<Dynamic> = [];

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;

		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var weightedChance:Float = 0;
		var doubleChanceWeight:Float = 0;
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);
			var trickyNoteAmt:Int = FlxG.random.int(1, 4);
			var sectionIsHit:Bool = section.mustHitSection;

			if (MainMenuState.mechanics[7].points != 0)
			{
				var chanceOffset:Float = 0;

				if (section.sectionNotes.length == 0)
				{
					chanceOffset = 0.25;
				}

				if (FlxG.random.bool(7.5 + ((0.3 + chanceOffset) * MainMenuState.mechanics[7].points)))
				{
					swapNote1.push(coolSection);
				}
				else
				{
					swapNote1.push(null);
				}
			}

			if (coolSection > 2 && section.sectionNotes.length != 0)
			{
				if (MainMenuState.mechanics[10].points != 0)
				{
					if (FlxG.random.bool(15 + (1.25 * MainMenuState.mechanics[10].points) + weightedChance))
					{
						sawBlades.push([coolSection, false]);
						weightedChance = 0;
					}
					else
					{
						sawBlades.push(null);
						weightedChance += 0.15 + (0.05 * MainMenuState.mechanics[10].points);
					}
				}

				if (MainMenuState.mechanics[11].points != 0)
				{
					if (FlxG.random.bool(7.5 + (0.75 * MainMenuState.mechanics[11].points) + doubleChanceWeight))
					{
						if (sawBlades.length != 0)
						{
							sawBlades[coolSection] = [coolSection, true];
							doubleChanceWeight = 0;
						}
						else
						{
							sawBlades.push([coolSection, false]);
							doubleChanceWeight += 0.1 + (0.025 * MainMenuState.mechanics[10].points);
						}
					}
				}
			}

			/*
				var neatSection:Bool = FlxG.random.bool(15 + (0.50 * MainMenuState.mechanics[0].points));
				if (sectionIsHit)
				{
					for (i in 0...trickyNoteAmt)
					{
						if (neatSection)
						{
							var type:String = '';
							if (FlxG.random.bool(2.5 + (0.15 * MainMenuState.mechanics[1].points)))
								type = 'halo';
							else
								type = 'fire';

							var dataValInititive:Int = 0;

							if (type == 'halo')
								dataValInititive = -4;
							else if (type == 'fire')
								dataValInititive = 7;
							var trickyNote:Note;
							trickyNote = new Note(Conductor.stepCrochet * (noteData.indexOf(section) + FlxG.random.int(1, coolSection)),
								dataValInititive + FlxG.random.int(0, 3));
							trickyNote.scrollFactor.set();
							trickyNote.noteType = type;
							unspawnNotes.push(trickyNote);
						}
					}
			}*/

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + Conductor.offset;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);
				swagNote.noteType = 'normal';
				if (MainMenuState.mechanics[2].points != 0)
				{
					swagNote.noteSwap = FlxG.random.bool(7.5 + (1.5 * MainMenuState.mechanics[2].points));
					swagNote.nextSwap = FlxG.random.int(0, 3, [swagNote.noteData]);
				}
				else
					swagNote.noteSwap = false;
				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				if (MainMenuState.mechanics[8].points != 0)
				{
					// if random notes is enabled, just replace it with halo or fire notes
					if (FlxG.random.bool(6.5 + ((1.25 * MainMenuState.mechanics[8].points) / 2)))
					{
						var randomNote:Note = new Note(daStrumTime, FlxG.random.int(0, 3, [daNoteData, swagNote.nextSwap]), oldNote);
						randomNote.scrollFactor.set(0, 0);
						randomNote.noteType = 'gen1';
						randomNote.mustPress = gottaHitNote;

						unspawnNotes.push(randomNote);
						if (randomNote.mustPress)
							playerAccuracy++;

						if (randomNote.mustPress)
						{
							randomNote.x += FlxG.width / 2; // general offset
						}
					}
				}

				// a
				if (gottaHitNote)
					playerAccuracy++;

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					sustainNote.noteType = 'normal';
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;
					sustainNote.noteSwap = swagNote.noteSwap;
					sustainNote.nextSwap = swagNote.nextSwap;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;

		trace('SONG INFORMATION:');
		var tempString:String = '';

		var tempSpawn:Array<Dynamic> = [
			SONG.song,
			SONG.bpm,
			SONG.needsVoices,
			SONG.player1,
			SONG.player2,
			SONG.gf,
			SONG.speed,
			SONG.camera,
			SONG.validScore
		];

		var stuffThingie:Array<String> = [
			'NAME: ',
			'BPM: ',
			'HAS VOCALS: ',
			'PLAYER 1: ',
			'PLAYER 2: ',
			'GIRLFRIEND: ',
			'SONG SPEED: ',
			'DYNAMIC CAMERA: ',
			'IS VALID SCORE: '
		];

		for (i in 0...tempSpawn.length)
		{
			tempString += '\n				' + stuffThingie[i] + tempSpawn[i];
			tempString += ', ';
		}

		tempString += '\n				V1.03-BETA V1';

		trace(tempString);

		/*
			_song = {
				song: 'Test',
				notes: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				gf: 'gf',
				speed: 1,
				camera: false,
				validScore: false
		};*/
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			strumLine.x += 10;

			// FlxG.log.add(i);
			var babyArrow:StrumLine = new StrumLine(0, strumLine.y);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					{
						babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
						babyArrow.animation.add('green', [6]);
						babyArrow.animation.add('red', [7]);
						babyArrow.animation.add('blue', [5]);
						babyArrow.animation.add('purplel', [4]);

						babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
						babyArrow.updateHitbox();
						babyArrow.antialiasing = false;

						switch (Math.abs(i))
						{
							case 0:
								babyArrow.x += Note.swagWidth * 0;
								babyArrow.animation.add('static', [0]);
								babyArrow.animation.add('pressed', [4, 8], 12, false);
								babyArrow.animation.add('confirm', [12, 16], 24, false);
							case 1:
								babyArrow.x += Note.swagWidth * 1;
								babyArrow.animation.add('static', [1]);
								babyArrow.animation.add('pressed', [5, 9], 12, false);
								babyArrow.animation.add('confirm', [13, 17], 24, false);
							case 2:
								babyArrow.x += Note.swagWidth * 2;
								babyArrow.animation.add('static', [2]);
								babyArrow.animation.add('pressed', [6, 10], 12, false);
								babyArrow.animation.add('confirm', [14, 18], 12, false);
							case 3:
								babyArrow.x += Note.swagWidth * 3;
								babyArrow.animation.add('static', [3]);
								babyArrow.animation.add('pressed', [7, 11], 12, false);
								babyArrow.animation.add('confirm', [15, 19], 24, false);
						}
					}
				default:
					{
						babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
						babyArrow.animation.addByPrefix('green', 'arrowUP');
						babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
						babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
						babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

						babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

						switch (Math.abs(i))
						{
							case 0:
								babyArrow.x += Note.swagWidth * 0;
								babyArrow.animation.addByPrefix('static', 'arrowLEFT');
								babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
							case 1:
								babyArrow.x += Note.swagWidth * 1;
								babyArrow.animation.addByPrefix('static', 'arrowDOWN');
								babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
							case 2:
								babyArrow.x += Note.swagWidth * 2;
								babyArrow.animation.addByPrefix('static', 'arrowUP');
								babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
							case 3:
								babyArrow.x += Note.swagWidth * 3;
								babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
								babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
						}

						babyArrow.antialiasing = Settings.antialiasing;
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			// idk any other ways to do it so i just do this
			var noSongFadeArrows:Array<String> = [
				'fresh',
				'dadbattle',
				'south',
				'monster',
				'philly',
				'blammed',
				'high',
				'milf',
				'eggnog'
			];

			if (!noSongFadeArrows.contains(SONG.song.toLowerCase()) && isStoryMode || debugCutscene)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;

				switch (curStage)
				{
					case 'school' | 'schoolEvil':
						new FlxTimer().start(0.35 * i, function(tmr:FlxTimer)
						{
							new FlxTimer().start(0.15, function(tmr:FlxTimer)
							{
								if (babyArrow.y < strumLine.y)
									babyArrow.y += 2.5;
								if (babyArrow.alpha < 1)
									babyArrow.alpha += 0.25;
								if (babyArrow.y < strumLine.y || babyArrow.alpha < 1)
									tmr.reset(0.15);
							});
						});
					default:
						FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
				}
			}

			babyArrow.ID = i;
			babyArrow.noteData = babyArrow.ID;
			babyArrow.setDataPosition(babyArrow.ID);

			switch (player)
			{
				case 0:
					enemyStrums.add(babyArrow);
					babyArrow.animation.finishCallback = function(name:String)
					{
						if (name == "confirm")
						{
							babyArrow.animation.play('static', true);
							babyArrow.centerOffsets();
						}
					}

				case 1:
					playerStrums.add(babyArrow);
					dumbStrums.push(babyArrow.currentNotePos);
					if (FlxG.save.data.botplay)
					{
						babyArrow.animation.finishCallback = function(name:String)
						{
							if (name == "confirm")
							{
								babyArrow.animation.play('static', true);
								babyArrow.centerOffsets();
							}
						}
					}
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);
			// trace(babyArrow.x);

			enemyStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets();
			});

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;

			FlxG.camera.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;
			FlxG.camera.active = true;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
			#end
			if (generatedMusic && unspawnNotes.length == 0 && songScore != 0)
				endSong();
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		// use an isPaused bool but not somewhere else :)
		// apparently this causes issues
		/*if (startedCountdown && canPause && !isPaused)
			{
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;
				FlxG.camera.active = true;

				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}*/

		super.onFocusLost();
	}

	/*
		public static function changeSettings()
		{
			downscroll = FlxG.save.data.downscroll;
			// you're unfair, no ghosttapping and accuracy
			// ghostTap = FlxG.save.data.ghostTap;
			//accuracyType = FlxG.save.data.accuracy;
			quality = FlxG.save.data.quality;
			antialiasing = FlxG.save.data.antialiasing;
			bgSprites.forEach(function(spr:FlxSprite)
			{
				spr.antialiasing = Settings.antialiasing;
			});
	}*/
	function resyncVocals():Void
	{
		if (unspawnNotes.length != 0)
		{
			vocals.pause();

			FlxG.sound.music.play();
			Conductor.songPosition = FlxG.sound.music.time;
			vocals.time = Conductor.songPosition;
			vocals.time = Conductor.songPosition;
			vocals.play();
		}
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var stopFocusing:Bool = false;

	var triggeredCamera:Bool = false;

	var beatList:Array<Dynamic> = [];

	var invulnToSawblade:Bool = false;

	function fixAccDisplay(accuracy:String):String
	{
		for (i in 0...accuracy.length)
		{
			if (accuracy.charAt(i) == '.')
			{
				if (accuracy.charAt(i + 2) == '')
				{
					accuracy += '0';
					break;
				}
			}
		}

		return accuracy;
	}

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		if (FlxG.save.data.botplay)
			SONG.validScore = false;

		if (generatedMusic && (MainMenuState.mechanics[10].points != 0 || MainMenuState.mechanics[11].points != 0))
		{
			if (FlxG.save.data.botplay)
				invulnToSawblade = true;
			else
			{
				if (FlxG.keys.justPressed.SPACE && !invulnToSawblade)
				{
					if (boyfriend.animOffsets.exists('dodge'))
						boyfriend.playAnim('dodge');
					invulnToSawblade = true;

					var cooldown:Float = 0.35;

					if (sawBlades[curSection] != null)
					{
						if (sawBlades[curSection][1] == true)
							cooldown = 0.15;
					}

					new FlxTimer().start(cooldown, function(tmr:FlxTimer)
					{
						invulnToSawblade = false;
						boyfriend.dance();
					});
				}
			}
		}

		// changeSettings();

		FlxG.sound.music.volume = FlxG.save.data.musicVolume / 100;
		vocals.volume = FlxG.save.data.vocalVolume / 100;

		if (noPressTime > 0)
			noPressTime -= elapsed / 1000;

		// dividing it by 1000 is seconds.

		if (!songHasStarted)
			timerLeft = fakeInst.length / 1000;
		else
			timerLeft = (songLength - Conductor.songPosition) / 1000;
		timerText.text = FlxStringUtil.formatTime(timerLeft, false);

		fixedSongScore = FlxStringUtil.formatMoney(songScore, false, true);

		// fix the hair stop bug
		if (curStage == 'limo')
		{
			if (enemy.animation.curAnim.finished && !enemy.animation.curAnim.name.startsWith("sing"))
				enemy.dance();
			if (/*!boyfriend.animation.curAnim.name == 'idle' &&*/ boyfriend.animation.curAnim.finished
				&& !boyfriend.animation.curAnim.name.startsWith("sing"))
				boyfriend.playAnim('idle', true);
		}

		if (FlxG.save.data.botplay)
			botplayTxt.alpha = 0.25;

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		if (!curStage.startsWith('school'))
		{
			strumLineNotes.forEach(function(spr:FlxSprite)
			{
				spr.antialiasing = Settings.antialiasing;
			});
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				phillyCityLights.members[curLight].alpha -= ((Conductor.crochet / 1000) * FlxG.elapsed) * 1.2;
		}

		if (MainMenuState.mechanics[3].points != 0 && Conductor.songPosition > 0 && generatedMusic && !trickyGrabbed)
		{
			healthDrainInterval -= 100 * elapsed;

			if (healthDrainInterval < 0)
			{
				healthDrainInterval = 2000 - (100 * MainMenuState.mechanics[3].points) + 100;
				if (!trickyGrabbed)
				{
					if (health - 0.04 <= 0)
						health = 0.04;
					else
						health -= 0.04;
				}
				else
				{
					trickyDmg += 0.04;
				}
			}
		}

		super.update(elapsed);

		var trueAccuracy:Float = 0.0;

		trueAccuracy = MathUtils.truncateFloat((totalRanksHit / (totalNotesHit + misses)) * 100, 2);

		if (trueAccuracy < 0)
			trueAccuracy = 0;

		var stringAcc:String = '';

		if (trueAccuracy - updateAccuracy() > 2.5)
			stringAcc = ' (${fixAccDisplay(Std.string(trueAccuracy))}%)';

		var accuracyDisplay:Float = 0;

		accuracyDisplay = MathUtils.wrap(FlxMath.roundDecimal(totalRanksHit / (misses + (playerAccuracy)) * 100, 2), 0, 100);
		if (Math.isNaN(accuracyDisplay))
			accuracyDisplay = 0;

		scoreTxt.text = "Score: " + fixedSongScore + ' (${multiplier}x)' + " | " + misses + " Misses" + " | " + "Accuracy: "
			+ fixAccDisplay(Std.string(accuracyDisplay)) + "%" + stringAcc;

		// shaking
		camHUD.flashSprite.x = FlxG.camera.flashSprite.x;
		camHUD.flashSprite.y = FlxG.camera.flashSprite.y;

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			isPaused = true;
			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		#if debug
		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}
		#end

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		// iconP1.setGraphicSize(Std.int(FlxMath.lerp(iconP1.width, 150, 0.25 / ((SONG.bpm * 0.65) / 60) * (30 / Main.framerate))));
		// iconP2.setGraphicSize(Std.int(FlxMath.lerp(iconP2.width, 150, 0.25 / ((SONG.bpm * 0.65) / 60) * (30 / Main.framerate))));

		// iconP1.centerOffsets();
		// iconP2.centerOffsets();

		var iconOffset:Int = 26;

		var iconP1Bop:Float = FlxMath.lerp(iconP1.scale.x, 1, 0.15 * (60 / Main.framerate));
		var iconP2Bop:Float = FlxMath.lerp(iconP2.scale.x, 1, 0.15 * (60 / Main.framerate));

		iconP1.scale.set(iconP1Bop, iconP1Bop);
		iconP2.scale.set(iconP2Bop, iconP2Bop);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		iconP1.x = healthBar.x
			+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
			+ (150 * iconP1.scale.x - 150) / 2
			- iconOffset;
		iconP2.x = healthBar.x
			+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
			- (150 * iconP2.scale.x) / 2
			- iconOffset * 2;

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
		{
			FlxG.switchState(new AnimationDebug(SONG.player2));
		}
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (!stopFocusing)
			{
				if (camFollow.x != enemy.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				{
					camFollow.setPosition(enemy.getMidpoint().x + 150, enemy.getMidpoint().y - 100);
					// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

					switch (enemy.curCharacter)
					{
						case 'spooky':
							camFollow.y = boyfriend.getMidpoint().y - 140;
						case 'pico':
							camFollow.y = boyfriend.getMidpoint().y - 160;
						case 'mom':
							camFollow.y = enemy.getMidpoint().y;
						case 'senpai':
							camFollow.y = enemy.getMidpoint().y - 430;
							camFollow.x = enemy.getMidpoint().x - 90;
						case 'senpai-angry':
							camFollow.y = enemy.getMidpoint().y - 430;
							camFollow.x = enemy.getMidpoint().x - 90;
					}

					if (SONG.song.toLowerCase() == 'tutorial')
					{
						tweenCamIn();
					}
				}

				if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
				{
					camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

					switch (curStage)
					{
						case 'spooky':
							camFollow.y = boyfriend.getMidpoint().y - 140;
						case 'philly':
							camFollow.y = boyfriend.getMidpoint().y - 160;
						case 'limo':
							camFollow.x = boyfriend.getMidpoint().x - 300;
						case 'mall':
							camFollow.y = boyfriend.getMidpoint().y - 200;
						case 'school':
							camFollow.x = boyfriend.getMidpoint().x - 200;
							camFollow.y = boyfriend.getMidpoint().y - 200;
						case 'schoolEvil':
							camFollow.x = boyfriend.getMidpoint().x - 200;
							camFollow.y = boyfriend.getMidpoint().y - 200;
					}

					if (SONG.song.toLowerCase() == 'tutorial')
					{
						FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
					}
				}
			}
			else
			{
				camFollow.x = gf.getGraphicMidpoint().x - 45;
				camFollow.y = gf.getGraphicMidpoint().y - 15;
			}
		}

		if (SONG.camera)
		{
			if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
			{
				if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				{
					var dadPoint:FlxPoint = new FlxPoint(0, 0);

					switch (enemy.curCharacter)
					{
						case 'spooky':
							dadPoint.y = boyfriend.getMidpoint().y - 140;
						case 'pico':
							dadPoint.y = boyfriend.getMidpoint().y - 160;
						case 'mom':
							dadPoint.y = enemy.getMidpoint().y;
						case 'senpai':
							dadPoint.y = enemy.getMidpoint().y - 430;
							dadPoint.x = enemy.getMidpoint().x - 90;
						case 'senpai-angry':
							dadPoint.y = enemy.getMidpoint().y - 430;
							dadPoint.x = enemy.getMidpoint().x - 90;
					}

					if (dadPoint.x == 0)
						dadPoint.x = enemy.getMidpoint().x + 150;
					if (dadPoint.y == 0)
						dadPoint.y = enemy.getMidpoint().y - 100;
				}
				else
				{
					var bfPoint:FlxPoint = new FlxPoint(0, 0);

					switch (curStage)
					{
						case 'spooky':
							bfPoint.y = boyfriend.getMidpoint().y - 140;
						case 'philly':
							bfPoint.y = boyfriend.getMidpoint().y - 160;
						case 'limo':
							bfPoint.x = boyfriend.getMidpoint().x - 300;
						case 'mall':
							bfPoint.y = boyfriend.getMidpoint().y - 200;
						case 'school':
							bfPoint.x = boyfriend.getMidpoint().x - 200;
							bfPoint.y = boyfriend.getMidpoint().y - 200;
						case 'schoolEvil':
							bfPoint.x = boyfriend.getMidpoint().x - 200;
							bfPoint.y = boyfriend.getMidpoint().y - 200;
					}
					if (bfPoint.x == 0)
						bfPoint.x = boyfriend.getMidpoint().x - 100;
					if (bfPoint.y == 0)
						bfPoint.y = boyfriend.getMidpoint().y - 100;
				}
			}
		}

		switch (SONG.song.toLowerCase())
		{
			case 'blammed':
				// stfu kids
				forceBeat = [
					129, 141, 148, 160, 166, 172, 180, 192, 204, 212, 224, 230, 236, 243, 256, 268, 276, 288, 294, 300, 308, 321, 332, 340, 351, 358, 364,
					372, 383, 512, 525, 532, 544, 550, 556, 564, 575, 590, 596, 607, 614, 619, 627, 636, 653, 660, 671, 678, 684, 692, 703, 716, 724, 736,
					742, 747, 756, 764, 768, 801, 896, 912, 918, 928, 934, 944, 949, 960, 964, 976, 991, 1008, 1023
				];
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, defaultCamZoom, 0.025);
			camHUD.zoom = FlxMath.lerp(camHUD.zoom, 1, 0.025);
		}

		if (forceBeat.contains(curStep))
		{
			if (!triggeredCamera)
			{
				FlxG.camera.zoom += 0.015 * (FlxG.save.data.musicVolume / 100);
				camHUD.zoom += 0.03 * (FlxG.save.data.musicVolume / 100);

				updateLights();
			}
			triggeredCamera = true;
		}
		else
		{
			triggeredCamera = false;
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
					updateCam(2);
				case 48:
					gfSpeed = 1;
					updateCam(1);
				case 80:
					gfSpeed = 2;
					updateCam(2);
				case 112:
					gfSpeed = 1;
					updateCam(1);
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			if (generatedMusic)
			{
				health = 0;
				trace("RESET = True");
			}
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (health <= 0)
		{
			playerDead = true;

			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			if (FlxG.random.bool(0.1))
				FlxG.switchState(new GitarooPause());
			else
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			var strum = playerStrums;

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height && !downscroll || daNote.y < -FlxG.height && downscroll)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				if (!daNote.canBeHit)
					strum = enemyStrums;

				if (daNote.isSustainNote || daNote.animation.curAnim.name.endsWith('end'))
				{
					if (daNote.tooLate)
						daNote.alpha = 0.3;
					else
						daNote.alpha = 0.6;
				}
				else
				{
					if (daNote.tooLate)
						daNote.alpha = 0.3;
					else
						daNote.alpha = 1;
				}

				// sorry kade dev :(
				var center:Float = strum.members[daNote.noteData].y + Note.swagWidth / 2;

				if (downscroll)
				{
					if (daNote.mustPress)
						daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
							+ 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2))
							- daNote.noteYOff;
					else
						daNote.y = (enemyStrums.members[Math.floor(Math.abs(daNote.noteData))].y
							+ 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2))
							- daNote.noteYOff;

					if (daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith('end'))
						{
							daNote.y += 10.5 * (((60 / SONG.bpm) * 1000) / 400) * 1.5 * FlxMath.roundDecimal(SONG.speed, 2)
								+ (46 * (FlxMath.roundDecimal(SONG.speed, 2) - 1));
							daNote.y -= 46 * (1 - (((60 / SONG.bpm) * 1000) / 600)) * FlxMath.roundDecimal(SONG.speed, 2);
						}

						if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
				}
				else
				{
					if (daNote.mustPress)
						daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
							- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2));
					else
						daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
							- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2));

					if (daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
						{
							daNote.y -= 10.5 * (((60 / SONG.bpm) * 1000) / 400) * 1.5 * FlxMath.roundDecimal(SONG.speed, 2)
								+ (46 * (FlxMath.roundDecimal(SONG.speed, 2) - 1));
							daNote.y += 77 * (1 - (((60 / SONG.bpm) * 1000) / 600)) - 144 * FlxMath.roundDecimal(SONG.speed, 2) / 16;
							daNote.y += 175 * ((60 / SONG.bpm));
						}
						else
							daNote.y -= (daNote.height / 2) * 0.8;

						if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (center - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					if (MainMenuState.mechanics[4].points != 0)
					{
						var drain:Float = 0.035 + (0.005 * MainMenuState.mechanics[4].points);
						var divisor:Array<Float> = [6.5, 5.5, 4.5];

						drain /= divisor[FlxG.random.weightedPick([75, 50, 25])];

						if (daNote.isSustainNote)
							drain *= 0.2;
						if (health - drain <= 0)
							health = 0.04;
						else
							health -= drain;
					}

					if (daNote.noteType != 'gen1')
					{
						switch (Math.abs(daNote.noteData))
						{
							case 0:
								enemy.playAnim('singLEFT' + altAnim, true);
							case 1:
								enemy.playAnim('singDOWN' + altAnim, true);
							case 2:
								enemy.playAnim('singUP' + altAnim, true);
							case 3:
								enemy.playAnim('singRIGHT' + altAnim, true);
						}
					}

					enemyStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(daNote.noteData) == spr.ID)
						{
							spr.animation.play('confirm', true);
						}
						if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
						{
							spr.centerOffsets();
							spr.offset.x -= 13;
							spr.offset.y -= 13;
						}
						else
							spr.centerOffsets();
					});

					enemy.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = FlxG.save.data.vocalVolume / 100;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if ((daNote.y < -daNote.height && !downscroll) || (daNote.y > FlxG.height + daNote.height && downscroll))
				{
					if (daNote.tooLate || !daNote.wasGoodHit)
					{
						health -= 0.0475;

						vocals.volume = 0;
						if (!FlxG.save.data.botplay)
						{
							if (!daNote.isSustainNote)
								noteMiss(daNote.noteData, daNote);
						}
						else
						{
							goodNoteHit(daNote);
						}
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});

			enemyStrums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.finished)
				{
					spr.animation.play('static');
					spr.centerOffsets();
				}
			});

			if (!inCutscene)
				keyShit();

			#if debug
			if (FlxG.keys.justPressed.ONE)
				endSong();
			#end
		}
	}

	// I GOTTA DO THIS TO BYPASS ERROR LOL
	private static var dumbStrums:Array<Int> = [];

	public inline function swapNote(note:Note):Void
	{
		var animations:Array<String> = ['purpleScroll', 'blueScroll', 'greenScroll', 'redScroll'];
		var animHold:Array<String> = ['purplehold', 'bluehold', 'greenhold', 'redhold'];
		var Strummy:Array<Int> = [];

		var newNoteData:Int = 0;
		newNoteData = note.nextSwap;

		for (strum in dumbStrums)
		{
			Strummy.push(strum);
		}
		// trace(Strummy);

		var offset:Int = 0;

		if (note.isSustainNote)
		{
			offset = 35;
			if (note.animation.curAnim.name.endsWith('end'))
				note.animation.play(animHold[newNoteData] + 'end');
			else
				note.animation.play(animHold[newNoteData]);
		}
		else
			note.animation.play(animations[newNoteData]);

		FlxTween.tween(note, {x: 50 + (FlxG.width / 2) + offset + Note.swagWidth * playerStrums.members[newNoteData].currentNotePos},
			Conductor.stepCrochet / 1500, {ease: FlxEase.linear});

		if (newNoteData != playerStrums.members[newNoteData].currentNotePos)
			note.x = 50 + (FlxG.width / 2) + offset + Note.swagWidth * playerStrums.members[newNoteData].currentNotePos;

		note.noteData = newNoteData;
	}

	function endSong():Void
	{
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		PlayState.unspawnNotes = [];

		if (SONG.validScore)
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);

		if (isStoryMode || debugCutscene)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				// FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				// do it because debug?
				FlxG.switchState(new MainMenuState());

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				switch (SONG.song.toLowerCase())
				{
					case 'eggnog' | 'south':
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						if (SONG.song.toLowerCase() == 'south')
							FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2), FlxG.save.data.soundVolume / 100);
						else
							FlxG.sound.play(Paths.sound('Lights_Shut_off'), FlxG.save.data.soundVolume / 100);

						new FlxTimer().start(3, function(tmr:FlxTimer)
						{
							nextSong(difficulty);
						});
					case 'roses':
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						blackShit.alpha = 0;
						add(blackShit);
						FlxTween.tween(blackShit, {alpha: 1}, 0.7, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								new FlxTimer().start(0.2, function(tmr:FlxTimer)
								{
									nextSong(difficulty);
								});
							}
						});

						FlxTween.tween(camHUD, {alpha: 1}, 0.7, {ease: FlxEase.quadInOut});
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				var dontSkip:Array<String> = ['roses', 'eggnog', 'south'];

				if (!dontSkip.contains(SONG.song.toLowerCase()))
				{
					trace('skip shit');
					nextSong(difficulty);
				}
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			// FlxG.sound.playMusic(Paths.music('freakyMenu'));
			FlxG.switchState(new MainMenuState());
		}
	}

	function nextSong(difficShit:String)
	{
		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficShit, PlayState.storyPlaylist[0]);
		FlxG.sound.music.stop();

		LoadingState.loadAndSwitchState(new PlayState());
	}

	var endingSong:Bool = false;

	var savedComboPos:Array<Float> = [0, 0];
	var comboPosSaved:Bool = false;

	var botAccDiff:Int = 0;

	private function popUpScore(daNote:Note, isBot:Bool = false, botMiss:Bool = false):Void
	{
		var strumtime:Float = daNote.strumTime;
		var isSustainNote:Bool = daNote.isSustainNote;
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = FlxG.save.data.vocalVolume / 100;

		var daRating:String = "sick";
		var score:Int = 350;

		if (!comboPosSaved)
		{
			savedComboPos[0] = enemy.getGraphicMidpoint().x;
			savedComboPos[1] = enemy.getGraphicMidpoint().y;
			comboPosSaved = true;
		}

		if (FlxG.save.data.botplay)
			noteDiff = 0;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
			daRating = 'shit';
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
			daRating = 'bad';
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
			daRating = 'good';

		switch (daRating)
		{
			case 'sick':
				ratingList[0]++;
			case 'good':
				ratingList[1]++;
			case 'bad':
				ratingList[2]++;
			case 'shit':
				ratingList[3]++;
		}

		if (!isSustainNote)
			score = ScoreFunctions.calculateNote(daRating, noteDiff);

		totalRanksHit += 1 - (noteDiff / Conductor.safeZoneOffset);

		totalNotesHit += 1;

		if (daNote.noteType != 'gen1')
			songScore += Math.floor(score * multiplier);

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */
		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}
		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));

		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		if (isBot)
		{
			rating.x = (savedComboPos[0] * 0.8);
			rating.y = savedComboPos[1] - 80;
		}
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);
		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = Settings.antialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = Settings.antialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}
		comboSpr.updateHitbox();
		rating.updateHitbox();
		var seperatedScore:Array<Int> = [];

		var stringCombo:String = Std.string(combo);

		for (i in 0...stringCombo.length)
		{
			seperatedScore.push(Std.int(Std.parseFloat(stringCombo.charAt(i))));
		}
		if (isBot) // how tho
			seperatedScore.reverse();
		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));

			numScore.screenCenter();
			numScore.x = (coolText.x + (43 * daLoop) - 90) - 20 * seperatedScore.length;
			numScore.y += 80;
			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = Settings.antialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();
			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			if (totalNotesHit != 0)
				add(numScore);
			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},

				startDelay: Conductor.crochet * 0.002
			});
			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */
		coolText.text = Std.string(seperatedScore);
		// add(coolText);
		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});
		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
	}

	private function keyShit():Void
	{
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
		var directionNames:Array<String> = ['left', 'down', 'up', 'right'];

		if (holdArray.contains(true) && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
				{
					goodNoteHit(daNote);
				}
			});
		}

		if (pressArray.contains(true) && generatedMusic)
		{
			var possibleNotes:Array<Note> = [];
			var directionList:Array<Int> = [];
			var dumbNotes:Array<Note> = [];
			var directionsAccounted:Array<Bool> = [false, false, false, false];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.wasGoodHit && !directionsAccounted[daNote.noteData])
				{
					if (directionList.contains(daNote.noteData))
					{
						directionsAccounted[daNote.noteData] = true;
						for (coolNote in possibleNotes)
						{
							if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
							{ // if it's the same note twice at < 10ms distance, just delete it
								// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
								dumbNotes.push(daNote);
								break;
							}
							else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
							{ // if daNote is earlier than existing note (coolNote), replace
								possibleNotes.remove(coolNote);
								possibleNotes.push(daNote);
								break;
							}
						}
					}
					else
					{
						directionsAccounted[daNote.noteData] = true;
						possibleNotes.push(daNote);
						directionList.push(daNote.noteData);
					}
				}
			});

			for (note in dumbNotes)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}

			possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			var hit = [false, false, false, false];

			if (possibleNotes.length > 0)
			{
				if (!ghostTap)
				{
					for (press in 0...pressArray.length)
					{
						if (pressArray[press] && !directionList.contains(press))
							noteMiss(press, null);
					}
				}

				for (coolNote in possibleNotes)
				{
					if (pressArray[coolNote.noteData] && !hit[coolNote.noteData])
					{
						if (mashViolations != 0)
							mashViolations--;
						hit[coolNote.noteData] = true;
						scoreTxt.color = FlxColor.WHITE;
						goodNoteHit(coolNote);
					}
				}
			}
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
		{
			boyfriend.playAnim('idle');
		}

		if (!FlxG.save.data.botplay)
		{
			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
					spr.animation.play('pressed');
				if (!holdArray[spr.ID])
					spr.animation.play('static');
				if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
				{
					spr.centerOffsets();
					spr.offset.x -= 13;
					spr.offset.y -= 13;
				}
				else
					spr.centerOffsets();
			});
		}
	}

	public function botPlay():Void
	{
		if (FlxG.save.data.botplay)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (downscroll && daNote.y > strumLine.y || !downscroll && daNote.y < strumLine.y)
				{
					// Force good note hit regardless if it's too late to hit it or not as a fail safe
					if ((daNote.canBeHit && daNote.mustPress) || (daNote.tooLate && daNote.mustPress))
					{
						goodNoteHit(daNote);

						playerStrums.forEach(function(spr:FlxSprite)
						{
							if (Math.abs(daNote.noteData) == spr.ID)
							{
								spr.animation.play('confirm', false);
							}
							if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
							{
								spr.centerOffsets();
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							}
							else
								spr.centerOffsets();
						});
						boyfriend.holdTimer = daNote.sustainLength;
					}
				}
			});
		}
		// if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !holdArray.contains(true))
		// ALWAYS PRIORITIZE THE FIRST ANIMATION
	}

	function animSprOrder(spr:FlxSprite):Int
	{
		if (spr.animation.curAnim != null && animOrder.exists(spr.animation.curAnim.name))
			return animOrder.get(spr.animation.curAnim.name);

		return -1;
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.04;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}

			combo = 0;
			misses += 1;

			songScore -= 25;

			if (FlxG.save.data.soundVolume > 20)
				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			else
				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.save.data.soundVolume / 100);
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
		}
	}

	/* no
		function badNoteCheck()
		{
			// just double pasting this shit cuz fuk u
			// REDO THIS SYSTEM!
			var upP = controls.UP_P;
			var rightP = controls.RIGHT_P;
			var downP = controls.DOWN_P;
			var leftP = controls.LEFT_P;

			if (leftP)
				noteMiss(0);
			if (downP)
				noteMiss(1);
			if (upP)
				noteMiss(2);
			if (rightP)
				noteMiss(3);
		}
	 */
	var mashing:Int = 0;
	var mashViolations:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
	{
		// this is copy pasted but idc
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

		// note.rating = Ratings.CalculateRating(noteDiff);

		if (controlArray[note.noteData])
		{
			goodNoteHit(note);

			/*if (mashing > getKeyPresses(note) && mashViolations <= 2)
				{
					mashViolations++;
					goodNoteHit(note, (mashing > getKeyPresses(note)));
				}
				else if (mashViolations > 2)
				{
					// this is bad but fuck you
					playerStrums.members[0].animation.play('static');
					playerStrums.members[1].animation.play('static');
					playerStrums.members[2].animation.play('static');
					playerStrums.members[3].animation.play('static');
					health -= 0.4;
					trace('mash ' + mashing);
					if (mashing != 0)
						mashing = 0;
				}
				else
					goodNoteHit(note, false); */
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			// cant believe i have to copy paste this shit
			var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

			if (FlxG.save.data.botplay)
				noteDiff = 0;

			lastNoteDiff = noteDiff;

			var daRating:String = "sick";

			if (!FlxG.save.data.botplay)
			{
				if (noteDiff > Conductor.safeZoneOffset * 0.9)
					daRating = 'shit';
				else if (noteDiff > Conductor.safeZoneOffset * 0.75)
					daRating = 'bad';
				else if (noteDiff > Conductor.safeZoneOffset * 0.3)
					daRating = 'good';
			}

			if (!note.isSustainNote)
			{
				curNoteType = 'note';
				popUpScore(note, false);
				combo += 1;
			}
			else
			{
				curNoteType = 'held';
				songScore += ScoreFunctions.calculateHeld(daRating, noteDiff);
			}

			var addHealth:Float = 0;

			if (note.isSustainNote)
				addHealth = 0.02;
			else
				addHealth = 0.06;

			if (health > 1)
				addHealth /= 2;

			health += addHealth;

			if (note.noteType != 'gen1')
			{
				switch (note.noteData)
				{
					case 0:
						boyfriend.playAnim('singLEFT', true);
					case 1:
						boyfriend.playAnim('singDOWN', true);
					case 2:
						boyfriend.playAnim('singUP', true);
					case 3:
						boyfriend.playAnim('singRIGHT', true);
				}
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = FlxG.save.data.vocalVolume / 100;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	var alreadyChanged:Bool = false;
	var disqualifyTxt:FlxText;

	public function changeSettings()
	{
		downscroll = Settings.downscroll;
		ghostTap = Settings.ghostTap;
		Conductor.offset = FlxG.save.data.noteOffset;

		SONG.validScore = false;

		if (downscroll)
			strumLine.y = 550;
		else
			strumLine.y = 50;

		if (downscroll)
		{
			strumLine.y = FlxG.height - 165;
			healthBarBG.y = FlxG.height * 0.1;
		}
		else
		{
			healthBarBG.y = FlxG.height * 0.9;
		}
		healthBar.y = healthBarBG.y + 4;
		scoreTxt.y = healthBarBG.y + healthBarBG.height + 10;
		iconP1.y = healthBar.y - (iconP2.height / 2);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		timerText.y = strumLine.y + 45;
		strumLineNotes.forEach(function(spr:FlxSprite)
		{
			spr.y = strumLine.y;
		});

		if (!alreadyChanged)
		{
			alreadyChanged = true;
			disqualifyTxt = new FlxText(FlxG.width, downscroll ? timerText.y + 70 : timerText.y - 70, 0, "Your score is disqualified.", 24);
			disqualifyTxt.setFormat("assets/fonts/vcr.ttf", 22, FlxColor.RED, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			disqualifyTxt.alpha = 0;
			disqualifyTxt.screenCenter(X);
			disqualifyTxt.cameras = [camHUD];
			add(disqualifyTxt);
			FlxTween.tween(disqualifyTxt, {alpha: 1}, 0.6, {
				onComplete: function(twn:FlxTween)
				{
					new FlxTimer().start(4, function(tmr:FlxTimer)
					{
						disqualifyTxt.alpha = 0;
					});
				}
			});
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		if (FlxG.save.data.soundVolume > 70)
			FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);
		else
			FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), FlxG.save.data.soundVolume / 100);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;
	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2), FlxG.save.data.soundVolume / 100);
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		iconP1.animation.play('scared-bf');
		// idk why my other methods dont work
		new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			iconP1.animation.play(SONG.player1);
		});
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (enemy.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// enemy.dance();
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	var milfActive:Bool = false;

	var sawBladeActivated:Bool = false;
	var sawBladePart:Int = 0;
	var isDual:Bool;
	var finishingBeatOffset:Int = 0;

	static var lastSwapSect:Array<Int> = [];

	function updateSwapped()
	{
		dumbStrums = [];

		playerStrums.forEachAlive(function(Strum:StrumLine)
		{
			dumbStrums.push(Strum.currentNotePos);
		});
	}

	var trickyInterrupt:Bool = false;
	var trickyGrabbed:Bool = false;
	var trickyDmg:Float = 0;
	var trickyCooldown:Int = 4;
	var trickyTween:FlxTween;

	function sectionHit()
	{
		if (MainMenuState.mechanics[5].points != 0)
		{
			trickyCooldown--;

			if (FlxG.random.bool(65 + (2.5 * MainMenuState.mechanics[5].points)) && health > 1 && trickyCooldown < 0)
			{
				trickyGremlin = new FlxSprite(0, 0);
				trickyGremlin.frames = Paths.getSparrowAtlas('gremlin/HP GREMLIN', null, false);
				trickyGremlin.animation.addByIndices('come', 'HP Gremlin ANIMATION', [0, 1], "", 24, false);
				trickyGremlin.animation.addByIndices('grab', 'HP Gremlin ANIMATION', [
					2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24
				], "", 24, false);
				trickyGremlin.animation.addByIndices('hold', 'HP Gremlin ANIMATION', [25, 26, 27, 28], "", 24);
				trickyGremlin.animation.addByIndices('release', 'HP Gremlin ANIMATION', [29, 30, 31, 32, 33], "", 24, false);

				trickyGremlin.antialiasing = true;
				trickyGremlin.setGraphicSize(Std.int(trickyGremlin.width * 0.76));

				trickyGremlin.cameras = [camHUD];

				trickyGremlin.x = iconP1.x;
				trickyGremlin.y = healthBarBG.y - 325;

				trickyCooldown = 4;

				if (downscroll)
				{
					trickyGremlin.flipY = true;
					trickyGremlin.y -= 150;
				}

				add(trickyGremlin);

				trickyGrabbed = true;

				trickyInterrupt = false;

				trickyDmg = 0;

				var startHealth = health;
				var toHealth = (40 / 100) * startHealth;
				if (startHealth > 75)
					toHealth = (20 / 100) * startHealth;

				var perct = toHealth / 2 * 100;

				FlxG.sound.play(Paths.sound('gremlinWoosh'));
				trickyGremlin.animation.play('come');

				var triggered:Bool = false;

				new FlxTimer().start(0.14, function(tmr:FlxTimer)
				{
					trickyGremlin.animation.play('grab');

					FlxTween.tween(trickyGremlin, {x: iconP1.x - 140}, 1, {
						ease: FlxEase.elasticIn,
						onComplete: function(tween:FlxTween)
						{
							FlxTween.tween(trickyGremlin, {
								x: (healthBar.x + (healthBar.width * (FlxMath.remapToRange(perct, 0, 100, 100, 0) * 0.01) - 26)) - 75
							}, 3, {
								onUpdate: function(tween:FlxTween)
								{
									if (trickyInterrupt && !triggered)
									{
										triggered = true;
										trickyGremlin.animation.play('release');
										trickyGremlin.animation.finishCallback = function(str:String)
										{
											trickyGremlin.visible = false;
											remove(trickyGremlin);
										}
									}
									else if (!trickyInterrupt)
									{
										trickyGremlin.animation.play('hold');

										var lerpHealth = FlxMath.lerp(startHealth, toHealth, tween.percent);
										if (lerpHealth <= 0)
											lerpHealth = 0.1;
										health = lerpHealth;

										if (playerDead)
										{
											health = 0;
											playerDead = false;
										}
									}
								},
								onComplete: function(tween:FlxTween)
								{
									if (trickyInterrupt)
									{
										trickyGrabbed = false;
										trickyGremlin.visible = false;
										remove(trickyGremlin);
									}
									else
									{
										trickyGremlin.animation.play('release');
										health -= trickyDmg;
										trickyGremlin.animation.finishCallback = function(anim:String)
										{
											trickyGremlin.visible = false;
											remove(trickyGremlin);
										}
										trickyGrabbed = false;
									}
								}
							});
						}
					});
				});
			}
		}

		if (sawBlades[curSection] != null)
		{
			sawBladeActivated = true;
			isDual = sawBlades[curSection][1];
			if (isDual)
				finishingBeatOffset = 3;
			else
				finishingBeatOffset = 2;
		}

		if (swapNote1[curSection] != null)
		{
			// x: 50 + (FlxG.width / 2) + (Note.swagWidth * spr.noteData)
			updateSwapped();
			var strumLineSect:Array<Int> = [0, 1, 2, 3];

			if (FlxG.random.bool(0.75 + (0.25 * MainMenuState.mechanics[7].points)))
				FlxG.random.shuffle(strumLineSect);
			else
			{
				var randomizedChance:Float = FlxG.random.float(0, 100);

				if (randomizedChance < 25)
					strumLineSect = [3, 1, 2, 0];
				else if (randomizedChance < 50)
					strumLineSect = [0, 2, 1, 3];
				else if (randomizedChance < 75)
					strumLineSect = [1, 0, 3, 2];
				else
					strumLineSect = [2, 3, 0, 1];

				if (strumLineSect == lastSwapSect)
					strumLineSect = [0, 1, 2, 3];
			}

			lastSwapSect = strumLineSect;

			for (spr in playerStrums.members)
			{
				FlxTween.tween(spr, {x: 50 + (FlxG.width / 2) + Note.swagWidth * strumLineSect[playerStrums.members.indexOf(spr)]}, 0.875, {
					ease: FlxEase.quadOut,
					onUpdate: function(twn:FlxTween)
					{
						notes.forEachAlive(function(note:Note)
						{
							if (note.mustPress && note.noteData == spr.noteData && note.noteType != 'gen1')
							{
								if (note.isSustainNote)
									note.x = spr.x + 35;
								else
									note.x = spr.x;
							}
						});

						for (daNote in unspawnNotes)
						{
							if (daNote.mustPress && daNote.noteData == spr.noteData && daNote.noteType != 'gen1')
							{
								if (daNote.isSustainNote)
									daNote.x = spr.x + 35;
								else
									daNote.x = spr.x;
							}
						}
					}
				});

				spr.setDataPosition(strumLineSect[playerStrums.members.indexOf(spr)]);
			}
		}
	}

	override function beatHit()
	{
		if (finishingBeatOffset > 0)
			finishingBeatOffset--;

		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (curBeat % 4 == 0)
		{
			curSection += 1;
			sectionHit();
		}

		if (sawBladeActivated)
		{
			warningSprite.visible = true;
			// sawBladeSprite.visible = true;

			if (isDual)
			{
				if (finishingBeatOffset == 2)
				{
					warningSprite.animation.play('alertDOUBLE');
					FlxG.sound.play(Paths.sound('alertDouble'));
				}
				else if (finishingBeatOffset == 3)
				{
					warningSprite.animation.play('alertSINGLE');
					FlxG.sound.play(Paths.sound('alert'));
					// sawBladeSprite.animation.play('prepare');
					// sawBladeSprite.setPosition(boyfriend.x - 1640, boyfriend.y + 60);
				}
				else
				{
					if (finishingBeatOffset == 1 || finishingBeatOffset == 0)
					{
						FlxG.sound.play(Paths.sound('attack'));
						// sawBladeSprite.animation.play('attack');
						// sawBladeSprite.offset.set(-688, 0);
						new FlxTimer().start(0.175, function(tmr:FlxTimer)
						{
							if (FlxG.save.data.botplay)
							{
								if (FlxG.save.data.botplay)
								{
									if (boyfriend.animOffsets.exists('dodge'))
										boyfriend.playAnim('dodge');

									new FlxTimer().start(0.225, function(tmr:FlxTimer)
									{
										boyfriend.dance();
									});
								}

								sawBladeSprite.visible = false;
							}
							else
							{
								if (!invulnToSawblade)
									health -= 4;
								else
								{
									invulnToSawblade = false;
									sawBladeSprite.visible = false;
								}
							}
						});
					}
				}
			}
			else
			{
				if (finishingBeatOffset == 0)
				{
					FlxG.sound.play(Paths.sound('attack'));
					// sawBladeSprite.animation.play('attack');
					new FlxTimer().start(0.175, function(tmr:FlxTimer)
					{
						if (FlxG.save.data.botplay)
						{
							if (boyfriend.animOffsets.exists('dodge'))
								boyfriend.playAnim('dodge');

							new FlxTimer().start(0.225, function(tmr:FlxTimer)
							{
								boyfriend.dance();
							});
						}
						else
						{
							if (!invulnToSawblade)
								health -= 4;
							else
							{
								invulnToSawblade = false;
								boyfriend.dance();
							}
						}
					});
				}
				else
				{
					warningSprite.animation.play('alertSINGLE');
					FlxG.sound.play(Paths.sound('alert'));
				}
			}
		}

		if (finishingBeatOffset == 0)
		{
			sawBladeActivated = false;
			isDual = false;
		}

		// invulnToSawblade = false;

		iconP1.scale.x = 1.15;
		iconP1.scale.y = 1.15;
		iconP2.scale.x = 1.15;
		iconP2.scale.y = 1.15;

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (curStage != 'limo')
			{
				if (SONG.notes[Math.floor(curStep / 16)].mustHitSection
					|| !enemy.animation.curAnim.name.startsWith("sing")
					&& enemy.curCharacter != 'gf')
					enemy.dance();
			}
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			milfActive = true;
			FlxG.camera.zoom += 0.015 * (FlxG.save.data.musicVolume / 100);
			camHUD.zoom += 0.03 * (FlxG.save.data.musicVolume / 100);
		}
		else
			milfActive = false;

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0 && !milfActive && SONG.song.toLowerCase() != 'blammed')
		{
			FlxG.camera.zoom += 0.015 * (FlxG.save.data.musicVolume / 100);
			camHUD.zoom += 0.03 * (FlxG.save.data.musicVolume / 100);
		}

		if (curBeat % gfSpeed == 0)
		{
			/*iconP1.setGraphicSize(Std.int(iconP1.width + (30 * (FlxG.save.data.musicVolume / 100))));
				iconP2.setGraphicSize(Std.int(iconP2.width + (30 * (FlxG.save.data.musicVolume / 100)))); */
			iconP1.scale.set(1.15 * (FlxG.save.data.musicVolume / 100), 1.15 * (FlxG.save.data.musicVolume / 100));
			iconP2.scale.set(1.15 * (FlxG.save.data.musicVolume / 100), 1.15 * (FlxG.save.data.musicVolume / 100));

			/*iconP1.updateHitbox();
				iconP2.updateHitbox(); */
		}

		if (curBeat % gfSpeed == 0)
			gf.dance();

		if (!boyfriend.animation.curAnim.name.startsWith("sing") && boyfriend.animation.curAnim.name != "dodge")
			boyfriend.playAnim('idle');

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
			boyfriend.playAnim('hey', true);

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && enemy.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			enemy.playAnim('cheer', true);
		}

		if (curBeat == 47 || curBeat == 111)
		{
			if (curSong == 'Bopeebo')
			{
				new FlxTimer().start(0.3, function(tmr:FlxTimer)
				{
					boyfriend.playAnim('hey', true);
				});
			}
		}

		if (curBeat == 183 || curBeat == 200)
		{
			if (SONG.song.toLowerCase() == 'eggnog')
				stopFocusing = !stopFocusing;
		}

		switch (curStage)
		{
			case 'school':
				bgGirls.dance();

			case 'mall':
				if (quality != 'low')
				{
					upperBoppers.animation.play('bop', true);
					bottomBoppers.animation.play('bop', true);
				}
				santa.animation.play('idle', true);

			case 'limo':
				if (quality != 'low')
				{
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});
				}

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0 && SONG.song.toLowerCase() != 'blammed')
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1, [curLight]);

					phillyCityLights.members[curLight].visible = true;
					phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	function updateCam(speed:Float)
	{
		FlxG.camera.follow(camFollow, LOCKON, (0.04 * (30 / Main.framerate)) / speed);
	}

	function updateLights()
	{
		phillyCityLights.forEach(function(light:FlxSprite)
		{
			light.visible = false;
		});

		curLight = FlxG.random.int(0, phillyCityLights.length - 1, [curLight]);

		phillyCityLights.members[curLight].visible = true;
		phillyCityLights.members[curLight].alpha = 1;
	}
}

class StrumLine extends FlxSprite
{
	public var noteData:Int;
	public var currentNotePos:Int;

	override public function new(x:Float, y:Float)
	{
		super(x, y);
		if (x > FlxG.width * 0.5)
			trace(x);
	}

	public function setDataPosition(data:Int):Void
	{
		currentNotePos = data;
	}
}
