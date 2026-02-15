package urg;

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

class PlayState extends MusicBeatState
{
	public var debugMode:Bool = true;
	public var songStarted:Bool = false;

	public var SONG:SongData;

	public var strumNote:NoteSprite;
	public var notes:FlxTypedSpriteGroup<NoteSprite>;

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

		notes = new FlxTypedSpriteGroup<NoteSprite>();
		add(notes);

		loadNotes();
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
	}

	public function updateDownscrollValues()
	{
		var isDownscroll = URGSave.instance.downscroll.get();

		strumNote.y = 50;

		if (isDownscroll)
			strumNote.y = FlxG.height - strumNote.height - strumNote.y;
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
		songTimeText.text = 'Song Position: ${FlxMath.roundDecimal(Conductor.songPosition / 1000, 2)}s / ${FlxMath.roundDecimal(FlxG.sound.music.time / 1000, 2)}s';

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

			var YOffset:Float = 0;

			if (SONG.timeformat == MILLISECONDS)
				YOffset = ((Conductor.songPosition - note.data.ms));
			if (SONG.timeformat == STEPS)
				YOffset = ((curStep - note.data.step) * note.height);

			// + actually goes down in flixel lol
			var passedStrum:Bool = (note.y > strumNote.y);
			if (!URGSave.instance.downscroll.get())
			{
				YOffset = -YOffset;
				passedStrum = (note.y < strumNote.y);
			}

			note.y = strumNote.y + YOffset;

			if (debugMode)
			{
				if (passedStrum)
					note.color = FlxColor.LIME;
				else
					note.color = FlxColor.RED;
			}
			else
			{
				if (passedStrum)
					note.alpha = 0.3;
				else
					note.alpha = 1.0;
			}
		}
	}

	public function resetCamMusicScrubbing()
	{
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.y = 0;
	}

	public function debugModeFunctions()
	{
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
			{
				FlxG.sound.music.resume();

				resetCamMusicScrubbing();
			}
		}

		var timeOffsetSeconds = 1 / 500;

		if (FlxG.keys.pressed.SHIFT)
			timeOffsetSeconds *= 4;

		if (FlxG.keys.anyPressed([W, UP, S, DOWN]))
		{
			if (FlxG.keys.anyPressed([W, UP]))
			{
				if (FlxG.keys.pressed.CONTROL && !FlxG.sound.music.playing)
					FlxG.camera.y -= timeOffsetSeconds * 1000;
				else
					FlxG.sound.music.time += timeOffsetSeconds * 1000;
			}
			if (FlxG.keys.anyPressed([S, DOWN]))
			{
				if (FlxG.keys.pressed.CONTROL && !FlxG.sound.music.playing)
					FlxG.camera.y += timeOffsetSeconds * 1000;
				else
					FlxG.sound.music.time -= timeOffsetSeconds * 1000;
			}

			if (FlxG.sound.music.time < 0)
				FlxG.sound.music.time = 0;

			if (FlxG.sound.music.time > FlxG.sound.music.length)
				FlxG.sound.music.time = FlxG.sound.music.length;
		}

		if (FlxG.keys.justPressed.CONTROL)
		{
			FlxG.camera.zoom = 0.5;
		}
		if (FlxG.keys.justReleased.CONTROL && FlxG.camera.zoom != defaultCamZoom)
		{
			resetCamMusicScrubbing();
		}

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
