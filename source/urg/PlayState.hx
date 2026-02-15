package urg;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
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
	public var notes:FlxTypedSpriteGroup<NoteSprite>;

	override public function create()
	{
		SONG = Song.loadSong('Test');

		if (SONG == null)
			throw 'Where\'s the song?';

		FlxG.sound.playMusic(AssetPaths.music('songs/Test'));

		#if debug
		#if hscript
		ConsoleUtil.registerObject('SONG', SONG);
		ConsoleUtil.registerFunction('traceSONG', function()
		{
			trace(Json.stringify(SONG));
		});
		ConsoleUtil.registerFunction('copySONG', function()
		{
			Clipboard.text = Json.stringify(SONG, '\t');
		});
		#end
		#end

		strumNote = new NoteSprite(true);
		strumNote.screenCenter();
		strumNote.y = 50;
		add(strumNote);

		notes = new FlxTypedSpriteGroup<NoteSprite>();
		add(notes);

		for (note in SONG.notes)
		{
			var noteSpr:NoteSprite = new NoteSprite(false, note);
			notes.add(noteSpr);
		}

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

		if (SONG.timeformat == MILLISECONDS)
		{
			for (note in notes.members)
			{
				note.y = strumNote.y + ((Conductor.songPosition - note.data.ms) * note.height);
				if (note.y < strumNote.y)
					note.alpha = 0.3;
				else
					note.alpha = 1.0;
			}
		}

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

				noteData.notes = ['Seconds: ${FlxG.sound.music.time / 1000}'];
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
