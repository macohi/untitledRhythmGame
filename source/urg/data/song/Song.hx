package urg.data.song;

class Song
{
	public static function loadSong(song:String):SongData
	{
		var songData:SongData = {
			bpm: 100,
			notes: [],
			timeformat: MILLISECONDS
		};

		return songData;
	}
}
