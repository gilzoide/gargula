module gargula.builtin.sprite;

import gargula.node;
import gargula.wrapper.raylib;

enum SpriteOptions
{
    none,
    axisAligned,
    fixedAnchor,
}

struct SpriteTemplate(TextureType, SpriteOptions options = SpriteOptions.none)
{
    mixin Node;

    // Workaround for error `struct SpriteTemplate has constructors, cannot use { initializers }, use SpriteTemplate( initializers ) instead` in LDC
    // Who knows why =S
    version (LDC) @disable this();

    TextureType texture;
    Vector2 position = 0;
    Color tintColor = WHITE;

    static if (options & SpriteOptions.axisAligned)
    {
        enum float rotation = 0;
        enum float scale = 1;
    }
    else
    {
        float rotation = 0;
        float scale = 1;
    }

    static if (options & SpriteOptions.fixedAnchor)
    {
        enum Vector2 anchor = 0.5;
    }
    else
    {
        Vector2 anchor = 0.5;
    }

    Vector2 size() const pure
    {
        return Vector2(texture.width, texture.height);
    }

    void draw()
    {
        auto sourceRect = Rectangle(Vector2(0), size);
        auto destRect = Rectangle(position, scale * size);
        auto origin = anchor * size * scale;
        DrawTexturePro(texture, sourceRect, destRect, origin, rotation, tintColor);
    }
}

alias Sprite = SpriteTemplate!(Texture);
alias CenteredSprite = SpriteTemplate!(Texture, SpriteOptions.fixedAnchor);
alias AASprite = SpriteTemplate!(Texture, SpriteOptions.axisAligned);
alias AACenteredSprite = SpriteTemplate!(Texture, SpriteOptions.axisAligned | SpriteOptions.fixedAnchor);
