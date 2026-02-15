import urg.InitState;
import macohi.funkin.koya.backend.AssetPaths;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, InitState));
	}
}
