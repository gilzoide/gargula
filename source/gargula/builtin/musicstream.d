module gargula.builtin.musicstream;

import gargula.node;
import gargula.wrapper.raylib;

/// Template for MusicStream objects, use MusicStream and Game.MusicStream instantiations
struct MusicStreamTemplate(MusicType)
{
    mixin Node;

    /// Actual Music data
    MusicType music;
    alias music this;

    /// Assign Music data directly
    void opAssign(MusicType music)
    {
        this.music = music;
    }

    /// Updates buffers for music streaming
    void update()
    {
        UpdateMusicStream(music);
    }

    /// Start music playing (open stream)
    void play()
    {
        PlayMusicStream(music);
    }

    /// Stop music playing
    void stop()
    {
        StopMusicStream(music);
    }

    /// Pause music playing
    void pause()
    {
        PauseMusicStream(music);
    }

    /// Resume playing paused music
    void resume()
    {
        ResumeMusicStream(music);
    }

    /// Toggle playing music
    void toggle()
    {
        if (isPlaying)
        {
            pause();
        }
        else
        {
            resume();
        }
    }

    /// Check if music is playing
    @property bool isPlaying()
    {
        return IsMusicPlaying(music);
    }
    
    /// Set volume for music (1.0 is max level)
    void setVolume(float volume)
    {
        SetMusicVolume(music, volume);
    }

    /// Set pitch for a music (1.0 is base level)
    void setPitch(float pitch)
    {
        SetMusicPitch(music, pitch);
    }

    /// Get music time length (in seconds)
    @property float timeLength()
    {
        return GetMusicTimeLength(music);
    }

    /// Get current music time played (in seconds)
    @property float timePlayed()
    {
        return GetMusicTimePlayed(music);
    }
}

alias MusicStream = MusicStreamTemplate!(Music);
