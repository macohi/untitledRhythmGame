package urg.objects;

import flixel.util.FlxColor;
import urg.data.save.URGSave;
import macohi.funkin.pre_vslice.Conductor;
import urg.data.song.SongData;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class NoteGroup extends FlxTypedSpriteGroup<NoteSprite>
{
	public var songData:SongData;
	public var strumNote:NoteSprite;

	public var curStep:Int = 0;

	public var debugMode:Bool = false;

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

			if (songData.timeformat == MILLISECONDS)
				YOffset = ((Conductor.songPosition - note.data.ms));
			if (songData.timeformat == STEPS)
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
}
