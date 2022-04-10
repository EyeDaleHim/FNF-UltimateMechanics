package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.system.FlxAssets.FlxGraphicAsset;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import sys.thread.Thread;
import sys.thread.ElasticThreadPool;

using StringTools;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	public static var cachePool:ElasticThreadPool = null;

	public static var cachedFrames:Map<String, FlxAtlasFrames> = new Map();
	public static var cachedSprite:Map<String, FlxSprite> = new Map();
	public static var cachedAudio:Map<String, FlxSound> = new Map();

	public static function initCaching():Void
	{
		if (cachePool == null)
			cachePool = new ElasticThreadPool(8, 5);
	}

	public static function preloadAsset(path:String, type:String, library:String)
	{
		switch (type)
		{
			case 'image':
			{
				var object:FlxSprite;
				object = new FlxSprite().loadGraphic(Paths.image(path, library));
				cacheImage(path + Std.string(library), object);
			}
			case 'audio':
			{
				var object:FlxSound = new FlxSound();
				object.loadEmbedded(Paths.sound(path, library));
				cacheAudio(path + Std.string(library), object);
			}
			case 'frames':
			{
				var object:FlxAtlasFrames;
				object = Paths.getSparrowAtlas(path, library);
				cacheFrames(path + Std.string(library), object);
			}
		}
	}

	static function cacheImage(path:String, object:FlxSprite)
	{
		initCaching();

		var formatted:String = '';
		if (path.endsWith('null'))
		{
			formatted = path.split('::')[0];
		}
		else
		{
			formatted = path;
		}

		cachePool.run(function()
		{
			if (!cachedSprite.exists(formatted))
			{
				cachedSprite.set(formatted, object);
				#if debug
				trace('cached $formatted for image');
				#end
			}
		});
	}

	static function cacheAudio(path:String, object:FlxSound)
	{
		initCaching();

		var formatted:String = '';
		if (path.endsWith('null'))
		{
			formatted = path.split('::')[0];
		}
		else
		{
			formatted = path;
		}

		cachePool.run(function()
		{
			if (!cachedAudio.exists(formatted))
			{
				cachedAudio.set(formatted, object);
				
				trace('cached $formatted for audio');
			}
		});
	}

	static function cacheFrames(path:String, object:FlxAtlasFrames)
	{
		initCaching();

		var formatted:String = '';
		if (path.endsWith('null'))
		{
			formatted = path.split('::')[0];
		}
		else
		{
			formatted = path;
		}

		cachePool.run(function()
		{
			if (!cachedFrames.exists(formatted))
			{
				cachedFrames.set(formatted, object);
				trace('cached $formatted for frames');
			}
		});
	}

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	/*static public function getImage(image:String, library:Null<String>)
		{
			
			return FlxG.bitmap.get(image);
	}*/
	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function video(key:String, ?library:String)
	{
		trace('assets/videos/$key.mp4');
		return getPath('videos/$key.mp4', BINARY, library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
	}

	static public function image(key:String, ?library:String, ?noCache:Bool = false):FlxGraphicAsset
	{
		/*
			if (FlxG.bitmap.get(key) == null)
			{
				FlxG.bitmap.add(getPath('images/$key.png', IMAGE, library));
		}*/
		var libraryString:String = '::${library}';

		if (noCache)
			libraryString = '';

		if (!noCache)
		{
			if (cachedSprite.exists(key + libraryString))
				return cachedSprite.get(key + libraryString).pixels;
			else
			{
				var cachingSprite:FlxSprite = new FlxSprite();
				cachingSprite.loadGraphic(getPath('images/$key.png', IMAGE, library));
				cacheImage(key + libraryString, cachingSprite);
			}
		}

		return getPath('images/$key.png', IMAGE, library);
	}

	static public function font(key:String, fontType:String = 'ttf')
	{
		if (key.endsWith('ttf') || key.endsWith('otf'))
			return 'assets/fonts/$key';

		return 'assets/fonts/$key.$fontType';
	}

	inline static public function diag(key:String, song:String, ?library:String)
	{
		return getPath('data/$song/$key.txt', TEXT, library);
	}

	inline static public function getSparrowAtlas(key:String, ?library:String, ?noCache:Bool = false)
	{
		var libraryString:String = '::${library}';

		if (noCache)
			libraryString = '';

		var sparrow:FlxAtlasFrames;

		if (cachedFrames.exists(key + libraryString) && !noCache)
			sparrow = cachedFrames.get(key + libraryString);
		else
		{
			sparrow = FlxAtlasFrames.fromSparrow(image(key, library, noCache), file('images/$key.xml', library));
			cacheFrames(key + libraryString, sparrow);
		}

		return sparrow;
	}

	inline static public function getPackerAtlas(key:String, ?library:String, ?noCache:Bool = false)
	{
		var packer:FlxAtlasFrames;

		var libraryString:String = '::${library}';

		if (noCache)
			libraryString = '';

		if (cachedFrames.exists(key + libraryString) && !noCache)
			packer = cachedFrames.get(key + libraryString);
		else
		{
			packer = FlxAtlasFrames.fromSpriteSheetPacker(image(key, library, noCache), file('images/$key.txt', library));
			cacheFrames(key + libraryString, packer);
		}

		return packer;
	}
}
