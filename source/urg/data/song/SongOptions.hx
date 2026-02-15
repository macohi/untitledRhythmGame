package urg.data.song;

class SongOptions
{
	public static var SONG_TIMEFORMAT:SongTimeformat = MILLISECONDS;
}

enum abstract SongTimeformat(String) from String to String
{
	var MILLISECONDS = 'ms';
	var BEATS_AND_STEPS = 'beats_and_steps';
}
