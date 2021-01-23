module gargula.resource.wave;

import flyweightbyid;

import gargula.wrapper.raylib;

template WaveResource(string[] _files)
{
    immutable static string[] files = _files;

    Wave load(uint id)
    in { assert(id < files.length); }
    do
    {
        return LoadWave(cast(const char*) files[id]);
    }

    alias WaveResource = Flyweight!(
        Wave,
        load,
        unload!Wave,
        files,
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
Sound loadSound(T : Wave)(T wave)
{
    return LoadSoundFromWave(wave);
}
