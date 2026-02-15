package urg.data.song;

import urg.data.song.SongOptions.SongTimeformat;

typedef SongData =
{
	bpm:Float,
	notes:Array<NoteData>,
	?timeformat:SongTimeformat,
}

typedef NoteData =
{
	?ms:Float,

	// ?beat:Int,
	?step:Int,

	?notes:Array<String>,
}
