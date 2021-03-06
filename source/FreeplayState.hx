/*package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.system.FlxSound;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.util.FlxSpriteUtil;
import lime.utils.Assets;

using StringTools;

class FreeplayState extends MusicBeatState
{
	public static var lastSelected:Int = 0;

	public var songName:String = '';

	// var songs:Array<SongMetadata> = [];
	var difficulty:Array<Float> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var bg:FlxSprite;

	var scoreText:FlxText;
	var diffText:FlxText;
	var songDiff:FlxText;
	var totalText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var bpmTxt:FlxText;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIconOld> = [];

	override function create()
	{
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		Settings.init();

		if (lastSelected != 0)
			curSelected = lastSelected;

		for (i in 0...initSonglist.length)
		{
			// songs.push(new SongMetadata(initSonglist[i], 1, 'gf', 100));
		}

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		if (StoryMenuState.weekUnlocked[2] || isDebug)
			addWeek(['Bopeebo', 'Fresh', 'Dad-battle'], 1, ['dad'], [100, 120, 180]);

		if (StoryMenuState.weekUnlocked[2] || isDebug)
			addWeek(['Spookeez', 'South', 'Monster'], 2, ['spooky', 'spooky', 'monster-christmas'], [150, 165, 95]); // ill make changing BPMs later

		if (StoryMenuState.weekUnlocked[3] || isDebug)
			addWeek(['Pico', 'Philly-Nice', 'Blammed'], 3, ['pico'], [95, 175, 165]);

		if (StoryMenuState.weekUnlocked[4] || isDebug)
			addWeek(['Satin-Panties', 'High', 'Milf'], 4, ['mom'], [110, 125, 180]);

		if (StoryMenuState.weekUnlocked[5] || isDebug)
			addWeek(['Cocoa', 'Eggnog', 'Winter-Horrorland'], 5, ['parents-christmas', 'parents-christmas', 'monster-christmas'], [100, 150, 159]);

		if (StoryMenuState.weekUnlocked[6] || isDebug)
			addWeek(['Senpai', 'Roses', 'Thorns'], 6, ['senpai', 'senpai', 'spirit'], [144, 166, 190]); // increase roses BPM to have more precision

		difficulty = [1, 3, 5, 9, 8, 12, 7, 6, 9, 11, 10, 12, 16, 11, 13, 9, 7, 14, 12];

		// LOAD MUSIC

		// LOAD CHARACTERS

		persistentUpdate = true;
		persistentDraw = true;

		bg = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);

		darkBG = new FlxSprite().loadGraphic(Paths.image('menuBGDark'));
		darkBG.alpha = 0;
		add(darkBG);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		/*for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIconOld = new HealthIconOld(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.65, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.60), 66, FlxColor.BLACK);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		// ill figure what this shit is later
		// FlxSpriteUtil.drawRoundRect(scoreBG, scoreText.x - 6, 0, Std.int(FlxG.width * 0.60), 66, 16, 16, FlxColor.RED);

		var infoBG:FlxSprite = new FlxSprite(scoreBG.x, 0 + scoreBG.height * 1.4).makeGraphic(Std.int(FlxG.width * 0.45), 66, 0xFF000000);
		infoBG.alpha = 0.6;
		add(infoBG);

		songDiff = new FlxText(infoBG.x + 6, infoBG.y + 6);
		songDiff.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		add(songDiff);

		totalText = new FlxText(FlxG.width * 0.85, FlxG.height - 28, 0, "", 24);
		totalText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		add(totalText);

		diffText = new FlxText(scoreText.x + 128, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		diffText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		add(diffText);

		bpmTxt = new FlxText(diffText.x - 138, diffText.y + 128, 0, "Press SPACE to play the selected Song.", 24);
		bpmTxt.font = scoreText.font;
		bpmTxt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		bpmTxt.fieldWidth = (FlxG.width - bpmTxt.x);
		add(bpmTxt);

		add(scoreText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, bpm:Int)
	{
		// songs.push(new SongMetadata(songName, weekNum, songCharacter, bpm));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>, ?bpm:Array<Int>)
	{
		if (songCharacters == null)
		{
			songCharacters = ['face'];
			FlxG.log.error("unknown character " + songCharacters + " in song" + songs);
		}

		var charNum:Int = 0;
		var bpmNum:Int = 0;

		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[charNum], bpm[bpmNum]);

			if (songCharacters.length != 1)
				charNum++;
			if (bpm.length != 1)
				bpmNum++;
		}
	}

	var freeplaySong:Bool = false;

	/*public function playSong(song:String)
	{
		var renamedSong:String = '';

		FlxG.sound.music.fadeOut((Conductor.crochet / 1000) * 2, 0, function(snd:FlxTween)
		{
			switch (song.toLowerCase())
			{
				case 'philly-nice':
					renamedSong = 'philly';
				case 'dad-battle':
					renamedSong = 'dadbattle';
				default:
					renamedSong = song;
			}
			Conductor.changeBPM(songs[curSelected].bpm);
			freeplaySong = true;
			FlxG.sound.playMusic(Paths.inst(renamedSong), 0, false);
			songName = renamedSong.toLowerCase();
			bpmTxt.text = 'PLAYING: ' + song.toUpperCase() + '...';
			FlxG.sound.music.fadeIn((Conductor.crochet / 1000) * 2, 1);
			FlxTween.tween(darkBG, {alpha: 0}, (Conductor.crochet / 1000) * 6, {ease: FlxEase.quartOut});
			FlxTween.tween(bg, {alpha: 1}, (Conductor.crochet / 1000) * 6, {ease: FlxEase.quartIn});
		});
	}

	var beatList:Array<Int> = [];
	var canBop:Bool = false;
	var isTweening:Bool = false;
	var darkBG:FlxSprite;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.watch.addQuick("curBeat", curBeat);
		FlxG.watch.addQuick("curStep", curStep);

		Conductor.songPosition = FlxG.sound.music.time;
		lastSelected = curSelected;
		FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 1, 0.95 * (30 / Main.framerate));

		if (FlxG.keys.justPressed.Q)
		{
			beatList.push(curStep);
			FlxG.camera.zoom += 0.015;
			trace(beatList);
		}

		if (FlxG.keys.justPressed.E)
		{
			beatList = [];
			trace(beatList);
			trace(songName);
		}

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
				freeplaySong = false;
				bpmTxt.text = "Press SPACE to play the selected Song.";
			}
		}

		if (FlxG.save.data.musicVolume > 70)
		{
			if (FlxG.sound.music.volume < 0.7)
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		else
		{
			if (FlxG.sound.music.volume < FlxG.save.data.musicVolume / 100)
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		totalText.text = curSelected + 1 + " / " + songs.length + " Songs";
		songDiff.text = "Difficulty: " + difficulty[curSelected];

		var coolLerpScore:Int = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));
		var coolScore:String = FlxStringUtil.formatMoney(coolLerpScore, false, true);
		totalText.y = Math.floor(FlxMath.lerp(totalText.y, FlxG.height - 28, 0.6));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST: " + coolScore;
		// scoreText.text = "PERSONAL BEST: " + coolScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = FlxG.keys.justPressed.ENTER;
		var accepted2 = FlxG.keys.justPressed.SPACE;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			// FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
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

			var poop:String = Highscore.formatSong(coolSong, curDifficulty);

			trace(coolSong);
			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, coolSong);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			PlayState.lastSelected = lastSelected;
			trace('CUR WEEK' + PlayState.storyWeek);
			trace(poop, songs[curSelected].songName.toLowerCase());
			LoadingState.loadAndSwitchState(new PlayState());
		}
		if (accepted2)
		{
			playSong(songs[curSelected].songName);
		}
	}

	override function stepHit()
	{
		if (BeatSync.getSteps(songName.toLowerCase()).contains(curStep) && freeplaySong)
		{
			if (!canBop)
			{
				if (curBeat > 168 && curBeat < 232 && songName.toLowerCase() == 'philly-nice')
					FlxG.camera.zoom += 0.03 * (FlxG.save.data.musicVolume / 100);
				else if (curBeat > 128 && curBeat < 192 && songName.toLowerCase() == 'blammed')
					FlxG.camera.zoom += 0.09 * (FlxG.save.data.musicVolume / 100);
				else
					FlxG.camera.zoom += 0.015 * (FlxG.save.data.musicVolume / 100);
			}
			canBop = true;
		}
		else
		{
			canBop = false;
		}

		// huh?
		if (curStep % 4 == 0)
			beatHit();
	}

	override function beatHit()
	{
		if (curBeat % 8 == 7)
		{
			if (songName.toLowerCase() == 'bopeebo')
			{
				for (icon in iconArray)
				{
					if (icon.animation.curAnim.name == 'gf')
					{
						icon.animation.play('gf-cheer');
						icon.offset.y -= 11;
					}
				}
			}
		}
		else
		{
			if (songName.toLowerCase() == 'bopeebo')
			{
				for (icon in iconArray)
				{
					if (icon.animation.curAnim.name == 'gf-cheer')
					{
						icon.animation.play('gf');
						icon.offset.y += 11;
					}
				}
			}
		}

		if (curBeat == 128 && songName.toLowerCase() == 'blammed')
		{
			FlxTween.tween(darkBG, {alpha: 1}, (Conductor.crochet / 1000) * 4, {ease: FlxEase.quartOut});
			FlxTween.tween(bg, {alpha: 0}, (Conductor.crochet / 1000) * 4, {ease: FlxEase.quartIn});
			FlxG.camera.flash(FlxColor.WHITE, 0.3, null, true);
		}
		if (curBeat == 192 && songName.toLowerCase() == 'blammed')
		{
			FlxTween.tween(darkBG, {alpha: 0}, (Conductor.crochet / 1000) * 6, {ease: FlxEase.quartOut});
			FlxTween.tween(bg, {alpha: 1}, (Conductor.crochet / 1000) * 6, {ease: FlxEase.quartIn});
		}
		if (songName.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200)
		{
			FlxG.camera.zoom += 0.03;
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		if (FlxG.save.data.soundVolume > 0.4)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		else
			FlxG.sound.play(Paths.sound('scrollMenu'), FlxG.save.data.soundVolume);

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		diffText.text = "< ";

		switch (curDifficulty)
		{
			case 0:
				diffText.text += "EASY >";
			case 1:
				diffText.text += 'NORMAL >';
			case 2:
				diffText.text += "HARD >";
		}
	}

	function changeSelection(change:Int = 0)
	{
		// NGio.logEvent('Fresh');
		// FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		if (FlxG.save.data.soundVolume > 0.4)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		else
			FlxG.sound.play(Paths.sound('scrollMenu'), FlxG.save.data.soundVolume);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;
		#end

		#if PRELOAD_ALL
		// FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		#end

		var bullShit:Int = 0;

		totalText.y -= 25;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
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
}


/*class SongMetadata
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
*/