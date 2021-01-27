module gargula.resource.rendertexture;

import betterclist;
import bettercmath : Vector;
import flyweightbyid;

import gargula.node;
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

/// RenderTexture node with draw/lateDraw
struct RenderTextureNode
{
    mixin Node;

    /// RenderTexture data.
    RenderTexture texture;
    alias texture this;

    ///
    void draw()
    {
        BeginTextureMode(texture);
    }
    ///
    void lateDraw()
    {
        EndTextureMode();
    }
}

template RenderTextureResource(RenderTextureOptions[] _options)
{
    import std.algorithm : map;
    static immutable sizes = list!(_options[].map!"a.size");

    RenderTextureNode load(uint id)
    in { assert(id < _options.length); }
    do
    {
        immutable size = sizes[id];
        RenderTexture texture = LoadRenderTexture(size.width, size.height);
        RenderTextureNode node = { texture: texture };
        return node;
    }

    alias Flyweight = .Flyweight!(
        RenderTextureNode,
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
