package urg.data.song;

import macohi.util.WindowUtil;
import haxe.Json;
import macohi.funkin.koya.backend.AssetPaths;
import macohi.funkin.koya.backend.KoyaAssets;

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

		var chartPath:String = AssetPaths.chart(song, song);
		if (KoyaAssets.exists(chartPath))
		{
			var jsonData:SongData = null;

			try
			{
				jsonData = Json.parse(KoyaAssets.getText(chartPath));
			}
			catch (e)
			{
				WindowUtil.alert('Error loading song chart', 'Chart: ${chartPath}\n\n${e.message}');
				jsonData = null;
			}

			if (jsonData != null)
				songData = jsonData;
		}

		return songData;
	}
}
