module gargula.resource;

//public import gargula.resource.font;
public import gargula.resource.music :
    play, update, stop, pause, resume, isPlaying,
    setVolume, setPitch, getTimeLength, getTimePlayed;
public import gargula.resource.sound :
    update, unload, play, stop, pause, resume, playMulti,
    stopMulti, isPlaying, setVolume, setPitch;
//public import gargula.resource.texture;
public import gargula.resource.wave :
    unload, loadSound;

/// Toggle playing audio objects, works for Sound and Music
void toggle(T)(T audioObject)
{
    if (isPlaying(audioObject))
    {
        pause(audioObject);
    }
    else
    {
        resume(audioObject);
    }
}
