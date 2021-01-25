module gargula.resource.audiostream;

import gargula.wrapper.raylib;

/// Update audio stream buffers with data
void update(T : AudioStream)(ref T stream, const void* data, int samplesCount)
{
    UpdateAudioStream(stream, data, samplesCount);
}

/// Close audio stream and free memory
void close(T : AudioStream)(ref T stream)
{
    CloseAudioStream(stream);
}

/// Check if any audio stream buffers requires refill
void isProcessed(T : AudioStream)(ref T stream)
{
    IsAudioStreamProcessed(stream);
}

/// Play audio stream
void play(T : AudioStream)(ref T stream)
{
    PlayAudioStream(stream);
}

/// Pause audio stream
void pause(T : AudioStream)(ref T stream)
{
    PauseAudioStream(stream);
}

/// Resume audio stream
void resume(T : AudioStream)(ref T stream)
{
    ResumeAudioStream(stream);
}

/// Check if audio stream is playing
void isPlaying(T : AudioStream)(ref T stream)
{
    IsAudioStreamPlaying(stream);
}

/// Stop audio stream
void stop(T : AudioStream)(ref T stream)
{
    StopAudioStream(stream);
}

/// Set volume for audio stream (1.0 is max level)
void setVolume(T : AudioStream)(ref T stream, float volume)
{
    SetAudioStreamVolume(stream, volume);
}

/// Set pitch for audio stream (1.0 is base level)
void setPitch(T : AudioStream)(ref T stream, float pitch)
{
    SetAudioStreamPitch(stream, pitch);
}
