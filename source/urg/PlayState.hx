package urg;

import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import macohi.funkin.pre_vslice.Conductor;
import macohi.funkin.pre_vslice.MusicBeatState;
import macohi.overrides.MText;
import urg.data.save.URGSave;
import urg.data.song.SongData;
import urg.objects.NoteGroup;
import urg.objects.NoteSprite;
import urg.objects.SongObject;

using macohi.util.TimeUtil;

class PlayState extends MusicBeatState
{
	public var debugMode:Bool = true;
	public var songStarted:Bool = false;

	public var SONG:SongObject;

	public var strumNote:NoteSprite;
	public var notes:NoteGroup;

	public var songTimeText:MText;

	public var defaultCamZoom:Float = 1.0;

	override public function create()
	{
		SONG = new SongObject('Test', debugMode);
		SONG.inst.onComplete = function()
		{
			songStarted = false;
		};
		
		songStarted = true;

		strumNote = new NoteSprite(true);
		strumNote.screenCenter();
		add(strumNote);

		notes = new NoteGroup();
		add(notes);

		notes.strumNote = strumNote;
		notes.debugMode = debugMode;
		notes.songData = SONG.data;

		notes.loadNotes();
		updateDownscrollValues();

		songTimeText = new MText(10, 10).makeText('Song Time: 0.00 / 0.00', 16);
		songTimeText.scrollFactor.set();
		add(songTimeText);

		super.create();
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

		if (SONG.inst == null)
		{
			songStarted = false;
			return;
		}

		Conductor.songPosition = SONG.inst.time;

		songTimeText.text = 'Song Position: ';
		songTimeText.text += '${Conductor.songPosition.convert_ms_to_s().round()} s';
		songTimeText.text += ' / ';
		songTimeText.text += '${SONG.inst.length.convert_ms_to_s().round()} s';

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
			if (SONG.inst.playing)
				SONG.inst.pause();
			else
				SONG.inst.resume();
		}

		var timeOffsetSeconds = 1 / 500;

		if (FlxG.keys.pressed.SHIFT)
			timeOffsetSeconds *= 4;

		if (FlxG.keys.anyPressed([W, UP, S, DOWN]))
		{
			if (FlxG.keys.anyPressed([W, UP]))
				SONG.inst.time += timeOffsetSeconds.convert_s_to_ms();
			if (FlxG.keys.anyPressed([S, DOWN]))
				SONG.inst.time -= timeOffsetSeconds.convert_s_to_ms();

			if (SONG.inst.time < 0)
				SONG.inst.time = 0;

			if (SONG.inst.time > SONG.inst.length)
				SONG.inst.time = SONG.inst.length;
		}

		if (FlxG.keys.justPressed.SPACE && !SONG.inst.playing)
		{
			var noteData:NoteData = {};

			if (SONG.data.timeformat == MILLISECONDS)
			{
				noteData.ms = SONG.inst.time;

				noteData.notes = ['Seconds: ${SONG.inst.time.convert_ms_to_s()}'];
			}
			if (SONG.data.timeformat == STEPS)
			{
				noteData.step = curStep;
			}

			var canAdd:Bool = true;

			canAdd = notes.checkForOverlap(noteData);

			if (!canAdd)
				return;

			trace('Added note: $noteData');
			SONG.data.notes.push(noteData);

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
