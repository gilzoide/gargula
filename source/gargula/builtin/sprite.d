module gargula.builtin.sprite;

import gargula.node;
import gargula.wrapper.raylib;

struct SpriteTemplate(TextureType)
{
    mixin Node;

    TextureType texture;
    Vector2 position = 0;
    Color tintColor = WHITE;

    void draw()
    {
        DrawTextureV(texture, position, tintColor);
    }
}

alias Sprite = SpriteTemplate!Texture;
