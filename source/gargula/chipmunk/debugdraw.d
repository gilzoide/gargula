module gargula.chipmunk.debugdraw;

import bettercmath;
import chipmunk;

import gargula.wrapper.raylib;

alias Vector4 = Vector!(float, 4);

debug extern(C) nothrow @nogc:
void drawCircle(cpVect pos, cpFloat angle, cpFloat radius, Vector4 outlineColor, Vector4 fillColor, cpDataPointer data)
{
    DrawCircleV(cast(Vector2) pos, radius, cast(Color) (fillColor * 255));
}

void drawSegment(cpVect a, cpVect b, Vector4 color, cpDataPointer data)
{
    immutable c = cast(Color) (color * 255);
    DrawLineV(cast(Vector2) a, cast(Vector2) b, c);
}

void drawFatSegment(cpVect a, cpVect b, cpFloat radius, Vector4 outlineColor, Vector4 fillColor, cpDataPointer data)
{
    immutable c = cast(Color) (fillColor * 255);
    DrawLineEx(cast(Vector2) a, cast(Vector2) b, radius, c);
}

void drawPolygon(int count, const cpVect *verts, cpFloat radius, Vector4 outlineColor, Vector4 fillColor, cpDataPointer data)
{
    static Vector2[128] points;
    immutable c = cast(Color) (fillColor * 255);
    foreach (i; 0 .. count)
    {
        points[i] = cast(Vector2) verts[i];
    }
    points[count] = cast(Vector2) verts[0]; // loop
    DrawLineStrip(points.ptr, count + 1, c);
}

void drawDot(cpFloat size, cpVect pos, Vector4 color, cpDataPointer data)
{
    import gargula.log;
    Color c = cast(Color) (color * 255);
    Log.Info!"COR [%d %d %d %d]"(c[0], c[1], c[2], c[3]);
    DrawCircleV(cast(Vector2) pos, size * 0.5, c);
}

cpSpaceDebugColor colorForShape(cpShape *shape, cpDataPointer data)
{
    return cpSpaceDebugColor(0, 1, 1, 1);
}

static cpSpaceDebugDrawOptions debugDrawOptions = {
    drawCircle: cast(cpSpaceDebugDrawCircleImpl) &drawCircle,
    drawSegment: cast(cpSpaceDebugDrawSegmentImpl) &drawSegment,
    drawFatSegment: cast(cpSpaceDebugDrawFatSegmentImpl) &drawFatSegment,
    drawPolygon: cast(cpSpaceDebugDrawPolygonImpl) &drawPolygon,
    drawDot: cast(cpSpaceDebugDrawDotImpl) &drawDot,
    flags: cast(cpSpaceDebugDrawFlags) 0x111,
    shapeOutlineColor: cpSpaceDebugColor(0, 1, 0, 1),
    colorForShape: cast(cpSpaceDebugDrawColorForShapeImpl) &colorForShape,
    constraintColor: cpSpaceDebugColor(0, 0, 1, 1),
    collisionPointColor: cpSpaceDebugColor(1, 0, 0, 1),
    data: null,
};
