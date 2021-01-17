module gargula.node;

void traverseCallingNodes(
    string method,
    string lateMethod,
    string ifFieldTrue,
    T, Args...
)(
    auto ref T obj,
    auto ref Args args
)
if (is(T == struct))
{
    import std.traits : Fields, FieldNameTuple, hasMember;
    static if (hasMember!(T, ifFieldTrue))
    {
        if (!__traits(getMember, obj, ifFieldTrue))
        {
            return;
        }
    }

    // Going deep into fields
    static if (hasMember!(T, method))
    {
        __traits(getMember, obj, method)(args);
    }
    static foreach (i, fieldName; FieldNameTuple!T)
    {
        static if (is(Fields!T[i] == struct))
        {
            traverseCallingNodes!(method, lateMethod, ifFieldTrue)(__traits(getMember, obj, fieldName), args);
        }
    }
    static if (hasMember!(T, lateMethod))
    {
        __traits(getMember, obj, lateMethod)(args);
    }
}

/// Node in the object tree
mixin template Node()
{
    private alias T = typeof(this);

    import std.traits : hasMember;
    static if (hasMember!(T, "update") || hasMember!(T, "lateUpdate"))
    {
        bool active = true;
    }
    static if (hasMember!(T, "draw") || hasMember!(T, "lateDraw"))
    {
        bool visible = true;
    }

    void _frame(float dt)
    {
        traverseCallingNodes!("update", "lateUpdate", "active")(this, dt);
        traverseCallingNodes!("draw", "lateDraw", "visible")(this);
    }

    static T* create()
    {
        import gargula.memory : Memory;
        typeof(return) obj = Memory.make!T();
        traverseCallingNodes!("initialize", "lateInitialize", "_")(*obj);
        return obj;
    }
}


