module gargula.chipmunk.shape;

import betterclist;
import chipmunk;

import gargula.chipmunk.body;
import gargula.chipmunk.space;
import gargula.log;
import gargula.node;

enum bodyStackSize = 4;
struct Shape
{
    @disable this();

    static List!(cpShape*, bodyStackSize) shapeStack;
    static cpShape* currentShape()
    {
        return shapeStack.empty ? null : shapeStack[$-1];
    }
}

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
        Shape.shapeStack.push(shape);
    }

    void lateInitialize()
    {
        Shape.shapeStack.pop();
    }

    ~this()
    {
        if (shape)
        {
            auto space = cpShapeGetSpace(shape);
            if (space)
            {
                cpSpaceRemoveShape(space, shape);
            }
            cpShapeFree(shape);
        }
    }
}

struct CircleShape
{
    mixin ShapeTemplate!"cpCircleShapeNew(body_, radius, offset)";

    cpFloat radius = 1;
    cpVect offset = cpvzero;
}

struct SegmentShape
{
    mixin ShapeTemplate!"cpSegmentShapeNew(body_, a, b, radius)";

    cpVect a = cpv(0, 0);
    cpVect b = cpv(1, 0);
    cpFloat radius = 1;
}

struct PolygonShape
{
    mixin ShapeTemplate!"cpPolyShapeNew(body_, cast(int) verts.length, verts.ptr, transform, radius)";

    int numVerts;
    cpVect[] verts;
    cpTransform transform = { 1, 0, 0, 1, 0, 0 };
    cpFloat radius;
}

struct BoxShape
{
    mixin ShapeTemplate!"cpBoxShapeNew(body_, width, height, radius)";

    cpFloat width = 1;
    cpFloat height = 1;
    cpFloat radius = 1;
}
