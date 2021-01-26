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
    /// Add destRect instead of position+scale for coordinates
    rectCoordinates = 1 << 2,
}

struct SpriteTemplate(TextureType, SpriteOptions options = SpriteOptions.none)
{
    mixin Node;

    // Workaround for error `struct SpriteTemplate has constructors, cannot use { initializers }, use SpriteTemplate( initializers ) instead` in LDC
    // Who knows why =S
    version (LDC) @disable this();

    TextureType texture;
    static if (options & SpriteOptions.rectCoordinates)
    {
        Rectangle rect = { 0, 0 };
        alias rect this;
        alias destRect = rect;
        enum destOrigin = Vector2.zeros;
    }
    else
    {
        Vector2 position = 0;
        float scale = 1;

        Rectangle destRect() const
        {
            return Rectangle(position, scale * size);
        }

        Vector2 destOrigin() const
        {
            return pivot * scale * size;
        }

        static if (options & SpriteOptions.fixedPivot)
        {
            enum Vector2 pivot = 0.5;
        }
        else
        {
            Vector2 pivot = 0.5;
        }

    }
    Color tintColor = WHITE;

    static if (options & SpriteOptions.axisAligned)
    {
        enum float rotation = 0;
    }
    else
    {
        float rotation = 0;
    }

    Rectangle sourceRect = { 0, 0 };

    void lateInitialize()
    {
        if (sourceRect.empty)
        {
            sourceRect.size = texture.size;
        }
        static if (options & SpriteOptions.rectCoordinates)
        {
            if (destRect.empty)
            {
                destRect.size = texture.size;
            }
        }
    }

    Vector2 size() const
    {
        return texture.size;
    }

    void draw()
    {
        texture.draw(sourceRect, destRect, destOrigin, rotation, tintColor);
    }
}

mixin template SpriteVariations(TextureType)
{
    import gargula.builtin.sprite : SpriteOptions, SpriteTemplate;
    alias Sprite = SpriteTemplate!(TextureType);
    alias SpriteRect = SpriteTemplate!(TextureType, SpriteOptions.rectCoordinates);
    alias CenteredSprite = SpriteTemplate!(TextureType, SpriteOptions.fixedPivot);
    alias CenteredSpriteRect = SpriteTemplate!(TextureType, SpriteOptions.fixedPivot | SpriteOptions.rectCoordinates);
    alias AASprite = SpriteTemplate!(TextureType, SpriteOptions.axisAligned);
    alias AASpriteRect = SpriteTemplate!(TextureType, SpriteOptions.axisAligned | SpriteOptions.rectCoordinates);
    alias AACenteredSprite = SpriteTemplate!(TextureType, SpriteOptions.axisAligned | SpriteOptions.fixedPivot);
    alias AACenteredSpriteRect = SpriteTemplate!(TextureType, SpriteOptions.axisAligned | SpriteOptions.fixedPivot | SpriteOptions.rectCoordinates);
}
mixin SpriteVariations!Texture;
