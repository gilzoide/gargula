module gargula.resource.wave;

import flyweightbyid;

import gargula.wrapper.raylib;

template WaveResource(string[] _files)
{
    static immutable files = _files;
    enum filenames = _files;

    Wave load(uint id)
    in { assert(id < files.length); }
    do
    {
        return LoadWave(cast(const char*) files[id]);
    }

    alias Flyweight = .Flyweight!(
        Wave,
        load,
        unload!Wave,
        filenames,
        FlyweightOptions.gshared
    );
}

/// Unload wave data
void unload(T : Wave)(ref T wave)
{
    UnloadWave(wave);
    wave = T.init;
}

/// Load sound from wave data
Sound loadSound(T : Wave)(ref T wave)
{
    return LoadSoundFromWave(wave);
}
