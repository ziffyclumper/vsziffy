package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class UndertaleSubState extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	public function new()
	{
		var daStage = PlayState.curStage;

		super();

		Conductor.songPosition = 0;
    FlxG.camera.scroll.set();
		FlxG.camera.target = null;


	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}
}
