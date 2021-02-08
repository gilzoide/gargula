module gargula.chipmunk.space;

import betterclist;
import chipmunk;

import gargula.node;
import gargula.wrapper.raylib;

enum spaceStackSize = 4;

struct Space
{
    mixin Node;

    cpSpace* space;
    alias space this;

    static List!(cpSpace*, spaceStackSize) spaceStack;
    static cpSpace* currentSpace()
    {
        return spaceStack.empty ? null : spaceStack[$-1];
    }

    void initialize()
    {
        space = cpSpaceNew();
        spaceStack.push(space);
    }

    void lateInitialize()
    {
        spaceStack.pop();
    }

    debug void draw()
    {
        import gargula.chipmunk.debugdraw : debugDrawOptions;
        cpSpaceDebugDraw(space, &debugDrawOptions);
    }

    void update()
    {
        cpSpaceStep(space, 1.0 / 60);
    }

    ~this()
    {
        if (space)
        {
            cpSpaceFree(space);
        }
    }
}
