package urg;

import flixel.FlxG;
import macohi.funkin.koya.backend.AssetPaths;
import macohi.funkin.pre_vslice.MusicBeatState;

class PlayState extends MusicBeatState
{
	public var debugMode:Bool = true;
	public var songStarted:Bool = false;

	override public function create()
	{
		FlxG.sound.playMusic(AssetPaths.music('StereoMadness'));
		songStarted = true;

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!songStarted) return;

		if (debugMode)
		{
			debugModeFunctions();
		}
	}

	public function debugModeFunctions()
	{
	}
}
