module gargula.node;

import std.meta;
import std.traits;

version (D_BetterC) {}
else debug
{
    version = SaveState;
}

/// Broadcasts `method` and `lateMethod` to object and all fields that
/// define this member function.
///
/// First calls `method` on object, if defined, then in all fields
/// from first to last that also define it.
///
/// Optionally, broadcast `lateMethod` in the same fashion as `method`,
/// but reversing the order: first call it in all fields from last to
/// first that defines the function, then call on this object.
///
/// Optionally, pass `ifFieldTrue` to check in runtime for this field
/// before calling the functions for objects that define it. A falsey
/// value makes function not be called.
void broadcast(
    string method,
    string lateMethod = null,
    string ifFieldTrue = null,
    T, Args...
)(
    auto ref T obj,
    auto ref Args args
)
if (is(T == struct) && (method != null || lateMethod != null))
{
    if (isFieldExistentAndFalse!ifFieldTrue(obj))
    {
        return;
    }

    static if (method != null && hasMember!(T, method))
    {
        //pragma(msg, "ROOT " ~ T.stringof ~ "." ~ method);
        mixin("obj." ~ method ~ "(args);");
    }
    broadcastChildren!(method, lateMethod, ifFieldTrue)(obj, args);
    static if (lateMethod != null && hasMember!(T, lateMethod))
    {
        //pragma(msg, "ROOT " ~ T.stringof ~ "." ~ lateMethod);
        mixin("obj." ~ lateMethod ~ "(args);");
    }
}

/// Broadcasts `method` and `lateMethod` to all fields that
/// define this member function.
///
/// Calls `method` on all fields from first to last that also define it.
///
/// Optionally, broadcast `lateMethod` in the same fashion as `method`,
/// but reversing the order: call it in all fields from last to
/// first that defines the function.
///
/// Optionally, pass `ifFieldTrue` to check in runtime for this field
/// before calling the functions for objects that define it. A falsey
/// value makes function not be called.
void broadcastChildren(
    string method,
    string lateMethod,
    string ifFieldTrue = null,
    T, Args...
)(
    auto ref T obj,
    auto ref Args args
)
if (is(T == struct) && (method != null || lateMethod != null))
{
    if (isFieldExistentAndFalse!ifFieldTrue(obj))
    {
        return;
    }

    enum aliasThis = __traits(getAliasThis, T);
    static foreach (i, fieldName; FieldNameTuple!T)
    {{
        static if (aliasThis.length == 0 || aliasThis != AliasSeq!(fieldName))
        {
            alias fieldType = Fields!T[i];
            // Call `method` on direct children
            static if (method != null && hasMember!(fieldType, method))
            {
                //pragma(msg, fieldType.stringof ~ " " ~ fieldName ~ "." ~ method);
                if (!isFieldExistentAndFalse!(ifFieldTrue)(mixin("obj." ~ fieldName)))
                {
                    mixin("obj." ~ fieldName ~ "." ~ method ~ "(args);");
                }
            }
            // repeat this traversal on children
            static if (is(fieldType == struct))
            {
                mixin("broadcastChildren!(method, lateMethod, ifFieldTrue)(obj." ~ fieldName ~ ", args);");
            }
        }
    }}
    static foreach (i, fieldName; Reverse!(FieldNameTuple!T))
    {{
        static if (aliasThis.length == 0 || aliasThis != AliasSeq!(fieldName))
        {
            alias fieldType = Reverse!(Fields!T)[i];
            // Call `lateMethod` on direct children
            static if (lateMethod != null && hasMember!(fieldType, lateMethod))
            {
                //pragma(msg, fieldType.stringof ~ " " ~ fieldName ~ "." ~ lateMethod);
                if (!isFieldExistentAndFalse!(ifFieldTrue)(mixin("obj." ~ fieldName)))
                {
                    mixin("obj." ~ fieldName ~ "." ~ lateMethod ~ "(args);");
                }
            }
        }
    }}
}

bool isFieldExistentAndFalse(string ifFieldTrue, T)(ref T obj)
{
    static if (ifFieldTrue != null && hasMember!(T, ifFieldTrue))
    {
        return !mixin("obj." ~ ifFieldTrue);
    }
    else
    {
        return false;
    }
}

/// Node in the object tree
mixin template Node()
{
    private alias T = typeof(this);

    bool active = true;
    bool visible = true;

    void _initialize()()
    {
        this.broadcast!("initialize", "lateInitialize");
    }

    void _update()()
    {
        this.broadcast!("update", "lateUpdate", "active");
    }

    void _draw()()
    {
        this.broadcast!("draw", "lateDraw", "visible");
    }

    void _frame()()
    {
        _update();
        _draw();
    }

    static T* create()
    {
        import gargula.memory : Memory;
        typeof(return) obj = Memory.make!T();
        obj._initialize();
        return obj;
    }

    version (SaveState)
    {
        shared static this()
        {
            import gargula.gamenode : createNodeFunctions, GameNode;
            createNodeFunctions[T.stringof] = &GameNode.create!T;
        }
    }
}
