module gargula.resource;

public import gargula.resource.audiostream :
    update, close, isProcessed, play, pause, resume,
    isPlaying, stop, setVolume, setPitch;
public import gargula.resource.font :
    unload, drawText, measureText, getGlyphIndex;
public import gargula.resource.music :
    unload, play, update, stop, pause, resume, isPlaying,
    setVolume, setPitch, getTimeLength, getTimePlayed;
public import gargula.resource.rendertexture :
    unload, size, RenderTextureNode;
public import gargula.resource.shader :
    unload, ShaderNode, getLocation, getLocationAttrib,
    setValue;
public import gargula.resource.sound :
    unload, update, unload, play, stop, pause, resume,
    playMulti, stopMulti, isPlaying, setVolume, setPitch;
public import gargula.resource.texture :
    unload, update, getData, genMipmaps, setFilter,
    setWrap, draw, size;
public import gargula.resource.wave :
    unload, loadSound;

/// Toggle playing audio objects, works for Sound, Music and AudioStream
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
