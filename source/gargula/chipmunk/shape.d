module gargula.chipmunk.shape;

import betterclist;
import chipmunk;

import gargula.chipmunk.body;
import gargula.chipmunk.space;
import gargula.log;
import gargula.node;

private mixin template ShapeTemplate(string newCall)
{
    mixin Node;

    cpShape* shape;
    alias shape this;

    void initialize()
    {
        auto space = Space.currentSpace();
        assert(space, "Trying to create a Shape without a Space");
        auto body_ = Body.currentBody();
        if (!body_)
        {
            body_ = cpSpaceGetStaticBody(space);
        }
        assert(body_, "Trying to create a Shape without a Body!!!");
        mixin("shape = " ~ newCall ~ ";");
        cpSpaceAddShape(space, shape);
    }

    //~this()
    //{
        //if (shape)
        //{
            //auto space = cpShapeGetSpace(shape);
            //if (space)
            //{
                //cpSpaceRemoveShape(space, shape);
            //}
            //cpShapeFree(shape);
        //}
    //}
}

struct CircleShape
{
    cpFloat radius = 1;
    cpVect offset = cpvzero;

    mixin ShapeTemplate!"cpCircleShapeNew(body_, radius, offset)";
}

struct SegmentShape
{
    cpVect a = cpv(0, 0);
    cpVect b = cpv(1, 0);
    cpFloat radius = 1;

    mixin ShapeTemplate!"cpSegmentShapeNew(body_, a, b, radius)";
}

struct PolygonShape
{
    int numVerts;
    cpVect[] verts;
    cpTransform transform = { 1, 0, 0, 1, 0, 0 };
    cpFloat radius;

    mixin ShapeTemplate!"cpPolyShapeNew(body_, cast(int) verts.length, verts.ptr, transform, radius)";
}

struct BoxShape
{
    cpFloat width = 1;
    cpFloat height = 1;
    cpFloat radius = 1;

    mixin ShapeTemplate!"cpBoxShapeNew(body_, width, height, radius)";
}
