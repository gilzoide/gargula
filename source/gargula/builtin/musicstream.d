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
}

alias MusicStream = MusicStreamTemplate!(Music);
