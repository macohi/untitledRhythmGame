package urg;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import urg.objects.NoteSprite;
import macohi.funkin.pre_vslice.Conductor;
#if debug
#if hscript
import flixel.system.debug.console.ConsoleUtil;
#end
#end
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

	public var centerNote:NoteSprite;

	override public function create()
	{
		FlxG.sound.playMusic(AssetPaths.music('songs/Test'));
		SONG = Song.loadSong('Test');

		if (SONG == null)
		{
			throw 'Where\'s the song?';
		}

		#if debug
		#if hscript
		ConsoleUtil.registerObject('SONG', SONG);
		#end
		#end

		centerNote = new NoteSprite();
		centerNote.screenCenter();
		add(centerNote);

		songStarted = true;

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!songStarted)
			return;

		if (FlxG.sound.music == null)
		{
			songStarted = false;
			return;
		}

		Conductor.songPosition = FlxG.sound.music.time;

		if (debugMode)
		{
			debugModeFunctions();
		}
	}

	public function debugModeFunctions()
	{
		if (FlxG.keys.justReleased.SPACE)
		{
			var noteData:NoteData = {
				ms: FlxG.sound.music.time,

				beat: curBeat,
				step: curStep,
			};

			trace('Added note: $noteData');

			SONG.notes.push(noteData);

			FlxTween.color(centerNote, 1, FlxColor.RED, FlxColor.WHITE, {
				ease: FlxEase.quadInOut
			});
		}
	}
}
