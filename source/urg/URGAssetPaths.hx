package urg;

import macohi.funkin.koya.backend.AssetPaths;

class URGAssetPaths
{
	public static function chart(song:String, ?library:String)
		return AssetPaths.json('data/$song', library);
}
