module gargula.chipmunk.body;

import bettercmath;
import betterclist;
import chipmunk;

import gargula.chipmunk.space;
import gargula.log;
import gargula.node;
import gargula.wrapper.rlgl;

private alias Vector2 = Vector!(float, 2);
private alias Transform3D = Transform!(float, 3);

enum bodyStackSize = 4;
struct Body
{
    @disable this();

    static List!(cpBody*, bodyStackSize) bodyStack;
    static cpBody* currentBody()
    {
        return bodyStack.empty ? null : bodyStack[$-1];
    }
}

private mixin template BodyTemplate(string newCall)
{
    mixin Node;

    cpBody* body_;
    alias body_ this;

    void initialize()
    {
        mixin("body_ = " ~ newCall ~ ";");
        auto space = Space.currentSpace();
        assert(space, "Trying to create a Body without a Space");
        cpSpaceAddBody(space, body_);
        Body.bodyStack.push(body_);
    }

    void lateInitialize()
    {
        Body.bodyStack.pop();
    }

    void draw()
    {
        rlMatrixMode(RL_MODELVIEW);
        rlPushMatrix();
        auto t = Transform3D.identity
            .translate(-cast(Vector2) cpBodyGetCenterOfGravity(body_))
            .rotate(cast(float) -cpBodyGetAngle(body_))
            .translate(cast(Vector2) cpBodyGetPosition(body_));
        rlMultMatrixf(t.matrix.elements.ptr);
    }
    void lateDraw()
    {
        rlPopMatrix();
    }

    //~this()
    //{
        //if (body_)
        //{
            //auto space = cpBodyGetSpace(body_);
            //if (space)
            //{
                //cpSpaceRemoveBody(space, body_);
            //}
            //cpBodyFree(body_);
        //}
    //}
}

struct DynamicBody
{
    mixin BodyTemplate!"cpBodyNew(mass, inertia)";

    cpFloat mass = 1;
    cpFloat inertia;
}

struct KinematicBody
{
    mixin BodyTemplate!"cpBodyNewKinematic()";
}

struct StaticBody
{
    mixin BodyTemplate!"cpBodyNewStatic()";
}
