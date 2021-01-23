module gargula.resource.texture;

import flyweightbyid;

import gargula.wrapper.raylib;

template TextureResource(string[] _files)
{
    static immutable string[] files = _files;

    Texture load(uint id)
    in { assert(id < files.length); }
    do
    {
        return LoadTexture(cast(const char*) files[id]);
    }

    alias TextureResource = Flyweight!(
        Texture,
        load,
        unload!Texture,
        files,
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
void update(T : Texture)(T texture, const void* pixels)
{
    UpdateTexture(texture, pixels);
}
/// Update GPU texture rectangle with new data
void update(T : Texture)(T texture, Rectangle rec, const void* pixels)
{
    UpdateTextureRec(texture, rec, pixels);
}

/// Get pixel data from GPU texture and return an Image
Image getData(T : Texture)(T texture)
{
    return GetTextureData(texture);
}

/// Generate GPU mipmaps for a texture
void genMipmaps(T : Texture)(T texture)
{
    GenTextureMipmaps(texture);
}

/// Set texture scaling filter mode
void setFilter(T : Texture)(T texture, int filterMode)
{
    SetTextureFilter(texture, filterMode);
}

/// Set texture wrapping mode
void setWrap(T : Texture)(T texture, int wrapMode)
{
    SetTextureWrap(texture, wrapMode);
}

/// Draw a Texture2D
void draw(T : Texture)(T texture, int posX, int posY, Color tint)
{
    DrawTexture(texture, posX, posY, tint);
}
/// Draw a Texture2D with position defined as Vector2
void draw(T : Texture)(T texture, Vector2 position, Color tint)
{
    DrawTextureV(texture, position, tint);
}
/// Draw a Texture2D with extended parameters
void draw(T : Texture)(T texture, Vector2 position, float rotation, float scale, Color tint)
{
    DrawTextureEx(texture, position, rotation, scale, tint);
}
/// Draw a part of a texture defined by a rectangle
void draw(T : Texture)(T texture, Rectangle source, Vector2 position, Color tint)
{
    DrawTextureRec(texture, source, position, tint);
}
/// Draw texture quad with tiling and offset parameters
void draw(T : Texture)(T texture, Vector2 tiling, Vector2 offset, Rectangle quad, Color tint)
{
    DrawTextureQuad(texture, tiling, offset, quad, tint);
}
/// Draw part of a texture (defined by a rectangle) with rotation and scale tiled into dest.
void draw(T : Texture)(T texture, Rectangle source, Rectangle dest, Vector2 origin, float rotation, float scale, Color tint)
{
    DrawTextureTiled(texture, source, dest, origin, rotation, scale, tint);
}
/// Draw a part of a texture defined by a rectangle with 'pro' parameters
void draw(T : Texture)(T texture, Rectangle source, Rectangle dest, Vector2 origin, float rotation, Color tint)
{
    DrawTexturePro(texture, source, dest, origin, rotation, tint);
}
/// Draws a texture (or part of it) that stretches or shrinks nicely
void draw(T : Texture)(T texture, NPatchInfo nPatchInfo, Rectangle dest, Vector2 origin, float rotation, Color tint)
{
    DrawTextureNPatch(texture, nPatchInfo, dest, origin, rotation, tint);
}

/// Get texture size
Vector2 size(T : Texture)(const T texture)
{
    return Vector2(texture.width, texture.height);
}
