package urg.objects;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import flixel.util.FlxSort;
import macohi.funkin.pre_vslice.Conductor;
import urg.data.save.URGSave;
import urg.data.song.SongData.NoteData;

class NoteGroup extends FlxTypedSpriteGroup<NoteSprite>
{
	public var song:SongObject;
	public var strumNote:NoteSprite;

	public var curStep:Int = 0;

	public var debugMode:Bool = false;

	public var goodNoteHit:FlxTypedSignal<NoteSprite->Void> = new FlxTypedSignal<NoteSprite->Void>();

	public var missNote:FlxTypedSignal<NoteSprite->Void> = new FlxTypedSignal<NoteSprite->Void>();
	public var badNoteHit:FlxTypedSignal<NoteSprite->Void> = new FlxTypedSignal<NoteSprite->Void>();
	public var ghostNoteHit:FlxTypedSignal<NoteSprite->Void> = new FlxTypedSignal<NoteSprite->Void>();

	public function checkForOverlap(noteData:NoteData):Bool
	{
		for (note in members)
		{
			if (song.data.timeformat == STEPS)
				if (noteData.step - note.data.step < 1)
				{
					return false;
					trace('Overlapping with a note.');
				}

			if (song.data.timeformat == MILLISECONDS)
			{
				var msDiff = new NoteSprite().height;

				if (noteData.ms - note.data.ms < msDiff)
				{
					return false;
					trace('Overlapping with a note. (${noteData.ms - note.data.ms}ms < ${msDiff}ms)');
				}
			}
		}

		return true;
	}

	public function reloadNotes()
	{
		for (note in this.members)
		{
			this.members.remove(note);
			note.destroy();
		}

		this.clear();

		this.loadNotes();
	}

	public function loadNotes()
	{
		song.data.notes.sort((struct1, struct2) ->
		{
			var s1v = 0.0;
			var s2v = 0.0;

			if (song.data.timeformat == MILLISECONDS)
			{
				s1v = struct1.ms;
				s2v = struct2.ms;
			}

			if (song.data.timeformat == STEPS)
			{
				s1v = struct1.step;
				s2v = struct2.step;
			}

			return FlxSort.byValues(FlxSort.ASCENDING, s1v, s2v);
		});

		for (note in song.data.notes)
		{
			if (song.data.timeformat == MILLISECONDS && note.ms == null)
				continue;
			if (song.data.timeformat == STEPS && note.step == null)
				continue;

			var noteSpr:NoteSprite = new NoteSprite(false, note);
			add(noteSpr);
			noteSpr.screenCenter();
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		for (note in this.members)
		{
			if (note == null)
			{
				this.members.remove(note);
				continue;
			}

			var YOffset:Float = 0;

			if (song.data.timeformat == MILLISECONDS)
				YOffset = ((Conductor.songPosition - note.data.ms));
			if (song.data.timeformat == STEPS)
				YOffset = ((curStep - note.data.step) * note.height);

			if (!URGSave.instance.downscroll.get())
				YOffset = -YOffset;

			note.y = strumNote.y + YOffset;

			// + actually goes down in flixel lol
			var passedStrum:Bool = (note.y > strumNote.y);
			var yoMin:Float = -note.height * 16;

			if (!URGSave.instance.downscroll.get())
				passedStrum = (note.y < strumNote.y);
			else
				yoMin = FlxG.width + -yoMin;

			note.active = !(Math.abs(YOffset) > (FlxG.height * 2));

			if (debugMode)
			{
				if (passedStrum)
					note.color = FlxColor.LIME;
				else
					note.color = FlxColor.RED;
			}
			else
			{
				var destroyNote:Bool = false;

				if (passedStrum)
				{
					note.alpha = 0.3;

					if (!note.late)
					{
						note.late = true;
						missNote.dispatch(note);
					}

					if (!URGSave.instance.downscroll.get() && note.y < yoMin)
						destroyNote = true;

					if (URGSave.instance.downscroll.get() && note.y > yoMin)
						destroyNote = true;
				}
				else
					note.alpha = 1.0;

				if (song.data.timeformat == MILLISECONDS && Math.abs(YOffset) < PlayState.INPUT_WINDOW_MS)
				{
					if (FlxG.keys.justReleased.SPACE)
					{
						destroyNote = true;
						goodNoteHit.dispatch(note);
					}
				}

				if (destroyNote)
				{
					this.members.remove(note);
					note.destroy();
				}
			}
		}
	}
}
