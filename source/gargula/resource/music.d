module gargula.resource.music;

import flyweightbyid;

import gargula.wrapper.raylib;

template MusicResource(string[] _files)
{
    static immutable string[] files = _files;
    enum filenames = _files;

    Music load(uint id)
    in { assert(id < files.length); }
    do
    {
        return LoadMusicStream(cast(const char*) files[id]);
    }

    alias Flyweight = .Flyweight!(
        Music,
        load,
        unload!Music,
        filenames,
        FlyweightOptions.gshared
    );
}

/// Unload music stream
void unload(T : Music)(ref T music)
{
    UnloadMusicStream(music);
    music = T.init;
}

/// Start music playing
void play(T : Music)(ref T music)
{
    PlayMusicStream(music);
}

/// Updates buffers for music streaming
void update(T : Music)(ref T music)
{
    UpdateMusicStream(music);
}

/// Stop music playing
void stop(T : Music)(ref T music)
{
    StopMusicStream(music);
}

/// Pause music playing
void pause(T : Music)(ref T music)
{
    PauseMusicStream(music);
}

/// Resume playing paused music
void resume(T : Music)(ref T music)
{
    ResumeMusicStream(music);
}

/// Check if music is playing
bool isPlaying(T : Music)(ref T music)
{
    return IsMusicPlaying(music);
}

/// Set volume for music (1.0 is max level)
void setVolume(T : Music)(ref T music, float volume)
{
    SetMusicStreamVolume(music, volume);
}

/// Set pitch for a music (1.0 is base level)
void setPitch(T : Music)(ref T music, float pitch)
{
    SetMusicStreamPitch(music, pitch);
}

/// Get music time length (in seconds)
float getTimeLength(T : Music)(ref T music)
{
    return GetMusicTimeLength(music);
}

/// Get current music time played (in seconds)
float getTimePlayed(T : Music)(ref T music)
{
    return GetMusicTimePlayed(music);
}
