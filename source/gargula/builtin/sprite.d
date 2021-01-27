module gargula.builtin.sprite;

import gargula.node;
import gargula.resource.texture;
import gargula.wrapper.raylib;

enum SpriteOptions
{
    /// Default options: dynamic rotation and pivot
    none = 0,
    /// Axis Aligned Sprites may not rotate
    axisAligned = 1 << 0,
    /// Pivot is fixed to Sprite's center
    fixedPivot = 1 << 1,
    /// Use rect.size as size directly instead of scale factor
    rectSize = 1 << 2,
}

struct SpriteTemplate(TextureType, SpriteOptions options = SpriteOptions.none)
{
    mixin Node;

    // Workaround for error `struct SpriteTemplate has constructors, cannot use { initializers }, use SpriteTemplate( initializers ) instead` in LDC
    // Who knows why =S
    version (LDC) @disable this();

    TextureType texture;
    Rectangle rect = { 0, 1 };
    alias rect this;
    Color tintColor = WHITE;

    @property Vector2 position() const
    {
        return rect.origin;
    }
    @property void position(const Vector2 value)
    {
        rect.origin = value;
    }
    static if (options & SpriteOptions.rectSize)
    {
        enum Vector2 scale = 1;
        @property Vector2 size() const
        {
            return rect.size;
        }
    }
    else
    {
        @property Vector2 scale() const
        {
            return rect.size;
        }
        @property void scale(const Vector2 value)
        {
            rect.size = value;
        }

        @property Vector2 size() const
        {
            return scale * sourceRect.size;
        }
    }

    static if (options & SpriteOptions.fixedPivot)
    {
        enum Vector2 pivot = 0.5;
    }
    else
    {
        Vector2 pivot = 0.5;
    }


    static if (options & SpriteOptions.axisAligned)
    {
        enum float rotation = 0;
    }
    else
    {
        float rotation = 0;
    }

    Rectangle sourceRect = { 0, 0 };
    int region = 0;

    void lateInitialize()
    {
        sourceRect = texture.region(region);
    }

    void draw()
    {
        Vector2 destOrigin = pivot * this.size;
        Rectangle destRect = { position, this.size };
        texture.draw(sourceRect, destRect, destOrigin, rotation, tintColor);
    }
}

mixin template SpriteVariations(TextureType)
{
    import gargula.builtin.sprite : SpriteOptions, SpriteTemplate;
    alias Sprite = SpriteTemplate!(TextureType);
    alias SpriteRect = SpriteTemplate!(TextureType, SpriteOptions.rectSize);
    alias CenteredSprite = SpriteTemplate!(TextureType, SpriteOptions.fixedPivot);
    alias CenteredSpriteRect = SpriteTemplate!(TextureType, SpriteOptions.fixedPivot | SpriteOptions.rectSize);
    alias AASprite = SpriteTemplate!(TextureType, SpriteOptions.axisAligned);
    alias AASpriteRect = SpriteTemplate!(TextureType, SpriteOptions.axisAligned | SpriteOptions.rectSize);
    alias AACenteredSprite = SpriteTemplate!(TextureType, SpriteOptions.axisAligned | SpriteOptions.fixedPivot);
    alias AACenteredSpriteRect = SpriteTemplate!(TextureType, SpriteOptions.axisAligned | SpriteOptions.fixedPivot | SpriteOptions.rectSize);
}
mixin SpriteVariations!TextureAtlas;
