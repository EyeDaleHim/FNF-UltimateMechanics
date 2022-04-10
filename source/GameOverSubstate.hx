package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxGroup.FlxTypedGroup;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	var motivTxts:FlxTypedGroup<FlxText>;

	public function new(x:Float, y:Float)
	{
		var daStage = PlayState.curStage;
		var daBf:String = '';
		switch (daStage)
		{
			case 'school':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'schoolEvil':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			default:
				daBf = 'bf';
		}

		super();

		PlayState.unspawnNotes = [];

		Conductor.songPosition = 0;

		motivTxts = new FlxTypedGroup<FlxText>();
		add(motivTxts);

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			if (!isEnding)
				createText(true);
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			FlxG.switchState(new MainMenuState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, (0.04 * (30 / Main.framerate)));
			FlxTween.tween(FlxG.camera, {zoom: 1}, 0.7, {ease: FlxEase.quadOut});
			FlxG.camera.active = true;
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		// FlxG.log.add('beat');
		createText();
	}

	var randomText:Array<String> = [
		"Come on...", "Don't stop...", "Keep going!", "You can do it!", "You got this!", "You can make it!", "You will ace this!", "You can win!",
		"Fight back!", "Fight hard!", "Try again!", "You'll do better!", "You'll be a winner!", "Beat them hard!", "Don't give up!", "Keep holding on!",
		"You will win!", "Just retry!", "You'll get them eventually!", "You can't lose just yet!", "You can't die just yet!", "You can't give up just yet!", 
		"Come on!", "Just come on!", "Go!"
	];

	var acceptedText:Array<String> = [
		"Yes!",
		"Good luck!",
		"You got this!",
		"Have fun!",
		"You'll win!",
		"You'll do it!",
		"Yay!"
	];

	function createText(didThing:Bool = false):Void
	{
		var txtList:Array<String> = randomText;
		var randomNum:Int = 4;
		if (didThing)
		{
			txtList = acceptedText;
			randomNum = 7;
		}

		for (i in 0...FlxG.random.int(2, randomNum))
		{
			var motivationTxt:FlxText = new FlxText(0, 0, 0, FlxG.random.getObject(randomText));
			motivationTxt.setFormat(Paths.font("vcr", "ttf"), FlxG.random.int(24, 32), FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
			motivationTxt.setPosition(FlxG.camera.scroll.x + (FlxG.width * FlxG.random.float(0, 1)) * FlxG.camera.zoom,
				FlxG.camera.scroll.y + (FlxG.height * FlxG.random.float(0, 1)) * FlxG.camera.zoom);
			if (!didThing)
			{
				FlxTween.tween(motivationTxt, {alpha: 0}, 1.4, {ease: FlxEase.quadOut});
				FlxTween.tween(motivationTxt, {x: motivationTxt.x + FlxG.random.float(-50, 50)}, 2.7, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						motivationTxt.kill();
						motivTxts.remove(motivationTxt, true);
						motivationTxt.destroy();
					}
				});
			}
			motivTxts.add(motivationTxt);
		}
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxTween.tween(FlxG.camera, {zoom: 0.1}, 4, {ease: FlxEase.quadInOut});
				FlxG.camera.fade(FlxColor.BLACK, 2, false);
				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
