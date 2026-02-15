package urg.objects;

import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.system.debug.console.ConsoleUtil;
import haxe.Json;
import lime.system.Clipboard;
import macohi.funkin.koya.backend.AssetPaths;
import urg.data.song.Song;
import urg.data.song.SongData;

class SongObject
{
	public var data:SongData;

	public var debugMode:Bool = false;

	public function new(song:String, ?debugMode:Bool = false)
	{
		this.debugMode = debugMode;

		data = Song.loadSong(song);

		if (data == null)
			throw 'Where\'s the song?';

		#if debug
		#if hscript
		ConsoleUtil.registerObject('SONG', data);
		ConsoleUtil.registerFunction('traceSONG', function()
		{
			trace(Json.stringify(data));
		});
		ConsoleUtil.registerFunction('copySONG', function()
		{
			Clipboard.text = Json.stringify(data, '\t');
		});
		#end
		#end

		FlxG.sound.playMusic(AssetPaths.music('songs/$song'));

		if (this.debugMode)
		{
			FlxG.sound.music.pause();
		}
	}
}
