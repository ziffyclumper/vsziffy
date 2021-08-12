package;

import flixel.ui.FlxButton.FlxTypedButton;
import flixel.addons.text.FlxTypeText;
#if sys
import smTools.SMFile;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;
import openfl.Assets;

#if windows
import Discord.DiscordClient;
#end

#if cpp
import sys.thread.Thread;
#end

using StringTools;

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var skipped:Bool = false;
	var firstIcon:FlxSprite = new FlxSprite();
	var textDial:FlxTypeText;
	var logo:FlxSprite;
	var enterText:FlxText;
	var skipText:FlxText;
	
	override public function create():Void
	{
		#if polymod
		polymod.Polymod.init({modRoot: "mods", dirs: ['introMod']});
		#end
		
		#if sys
		if (!sys.FileSystem.exists(Sys.getCwd() + "/assets/replays"))
			sys.FileSystem.createDirectory(Sys.getCwd() + "/assets/replays");
		#end

		@:privateAccess
		{
			trace("Loaded " + openfl.Assets.getLibrary("default").assetsLoaded + " assets (DEFAULT)");
		}
		
		PlayerSettings.init();

		#if windows
		DiscordClient.initialize();

		Application.current.onExit.add (function (exitCode) {
			DiscordClient.shutdown();
		 });
		 
		#end

		trace('hello');

		// DEBUG BULLSHIT

		super.create();

		// NGio.noLogin(APIStuff.API);

		#if ng
		var ng:NGio = new NGio(APIStuff.API, APIStuff.EncKey);
		trace('NEWGROUNDS LOL');
		#end

		FlxG.save.bind('funkin', 'ninjamuffin99');

		KadeEngineData.initSave();

		// var file:SMFile = SMFile.loadFile("file.sm");
		// this was testing things
		
		Highscore.load();

		if (FlxG.save.data.weekUnlocked != null)
		{
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#else
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#end
	}

	function startIntro()
	{
		if (!initialized)
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();
			FlxG.sound.playMusic(Paths.music('onceum', 'goop'), 1);
			Conductor.changeBPM(131);
		}

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(blackScreen);

		firstIcon = new FlxSprite(-150, -100);
		firstIcon.frames = Paths.getSparrowAtlas('undertale/introPictures', 'goop');
		firstIcon.animation.addByPrefix('1', '0_1 instance 1', 24, false);
		firstIcon.animation.addByPrefix('2', '0_2 instance 1', 24, false);
		firstIcon.animation.addByPrefix('3', '0_3 instance 1', 24, false);
		firstIcon.animation.addByPrefix('4', '0_4 instance 1', 24, false);
		firstIcon.animation.addByPrefix('5', '0_5 instance 1', 24, false);
		firstIcon.animation.addByPrefix('6', '0_6 instance 1', 24, false);
		firstIcon.animation.play('1');
		firstIcon.antialiasing = true;
		firstIcon.updateHitbox();
		firstIcon.screenCenter();
		firstIcon.y -= 140;
		add(firstIcon);

		textDial = new FlxTypeText(0, 0, 650, 'Long ago, two worms ruled over Earth: BOYFRIEND and GIRLFRIEND.', 48);
		textDial.color = FlxColor.WHITE;
		textDial.font = Paths.font('determination.ttf');
		textDial.delay = 0.08;
		textDial.sounds = [FlxG.sound.load(Paths.sound('txt2', 'goop'), 0.6)];
		textDial.scrollFactor.set();
		textDial.updateHitbox();
		textDial.screenCenter();
		textDial.y += 100;
		add(textDial);

		skipText = new FlxText(0, FlxG.height - 40, 900, 'Press ENTER to Skip', 24);
		skipText.setFormat(Paths.font('determination.ttf'), 24, FlxColor.WHITE, FlxTextAlign.CENTER);
		skipText.updateHitbox();
		skipText.scrollFactor.set();
		skipText.alpha = 0;
		skipText.screenCenter(X);
		add(skipText);

		logo = new FlxSprite(0, 0).loadGraphic(Paths.image('undertale/logo', 'goop'));
		logo.antialiasing = true;
		logo.scrollFactor.set();
		logo.visible = false;
		logo.updateHitbox();
		logo.screenCenter();
		logo.y -= 50;
		add(logo);

		enterText = new FlxText(0, 0, 'Press Enter to Start');
		enterText.setFormat(Paths.font('determination.ttf'), 48, FlxColor.WHITE, FlxTextAlign.CENTER);
		enterText.updateHitbox();
		enterText.scrollFactor.set();
		enterText.visible = false;
		enterText.screenCenter(X);
		enterText.y = logo.y + logo.height - 70;
		add(enterText);

		FlxTween.tween(skipText, {alpha: 0.5}, 2, {startDelay: 0.5});

		textDial.start(true);

		//holy shit who programmed this???? 
		new FlxTimer().start(7, function(tmr1:FlxTimer) {
			FlxTween.tween(firstIcon, {alpha: 0}, 0.3, {onComplete: function(twn:FlxTween)
				{
					firstIcon.animation.play('2');
					FlxTween.tween(firstIcon, {alpha: 1}, 0.3);
				}});
		});
		new FlxTimer().start(7.6, function(tmr2:FlxTimer) {
			textDial.resetText('One day, after a long and strenuous battle, BOYFRIEND decided to take a rest.');
			textDial.start(true);
		});

		new FlxTimer().start(14, function(tmr3:FlxTimer) {
			FlxTween.tween(firstIcon, {alpha: 0}, 0.3, {onComplete: function(twn:FlxTween)
				{
					firstIcon.animation.play('3');
					FlxTween.tween(firstIcon, {alpha: 1}, 0.3);
				}});
		});
		new FlxTimer().start(14.6, function(tmr4:FlxTimer) {
			textDial.resetText('But a bright light appeared in front of him that caught his attention.');
			textDial.start(true);
		});

		new FlxTimer().start(22, function(tmr5:FlxTimer) {
			FlxTween.tween(firstIcon, {alpha: 0}, 0.3, {onComplete: function(twn:FlxTween)
				{
					firstIcon.animation.play('4');
					textDial.visible = false;
					FlxTween.tween(firstIcon, {alpha: 1}, 0.3);
				}});
		});

		new FlxTimer().start(26, function(tmr6:FlxTimer) {
			FlxTween.tween(firstIcon, {alpha: 0}, 0.3, {onComplete: function(twn:FlxTween)
				{
					firstIcon.animation.play('5');
					textDial.visible = true;
					FlxTween.tween(firstIcon, {alpha: 1}, 0.3);
					textDial.resetText('wtf is that goop lmao');
					textDial.start(true);
				}});
		});

		new FlxTimer().start(32, function(tmr7:FlxTimer) {
			FlxTween.tween(firstIcon, {alpha: 0}, 0.3, {onComplete: function(twn:FlxTween)
				{
					firstIcon.animation.play('6');
					FlxTween.tween(firstIcon, {alpha: 1}, 0.3);
					textDial.resetText('oh fuck');
					textDial.start(true);
				}});
		});

		new FlxTimer().start(33.5, function(tmr7:FlxTimer) {
			skipIntro();
		});


		persistentUpdate = true;
		FlxG.mouse.visible = false;

		if (initialized) {

		}
		else {
			initialized = true;
		}

		// credGroup.add(credTextShit);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = controls.ACCEPT;

		if (pressedEnter && !skipped)
		{					
			skipIntro();
		}
		else if(pressedEnter && skipped) {
			MainMenuState.firstStart = true;
			MainMenuState.finishedFunnyMove = false;
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	function skipIntro() {
		textDial.visible = false;
		textDial.skip();
		textDial.destroy();			
		firstIcon.visible = false;
		logo.visible = true;
		enterText.visible = true;
		skipText.visible = false;
		FlxG.sound.music.stop();
		FlxG.sound.play(Paths.sound('intronoise', 'goop'));
		skipped = true;	
	}
}
