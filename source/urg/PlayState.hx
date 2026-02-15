package urg;

import urg.data.song.Song;
import urg.data.song.SongData;
import flixel.FlxG;
import macohi.funkin.koya.backend.AssetPaths;
import macohi.funkin.pre_vslice.MusicBeatState;

class PlayState extends MusicBeatState
{
	public var debugMode:Bool = true;
	public var songStarted:Bool = false;

	public var SONG:SongData;

	override public function create()
	{
		FlxG.sound.playMusic(AssetPaths.music('songs/Test'));
		SONG = Song.loadSong('Test');

		if (SONG == null)
		{
			throw 'Where\'s the song?';
		}

		songStarted = true;

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!songStarted) return;

		if (debugMode)
		{
			debugModeFunctions();
		}
	}

	public function debugModeFunctions()
	{

		if (FlxG.keys.justReleased.SPACE)
		{

		}
	}
}
