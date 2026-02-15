package urg.data.song;

class Song
{
	public static function loadSong(song:String):SongData
	{
		song = song.toLowerCase();

		var songData:SongData = {
			bpm: 100,
			timeformat: MILLISECONDS,
			notes: [],
		};

		if (song == 'test')
			songData.timeformat = BEATS_AND_STEPS;

		return songData;
	}
}
