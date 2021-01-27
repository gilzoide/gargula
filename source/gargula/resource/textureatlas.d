module gargula.resource.textureatlas;

import betterclist;
import flyweightbyid;

import gargula.resource.texture;
import gargula.wrapper.raylib;

/// Options for imported Textures.
struct TextureAtlasOptions
{
    /// File name.
    string filename;
    /// Texture frame coordinates
    Rectangle[] frames;
    /// Whether mipmaps should be created on load.
    bool mipmaps = false;
    /// Filter mode.
    int filter = -1;
    /// Wrap mode.
    int wrap = -1;
}

/// Wrapper around Texture with subregion information.
struct TextureAtlas
{
    /// Texture data.
    Texture texture;
    alias texture this;
    /// Coordinates for each frame
    const(Rectangle)[] frames;
}

template TextureAtlasResource(TextureAtlasOptions[] _options)
{
    import std.algorithm : map;
    static immutable options = list!(_options);
    enum filenames = list!(_options[].map!"a.filename");

    TextureAtlas load(uint id)
    in { assert(id < _options.length); }
    do
    {
        const auto option = options[id];
        Texture tex = LoadTexture(cast(const char*) option.filename);
        if (option.mipmaps)
        {
            tex.genMipmaps();
        }
        if (option.filter != TextureOptions.init.filter)
        {
            tex.setFilter(option.filter);
        }
        if (option.wrap != TextureOptions.init.wrap)
        {
            tex.setWrap(option.wrap);
        }
        TextureAtlas atlas = {
            texture: tex,
            frames: option.frames,
        };
        return atlas;
    }

    alias Flyweight = .Flyweight!(
        TextureAtlas,
        load,
        unload!TextureAtlas,
        filenames,
        FlyweightOptions.gshared
    );
}

/// Unload atlas' texture from GPU memory (VRAM)
void unload(T : TextureAtlas)(ref T atlas)
{
    UnloadTexture(atlas.texture);
    atlas = T.init;
}

