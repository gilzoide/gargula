module gargula.builtin.clearbackground;

import gargula.node;
import gargula.wrapper.raylib;

struct ClearBackgroundNode
{
    mixin Node;

    Color color = RAYWHITE;

    void draw()
    {
        ClearBackground(color);
    }
}
