package urg.data.song;

import haxe.Json;
import macohi.funkin.koya.backend.KoyaAssets;
import macohi.util.WindowUtil;

using macohi.funkin.vslice.util.AnsiUtil;

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

		var chartPath:String = URGAssetPaths.chart(song.toLowerCase());
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
		else
		{
			trace(' WARNING '.warning() + ' Missing song JSON: ${song.toLowerCase()}');
		}

		return songData;
	}
}
