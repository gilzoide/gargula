module gargula.resource.texture;

import flyweightbyid;

import gargula.wrapper.raylib;

template TextureResource(string[] files)
{
    Texture load(uint id)
    in { assert(id < files.length); }
    do
    {
        return LoadTexture(cast(const char*) files[id]);
    }

    void unload(ref Texture tex)
    {
        UnloadTexture(tex);
        tex = Texture.init;
    }

    alias TextureResource = Flyweight!(
        Texture,
        load,
        unload,
        files,
        FlyweightOptions.gshared
    );
}
