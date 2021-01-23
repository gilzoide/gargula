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

    void unload(ref Wave tex)
    {
        UnloadWave(tex);
        tex = Wave.init;
    }

    alias WaveResource = Flyweight!(
        Wave,
        load,
        unload,
        files,
        FlyweightOptions.gshared
    );
}

