package urg;

import lime.system.Clipboard;
import haxe.Json;
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

	public var strumNote:NoteSprite;

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
		ConsoleUtil.registerFunction('traceSONG', function() {
			trace(Json.stringify(SONG));
		});
		ConsoleUtil.registerFunction('copySONG', function() {
			Clipboard.text = Json.stringify(SONG, '\t');
		});
		#end
		#end

		strumNote = new NoteSprite();
		strumNote.screenCenter();
		strumNote.y = 50;
		add(strumNote);

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
			var noteData:NoteData = {};

			if (SONG.timeformat == MILLISECONDS)
			{
				noteData.ms = FlxG.sound.music.time;

				noteData.notes = [
					'Seconds: ${FlxG.sound.music.time / 1000}'
				];
			}
			if (SONG.timeformat == BEATS_AND_STEPS)
			{
				noteData.beat = curBeat;
				noteData.step = curStep;
			}

			trace('Added note: $noteData');

			SONG.notes.push(noteData);

			FlxTween.color(strumNote, 1, FlxColor.RED, FlxColor.WHITE, {
				ease: FlxEase.quadInOut
			});
		}
	}
}
