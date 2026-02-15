package urg;

import urg.objects.NoteGroup;
import flixel.util.FlxSort;
import macohi.overrides.MSprite;
import flixel.math.FlxMath;
import macohi.overrides.MText;
import urg.data.save.URGSave;
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

using macohi.util.TimeUtil;

class PlayState extends MusicBeatState
{
	public var debugMode:Bool = true;
	public var songStarted:Bool = false;

	public var SONG:SongData;

	public var strumNote:NoteSprite;
	public var notes:NoteGroup;

	public var songTimeText:MText;

	public var defaultCamZoom:Float = 1.0;

	override public function create()
	{
		SONG = Song.loadSong('Test');

		if (SONG == null)
			throw 'Where\'s the song?';

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
		add(strumNote);

		notes = new NoteGroup();
		add(notes);

		notes.loadNotes();
		updateDownscrollValues();

		songTimeText = new MText(10, 10).makeText('Song Time: 0.00 / 0.00', 16);
		songTimeText.scrollFactor.set();
		add(songTimeText);

		FlxG.sound.playMusic(AssetPaths.music('songs/Test'));
		songStarted = true;

		if (debugMode)
		{
			FlxG.sound.music.pause();
		}

		super.create();

		notes.strumNote = strumNote;
		notes.debugMode = debugMode;
		notes.songData = SONG;
	}

	public function updateDownscrollValues()
	{
		var isDownscroll = URGSave.instance.downscroll.get();

		strumNote.y = 50;

		if (isDownscroll)
			strumNote.y = FlxG.height - strumNote.height - strumNote.y;
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
		songTimeText.text = 'Song Position: ';
		songTimeText.text += '${Conductor.songPosition.convert_ms_to_s().round()} s';
		songTimeText.text += ' / ';
		songTimeText.text += '${FlxG.sound.music.length.convert_ms_to_s().round()} s';

		if (debugMode)
		{
			debugModeFunctions();
		}
		notes.curStep = curStep;
	}

	public function debugModeFunctions()
	{
		if (FlxG.keys.anyJustPressed([Q, E]))
		{
			if (FlxG.keys.justPressed.Q)
				FlxG.camera.zoom -= 0.1;
			if (FlxG.keys.justPressed.E)
				FlxG.camera.zoom += 0.1;

			if (FlxG.camera.zoom < 0.5)
				FlxG.camera.zoom = 0.5;
			if (FlxG.camera.zoom > 1.0)
				FlxG.camera.zoom = 1.0;
		}

		if (FlxG.keys.justReleased.D)
		{
			URGSave.instance.downscroll.set(!URGSave.instance.downscroll.get());
			updateDownscrollValues();
		}

		if (FlxG.keys.justReleased.ENTER)
		{
			if (FlxG.sound.music.playing)
				FlxG.sound.music.pause();
			else
				FlxG.sound.music.resume();
		}

		var timeOffsetSeconds = 1 / 500;

		if (FlxG.keys.pressed.SHIFT)
			timeOffsetSeconds *= 4;

		if (FlxG.keys.anyPressed([W, UP, S, DOWN]))
		{
			if (FlxG.keys.anyPressed([W, UP]))
				FlxG.sound.music.time += timeOffsetSeconds.convert_s_to_ms();
			if (FlxG.keys.anyPressed([S, DOWN]))
				FlxG.sound.music.time -= timeOffsetSeconds.convert_s_to_ms();

			if (FlxG.sound.music.time < 0)
				FlxG.sound.music.time = 0;

			if (FlxG.sound.music.time > FlxG.sound.music.length)
				FlxG.sound.music.time = FlxG.sound.music.length;
		}

		if (FlxG.keys.justPressed.SPACE && !FlxG.sound.music.playing)
		{
			var noteData:NoteData = {};

			if (SONG.timeformat == MILLISECONDS)
			{
				noteData.ms = FlxG.sound.music.time;

				noteData.notes = ['Seconds: ${FlxG.sound.music.time.convert_ms_to_s()}'];
			}
			if (SONG.timeformat == STEPS)
			{
				noteData.step = curStep;
			}

			var canAdd:Bool = true;

			canAdd = notes.checkForOverlap(noteData);

			if (!canAdd)
				return;

			trace('Added note: $noteData');
			SONG.notes.push(noteData);

			highlightStrum(FlxColor.RED);
			notes.reloadNotes();
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
