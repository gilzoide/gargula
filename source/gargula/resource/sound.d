module gargula.resource.sound;

import flyweightbyid;

import gargula.wrapper.raylib;

template SoundResource(string[] _files)
{
    static immutable string[] files = _files;
    enum filenames = _files;

    Sound load(uint id)
    in { assert(id < files.length); }
    do
    {
        return LoadSound(cast(const char*) files[id]);
    }

    alias Flyweight = .Flyweight!(
        Sound,
        load,
        unload!Sound,
        filenames,
        FlyweightOptions.gshared
    );
}

/// Update sound buffer with new data
void update(T : Sound)(ref T sound, void[] data)
{
    UpdateSound(sound, data.ptr, data.length);
}

/// Unload sound
void unload(T : Sound)(ref T sound)
{
    UnloadSound(sound);
    sound = T.init;
}

/// Play a sound
void play(T : Sound)(ref T sound)
{
    PlaySound(sound);
}

/// Stop playing a sound
void stop(T : Sound)(ref T sound)
{
    StopSound(sound);
}

/// Pause a sound
void pause(T : Sound)(ref T sound)
{
    PauseSound(sound);
}

/// Resume a paused sound
void resume(T : Sound)(ref T sound)
{
    ResumeSound(sound);
}

/// Play a sound (using multichannel buffer pool)
void playMulti(T : Sound)(ref T sound)
{
    PlaySoundMulti(sound);
}

/// Stop any sound playing (using multichannel buffer pool)
void stopMulti(T : Sound)(ref T sound)
{
    StopSoundMulti(sound);
}

/// Check if a sound is currently playing
bool isPlaying(T : Sound)(ref T sound)
{
    return IsSoundPlaying(sound);
}

/// Set volume for a sound (1.0 is max level)
void setVolume(T : Sound)(ref T sound, float volume)
{
    SetSoundVolume(sound, volume);
}

/// Set pitch for a sound (1.0 is base level)
void setPitch(T : Sound)(ref T sound, float pitch)
{
    SetSoundPitch(sound, pitch);
}
