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

    void unload(ref Sound tex)
    {
        UnloadSound(tex);
        tex = Sound.init;
    }

    alias SoundResource = Flyweight!(
        Sound,
        load,
        unload,
        files,
        FlyweightOptions.gshared
    );
}

