package urg.objects;

import urg.data.song.SongData.NoteData;
import macohi.overrides.MSprite;

class NoteSprite extends MSprite
{
	public var strumline:Bool = false;
	public var data:NoteData = null;

	override public function new(strumline:Bool = false, data:NoteData = null)
	{
		super();
		this.strumline = strumline;
		this.data = data;

		makeGraphic(64, 64);
	}
}
