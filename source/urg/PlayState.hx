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

		loadNotes();

		songStarted = true;

		if (debugMode)
		{
			FlxG.sound.music.pause();
		}

		super.create();
	}

	public function reloadNotes()
	{
		for (note in notes.members)
		{
			notes.members.remove(note);
			note.destroy();
		}

		notes.clear();

		loadNotes();
	}

	public function loadNotes()
	{
		for (note in SONG.notes)
		{
			if (SONG.timeformat == MILLISECONDS && note.ms == null)
				continue;
			if (SONG.timeformat == STEPS && note.step == null)
				continue;

			var noteSpr:NoteSprite = new NoteSprite(false, note);
			notes.add(noteSpr);
			notes.screenCenter();
		}
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

		for (note in notes.members)
		{
			if (note == null)
			{
				notes.members.remove(note);
				continue;
			}

			if (SONG.timeformat == MILLISECONDS)
				note.y = strumNote.y + ((Conductor.songPosition - note.data.ms));
			if (SONG.timeformat == STEPS)
				note.y = strumNote.y + ((curStep - note.data.step) * note.height);

			if (debugMode)
			{
				if (note.y < strumNote.y)
					note.color = FlxColor.LIME;
				else
					note.color = FlxColor.RED;
			}
			else
			{
				if (note.y < strumNote.y)
					note.alpha = 0.3;
				else
					note.alpha = 1.0;
			}
		}
	}

	public function debugModeFunctions()
	{
		if (FlxG.keys.justReleased.ENTER)
		{
			if (FlxG.sound.music.playing)
				FlxG.sound.music.pause();
			else
				FlxG.sound.music.resume();
		}

		var timeOffsetSeconds = 1 / 10;

		if (FlxG.keys.anyPressed([W, UP]))
			FlxG.sound.music.time -= timeOffsetSeconds * 1000;
		if (FlxG.keys.anyPressed([S, DOWN]))
			FlxG.sound.music.time += timeOffsetSeconds * 1000;

		if (FlxG.keys.justPressed.SPACE)
		{
			var noteData:NoteData = {};

			if (SONG.timeformat == MILLISECONDS)
			{
				noteData.ms = FlxG.sound.music.time;

				noteData.notes = ['Seconds: ${FlxG.sound.music.time / 1000}'];
			}
			if (SONG.timeformat == STEPS)
			{
				noteData.step = curStep;
			}

			trace('Added note: $noteData');

			SONG.notes.push(noteData);

			highlightStrum(FlxColor.RED);

			reloadNotes();
		}
	}

	public function highlightStrum(color:Null<FlxColor>)
	{
		if (color == null)
			return;

		FlxTween.cancelTweensOf(strumNote);
		FlxTween.color(strumNote, 1, color, FlxColor.WHITE, {
			ease: FlxEase.quadInOut
		});
	}
}
