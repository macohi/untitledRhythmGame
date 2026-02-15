package urg.data.save;

import macohi.save.Save;
import macohi.save.SaveField;

class URGSave extends Save
{
	public static var instance:URGSave;

	public var downscroll:SaveField<Bool>;

	override public function new()
	{
		super();

		SAVE_VERSION = 1;
		init('UntitledRhythmGame');
	}

	override function initFields()
	{
		super.initFields();

		downscroll = new SaveField('downscroll', false, 'Downscroll');
	}
}
