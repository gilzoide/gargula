module gargula.resource.font;

import flyweightbyid;

import gargula.wrapper.raylib;

template FontResource(string[] _files)
{
    immutable static string[] files = _files;

    Font load(uint id)
    in { assert(id < files.length); }
    do
    {
        return LoadFont(cast(const char*) files[id]);
    }

    void unload(ref Font tex)
    {
        UnloadFont(tex);
        tex = Font.init;
    }

    alias FontResource = Flyweight!(
        Font,
        load,
        unload,
        files,
        FlyweightOptions.gshared
    );
}

