module gargula.chipmunk.space;

import chipmunk;

import gargula.node;

struct Space
{
    mixin Node;

    cpSpace* space;
    alias space this;

    void initialize()
    {
        space = cpSpaceNew();
    }

    ~this()
    {
        if (space)
        {
            cpSpaceDestroy(space);
        }
    }
}
