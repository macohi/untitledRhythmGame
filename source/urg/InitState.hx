package urg;

import flixel.FlxG;
import macohi.overrides.MState;
import urg.data.save.URGSave;

class InitState extends MState
{
	override function create()
	{
		super.create();

		URGSave.instance = new URGSave();

		FlxG.switchState(() -> new PlayState());
	}
}
