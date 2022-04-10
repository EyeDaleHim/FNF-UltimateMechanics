package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
import flixel.addons.ui.FlxUIState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxRect;
import flixel.group.FlxGroup.FlxTypedGroup;

enum TransitionType
{
	IN;
	OUT;
}

// unused stuff for now

class Transition extends FlxCamera
{
	public static var instance:FlxCamera;
	public static var group:FlxTypedGroup<FlxSprite>;

	public static function transition(trans:TransitionType, duration:Float, finishCallback:Void->Void):Void
	{
		instance = new FlxCamera();
		this = instance;
		FlxG.cameras.add(instance);

		group = new FlxTypedGroup<FlxSprite>();
		MusicBeatState.add(group);

		var transGradient:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height,
			(trans == IN ? [0x0, FlxColor.BLACK] : [FlxColor.BLACK, 0x0]));
		transGradient.scrollFactor.set();
		transGradient.cameras = [instance];
		group.add(transGradient);

		var transBlack:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height + 400, FlxColor.BLACK);
		transBlack.scrollFactor.set();
		transBlack.cameras = [instance];
		group.add(transBlack);

		switch (trans)
		{
			case IN:
				{
					transGradient.y = transBlack.y - transBlack.height;
					FlxTween.tween(transGradient, {y: transGradient.height + 50}, duration, {
						onComplete: function(twn:FlxTween)
						{
							if (finishCallback != null)
							{
								finishCallback();

								remove(transGradient);
								remove(transBlack);

								transGradient.destroy();
								transBlack.destroy();

								FlxG.cameras.remove(instance);
								this = null;
								instance = null;
							}
						},
						onUpdate: function(twn:FlxTween)
						{
							transBlack.y = transGradient.y + transGradient.height;
						},
						ease: FlxEase.linear
					});
				}
			case OUT:
				{
					transGradient.y = -transGradient.height;
					transBlack.y = transGradient.y - transBlack.height + 50;
					FlxTween.tween(transGradient, {y: transGradient.height + 50}, duration, {
						onComplete: function(twn:FlxTween)
						{
							if (finishCallback != null)
							{
								finishCallback();

								remove(transGradient);
								remove(transBlack);

								transGradient.destroy();
								transBlack.destroy();

								FlxG.cameras.remove(instance);
								this = null;
							}
						},
						onUpdate: function(twn:FlxTween)
						{
							transBlack.y = transGradient.y - transBlack.height;
						},
						ease: FlxEase.linear
					});
				}
		}
	}
}
