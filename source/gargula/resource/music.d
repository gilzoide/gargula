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

    void unload(ref Music tex)
    {
        UnloadMusicStream(tex);
        tex = Music.init;
    }

    alias MusicResource = Flyweight!(
        Music,
        load,
        unload,
        files,
        FlyweightOptions.gshared
    );
}

