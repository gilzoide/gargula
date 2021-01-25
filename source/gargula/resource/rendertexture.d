module gargula.resource.rendertexture;

import betterclist;
import bettercmath : Vector;
import flyweightbyid;

import gargula.wrapper.raylib;

private alias Vector2i = Vector!(int, 2);

/// Options for created RenderTextures.
struct RenderTextureOptions
{
    /// Name used by Flyweight.
    string name;
    /// RenderTexture size.
    Vector2i size;
}

template RenderTextureResource(RenderTextureOptions[] _options)
{
    import std.algorithm : map;
    static immutable auto sizes = list!(_options[].map!"a.size");

    RenderTexture load(uint id)
    in { assert(id < _options.length); }
    do
    {
        auto size = sizes[id];
        return LoadRenderTexture(size.width, size.height);
    }

    alias RenderTextureResource = Flyweight!(
        RenderTexture,
        load,
        unload!RenderTexture,
        list!(_options[].map!"a.name"),
        FlyweightOptions.gshared
    );
}

/// Unload render texture from GPU memory (VRAM)
void unload(T : RenderTexture)(ref T renderTexture)
{
    UnloadRenderTexture(renderTexture);
    renderTexture = T.init;
}

/// Get texture size
Vector2 size(T : RenderTexture)(const ref T renderTexture)
{
    return Vector2(renderTexture.texture.width, renderTexture.texture.height);
}
