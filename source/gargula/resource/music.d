module gargula.resource.music;

import flyweightbyid;

import gargula.wrapper.raylib;

template MusicResource(string[] _files)
{
    immutable static string[] files = _files;

    Music load(uint id)
    in { assert(id < files.length); }
    do
    {
        return LoadMusicStream(cast(const char*) files[id]);
    }

    alias MusicResource = Flyweight!(
        Music,
        load,
        unload!Music,
        files,
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
void play(T : Music)(T music)
{
    PlayMusicStream(music);
}

/// Updates buffers for music streaming
void update(T : Music)(T music)
{
    UpdateMusicStream(music);
}

/// Stop music playing
void stop(T : Music)(T music)
{
    StopMusicStream(music);
}

/// Pause music playing
void pause(T : Music)(T music)
{
    PauseMusicStream(music);
}

/// Resume playing paused music
void resume(T : Music)(T music)
{
    ResumeMusicStream(music);
}

/// Check if music is playing
bool isPlaying(T : Music)(T music)
{
    return IsMusicPlaying(music);
}

/// Set volume for music (1.0 is max level)
void setVolume(T : Music)(T music, float volume)
{
    SetMusicStreamVolume(music, volume);
}

/// Set pitch for a music (1.0 is base level)
void setPitch(T : Music)(T music, float pitch)
{
    SetMusicStreamPitch(music, pitch);
}

/// Get music time length (in seconds)
float getTimeLength(T : Music)(T music)
{
    return GetMusicTimeLength(music);
}

/// Get current music time played (in seconds)
float getTimePlayed(T : Music)(T music)
{
    return GetMusicTimePlayed(music);
}
