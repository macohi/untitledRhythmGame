package urg;

import flixel.FlxG;
import urg.data.save.URGSave;
import macohi.overrides.MState;

class InitState extends MState
{
	override function create()
	{
		super.create();

		URGSave.instance = new URGSave();

		FlxG.switchState(() -> new PlayState());
	}
}
