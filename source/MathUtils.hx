package;

import flixel.util.typeLimit.OneOfTwo;
import openfl.system.System;
import flixel.math.FlxMath;
import flixel.util.FlxSort;
import haxe.ds.Vector;
import Song.SwagSong;
import Section.SwagSection;

// basically float or int
typedef Number = OneOfTwo<Int, Float>;

class MathUtils
{
	// do  whatever you  want with this useless crap lol
	public static var a1 = 0.254829592;
	public static var a2 = -0.284496736;
	public static var a3 = 1.421413741;
	public static var a4 = -1.453152027;
	public static var a5 = 1.061405429;
	public static var p = 0.3275911;

	public static function truncateFloat(number:Float, precision:Int):Float
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	public static function nearlyEquals(a:Float, b:Float, diff:Float):Bool
	{
		if ((Math.abs(a) - Math.abs(b)) <= diff)
			return true;

		return false;
	}

	public static function wrap(value:Float, min:Float, max:Float):Float
		{
			var range:Int = Std.int(max - min + 1);
	
			if (value < min)
				value += range * ((min - value) / range + 1);
	
			return min + (value - min) % range;
		}
	

	public static function clamp(mini:Float, maxi:Float, value:Float):Float
	{
		return Math.min(Math.max(mini, value), maxi);
	}

	public static function erf(x:Float):Float
	{
		// Save the sign of x
		var sign = 1;
		if (x < 0)
			sign = -1;
		x = Math.abs(x);

		// A&S formula 7.1.26
		var t = 1.0 / (1.0 + p * x);
		var y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * Math.exp(-x * x);

		return sign * y;
	}
}
