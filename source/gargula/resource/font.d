module gargula.resource.font;

import std.string : toStringz;

import flyweightbyid;

import gargula.wrapper.raylib;

template FontResource(string[] _files)
{
    immutable static string[] files = _files;
    enum filenames = _files;

    Font load(uint id)
    in { assert(id < files.length); }
    do
    {
        return LoadFont(cast(const char*) files[id]);
    }

    alias Flyweight = .Flyweight!(
        Font,
        load,
        unload!Font,
        filenames,
        FlyweightOptions.gshared
    );
}

/// Unload Font from GPU memory (VRAM)
void unload(T : Font)(ref T font)
{
    UnloadFont(font);
    font = T.init;
}

/// Draw text using font and additional parameters
void drawText(T : Font)(T font, string text, Vector2 position, float fontSize, float spacing, Color tint)
{
    DrawTextEx(font, text.toStringz, position, fontSize, spacing, tint);
}
/// Draw text using font inside rectangle limits
void drawText(T : Font)(T font, string text, Rectangle rec, float fontSize, float spacing, bool wordWrap, Color tint)
{
    DrawTextRec(font, text.toStringz, rec, fontSize, spacing, wordWrap, tint);
}
/// Draw text using font inside rectangle limits with support for text selection
void drawText(T : Font)(T font, string text, Rectangle rec, float fontSize, float spacing, bool wordWrap, Color tint, int selectStart, int selectLength, Color selectTint, Color selectBackTint)
{
    DrawTextRecEx(font, text.toStringz, rec, fontSize, spacing, wordWrap, tint, selectStart, selectLength, selectTint, selectBackTint);
}
/// Draw one character (codepoint)
void drawText(T : Font)(T font, int codepoint, Vector2 position, float fontSize, Color tint)
{
    DrawTextCodepoint(font, codepoint, position, fontSize, tint);
}

/// Measure string size for Font
Vector2 measureText(T : Font)(T font, string text, float fontSize, float spacing)
{
    return MeasureTextEx(font, text.toStringz, fontSize, spacing);
}

/// Get index position for a unicode character on font
int getGlyphIndex(T : Font)(T font, int codepoint)
{
    return GetGlyphIndex(font, codepoint);
}
