package;

import lime.utils.Assets;
import flixel.util.FlxSort;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];

	public static function difficultyString():String
	{
		return difficultyArray[PlayState.storyDifficulty];
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	static var sortBy:Int = 0;

	static function sortVals(Obj1:Int, Obj2:Int):Int
	{
		if (sortBy != -1 && sortBy != 1)
			sortBy = FlxSort.ASCENDING;

		return FlxSort.byValues(sortBy, Obj1, Obj2);
	}

	public static function numberArray(max:Int, min = 0, ?order:FlxSort = null, sort:Int = -1):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		sortBy = sort;
		for (i in min...max)
		{
			dumbArray.push(i);
		}

		if (order != null)
		{
			dumbArray.sort(sortVals);
			sortBy = 0;
		}
		return dumbArray;
	}
}
