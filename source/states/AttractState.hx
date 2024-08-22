package states;

#if html5
import funkin.graphics.video.FlxVideo;
#else
import objects.VideoSprite;
#end

/**
 * After about 2 minutes of inactivity on the title screen,
 * the game will enter the Attract state, as a reference to physical arcade machines.
 *
 * In the current version, this just plays the ~~Kickstarter trailer~~ Erect teaser, but this can be changed to
 * gameplay footage, a generic game trailer, or something more elaborate.
 */
class AttractState extends MusicBeatState
{
  static final ATTRACT_VIDEO_PATH:String = Paths.video('toyCommercial');

  public override function create():Void
  {
    // Pause existing music.
    if (FlxG.sound.music != null)
    {
      FlxG.sound.music.destroy();
      FlxG.sound.music = null;
    }

    #if html5
    trace('Playing web video ${ATTRACT_VIDEO_PATH}');
    playVideoHTML5(ATTRACT_VIDEO_PATH);
    #end

    #if (hxvlc || hxCodec)
    trace('Playing native video ${ATTRACT_VIDEO_PATH}');
    playVideoNative(ATTRACT_VIDEO_PATH);
    #end
  }

  #if html5
  var vid:FlxVideo;

  function playVideoHTML5(filePath:String):Void
  {
    // Video displays OVER the FlxState.
    vid = new FlxVideo(filePath);
    if (vid != null)
    {
      vid.zIndex = 0;

      vid.finishCallback = onAttractEnd;

      add(vid);
    }
    else
    {
      trace('ALERT: Video is null! Could not play cutscene!');
    }
  }
  #end

  #if VIDEOS_ALLOWED
  var vid:VideoSprite;

  function playVideoNative(filePath:String):Void
  {
    // Video displays OVER the FlxState.
    vid = new VideoSprite(filePath,false);

    if (vid != null)
    {
      //vid.zIndex = 0;
      vid.finishCallback = onAttractEnd.bind();

      add(vid);
      
      vid.play();
    }
    else
    {
      trace('ALERT: Video is null! Could not play cutscene!');
    }
  }
  #end

  public override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    // If the user presses any button, skip the video.
    if (FlxG.keys.justPressed.ANY && !controls.VOLUME_MUTE && !controls.VOLUME_UP && !controls.VOLUME_DOWN)
    {
      onAttractEnd();
    }
  }

  /**
   * When the attraction state ends (after the video ends or the user presses any button),
   * switch immediately to the title screen.
   */
  function onAttractEnd():Void
  {
    #if html5
    if (vid != null)
    {
      remove(vid);
    }
    #end

    #if (hxvlc || hxCodec)
    if (vid != null)
    {
      vid.pause();
      remove(vid);
      @:privateAccess
      vid.alreadyDestroyed = true;
    }
    #end

    #if (html5 || hxCodec)
    vid.destroy();
    vid = null;
    #end
    FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.01);
    FlxG.switchState(() -> new TitleState());
  }
}
