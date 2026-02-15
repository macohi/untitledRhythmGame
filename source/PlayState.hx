import flixel.FlxG;
import macohi.funkin.koya.backend.AssetPaths;
import macohi.funkin.pre_vslice.MusicBeatState;

class PlayState extends MusicBeatState
{
	override public function create()
	{
		FlxG.sound.play(AssetPaths.music('StereoMadness'));

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
