module gargula.resource.font;

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
void drawText(T : Font)(ref T font, const char* text, Vector2 position, float fontSize, float spacing, Color tint)
{
    DrawTextEx(font, text, position, fontSize, spacing, tint);
}
/// Draw text using font inside rectangle limits
void drawText(T : Font)(ref T font, const char* text, Rectangle rec, float fontSize, float spacing, bool wordWrap, Color tint)
{
    DrawTextRec(font, text, rec, fontSize, spacing, wordWrap, tint);
}
/// Draw text using font inside rectangle limits with support for text selection
void drawText(T : Font)(ref T font, const char* text, Rectangle rec, float fontSize, float spacing, bool wordWrap, Color tint, int selectStart, int selectLength, Color selectTint, Color selectBackTint)
{
    DrawTextRecEx(font, text, rec, fontSize, spacing, wordWrap, tint, selectStart, selectLength, selectTint, selectBackTint);
}
/// Draw one character (codepoint)
void drawText(T : Font)(ref T font, int codepoint, Vector2 position, float fontSize, Color tint)
{
    DrawTextCodepoint(font, codepoint, position, fontSize, tint);
}

/// Draw text with `string` parameter instead of `const char*`
void drawText(T : Font, Args...)(ref T font, string text, auto ref Args args)
{
    import std.string : toStringz;
    font.drawText(text.toStringz, args);
}

/// Measure string size for Font
Vector2 measureText(T : Font)(ref T font, const char* text, float fontSize, float spacing)
{
    return MeasureTextEx(font, text, fontSize, spacing);
}
/// Measure string size for Font, `string` version
auto measureText(T : Font, Args...)(ref T font, string text, auto ref Args args)
{
    import std.string : toStringz;
    return font.measureText(text.toStringz, args);
}

/// Get index position for a unicode character on font
int getGlyphIndex(T : Font)(ref T font, int codepoint)
{
    return GetGlyphIndex(font, codepoint);
}
