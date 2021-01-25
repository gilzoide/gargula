module gargula.resource.texture;

import betterclist;
import flyweightbyid;

import gargula.wrapper.raylib;

/// Options for imported Textures.
struct TextureOptions
{
    /// File name.
    string filename;
    /// Whether mipmaps should be created on load.
    bool mipmaps = false;
    /// Filter mode.
    int filterMode = -1;
    /// Wrap mode.
    int wrapMode = -1;
}

template TextureResource(TextureOptions[] _options)
{
    import std.algorithm : map;
    static immutable TextureOptions[] options = _options;
    enum filenames = list!(_options[].map!"a.filename");

    Texture load(uint id)
    in { assert(id < _options.length); }
    do
    {
        const auto option = options[id];
        Texture tex = LoadTexture(cast(const char*) option.filename);
        if (option.mipmaps)
        {
            tex.genMipmaps();
        }
        if (option.filterMode != TextureOptions.init.filterMode)
        {
            tex.setFilter(option.filterMode);
        }
        if (option.wrapMode != TextureOptions.init.wrapMode)
        {
            tex.setWrap(option.wrapMode);
        }
        return tex;
    }

    alias Flyweight = .Flyweight!(
        Texture,
        load,
        unload!Texture,
        filenames,
        FlyweightOptions.gshared
    );
}

/// Unload texture from GPU memory (VRAM)
void unload(T : Texture)(ref T texture)
{
    UnloadTexture(texture);
    texture = T.init;
}

/// Update GPU texture with new data
void update(T : Texture)(ref T texture, const void* pixels)
{
    UpdateTexture(texture, pixels);
}
/// Update GPU texture rectangle with new data
void update(T : Texture)(ref T texture, Rectangle rec, const void* pixels)
{
    UpdateTextureRec(texture, rec, pixels);
}

/// Get pixel data from GPU texture and return an Image
Image getData(T : Texture)(ref T texture)
{
    return GetTextureData(texture);
}

/// Generate GPU mipmaps for a texture
void genMipmaps(T : Texture)(ref T texture)
{
    GenTextureMipmaps(&texture);
}

/// Set texture scaling filter mode
void setFilter(T : Texture)(ref T texture, int filterMode)
{
    SetTextureFilter(texture, filterMode);
}

/// Set texture wrapping mode
void setWrap(T : Texture)(ref T texture, int wrapMode)
{
    SetTextureWrap(texture, wrapMode);
}

/// Draw a Texture2D
void draw(T : Texture)(ref T texture, int posX, int posY, Color tint)
{
    DrawTexture(texture, posX, posY, tint);
}
/// Draw a Texture2D with position defined as Vector2
void draw(T : Texture)(ref T texture, Vector2 position, Color tint)
{
    DrawTextureV(texture, position, tint);
}
/// Draw a Texture2D with extended parameters
void draw(T : Texture)(ref T texture, Vector2 position, float rotation, float scale, Color tint)
{
    DrawTextureEx(texture, position, rotation, scale, tint);
}
/// Draw a part of a texture defined by a rectangle
void draw(T : Texture)(ref T texture, Rectangle source, Vector2 position, Color tint)
{
    DrawTextureRec(texture, source, position, tint);
}
/// Draw texture quad with tiling and offset parameters
void draw(T : Texture)(ref T texture, Vector2 tiling, Vector2 offset, Rectangle quad, Color tint)
{
    DrawTextureQuad(texture, tiling, offset, quad, tint);
}
/// Draw part of a texture (defined by a rectangle) with rotation and scale tiled into dest.
void draw(T : Texture)(ref T texture, Rectangle source, Rectangle dest, Vector2 origin, float rotation, float scale, Color tint)
{
    DrawTextureTiled(texture, source, dest, origin, rotation, scale, tint);
}
/// Draw a part of a texture defined by a rectangle with 'pro' parameters
void draw(T : Texture)(ref T texture, Rectangle source, Rectangle dest, Vector2 origin, float rotation, Color tint)
{
    DrawTexturePro(texture, source, dest, origin, rotation, tint);
}
/// Draws a texture (or part of it) that stretches or shrinks nicely
void draw(T : Texture)(ref T texture, NPatchInfo nPatchInfo, Rectangle dest, Vector2 origin, float rotation, Color tint)
{
    DrawTextureNPatch(texture, nPatchInfo, dest, origin, rotation, tint);
}

/// Get texture size
Vector2 size(T : Texture)(const ref T texture)
{
    return Vector2(texture.width, texture.height);
}
