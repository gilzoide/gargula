module gargula.resource.sound;

import flyweightbyid;

import gargula.wrapper.raylib;

template SoundResource(string[] _files)
{
    immutable static string[] files = _files;

    Sound load(uint id)
    in { assert(id < files.length); }
    do
    {
        return LoadSound(cast(const char*) files[id]);
    }

    alias SoundResource = Flyweight!(
        Sound,
        load,
        unload!Sound,
        files,
        FlyweightOptions.gshared
    );
}

/// Update sound buffer with new data
void update(T : Sound)(T sound, void[] data)
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
void play(T : Sound)(T sound)
{
    PlaySound(sound);
}

/// Stop playing a sound
void stop(T : Sound)(T sound)
{
    StopSound(sound);
}

/// Pause a sound
void pause(T : Sound)(T sound)
{
    PauseSound(sound);
}

/// Resume a paused sound
void resume(T : Sound)(T sound)
{
    ResumeSound(sound);
}

/// Play a sound (using multichannel buffer pool)
void playMulti(T : Sound)(T sound)
{
    PlaySoundMulti(sound);
}

/// Stop any sound playing (using multichannel buffer pool)
void stopMulti(T : Sound)(T sound)
{
    StopSoundMulti(sound);
}

/// Check if a sound is currently playing
bool isPlaying(T : Sound)(T sound)
{
    return IsSoundPlaying(sound);
}

/// Set volume for a sound (1.0 is max level)
void setVolume(T : Sound)(T sound, float volume)
{
    SetSoundVolume(sound, volume);
}

/// Set pitch for a sound (1.0 is base level)
void setPitch(T : Sound)(T sound, float pitch)
{
    SetSoundPitch(sound, pitch);
}
