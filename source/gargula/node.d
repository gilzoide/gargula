module gargula.node;

void traverseCallingSelfThenChildren(
    string method,
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

    static if (hasMember!(T, method))
    {
        __traits(getMember, obj, method)(args);
    }
    static foreach (i, fieldName; FieldNameTuple!T)
    {
        static if (is(Fields!T[i] == struct))
        {
            traverseCallingSelfThenChildren!(method, ifFieldTrue)(__traits(getMember, obj, fieldName), args);
        }
    }
}

void traverseCallingReverseChildrenThenSelf(
    string method,
    string ifFieldTrue,
    T, Args...
)(
    auto ref T obj,
    auto ref Args args
)
if (is(T == struct))
{
    import std.meta : Reverse;
    import std.traits : Fields, FieldNameTuple, hasMember;
    static if (hasMember!(T, ifFieldTrue))
    {
        if (!__traits(getMember, obj, ifFieldTrue))
        {
            return;
        }
    }

    static foreach (i, fieldName; Reverse!(FieldNameTuple!T))
    {
        static if (is(Reverse!(Fields!T)[i] == struct))
        {
            traverseCallingSelfThenChildren!(method, ifFieldTrue)(__traits(getMember, obj, fieldName), args);
        }
    }
    static if (hasMember!(T, method))
    {
        __traits(getMember, obj, method)(args);
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

    void _frame()
    {
        traverseCallingSelfThenChildren!("update", "active")(this);
        traverseCallingReverseChildrenThenSelf!("lateUpdate", "active")(this);

        traverseCallingSelfThenChildren!("draw", "visible")(this);
        traverseCallingReverseChildrenThenSelf!("lateDraw", "visible")(this);
    }

    static T* create()
    {
        import gargula.memory : Memory;
        typeof(return) obj = Memory.make!T();
        traverseCallingSelfThenChildren!("initialize", "_")(*obj);
        traverseCallingReverseChildrenThenSelf!("lateInitialize", "_")(*obj);
        return obj;
    }
}


