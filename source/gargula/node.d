module gargula.node;

void traverseCallingSelfThenChildren(
    string method,
    string ifFieldTrue = null,
    T, Args...
)(
    auto ref T obj,
    auto ref Args args
)
if (is(T == struct))
{
    static if (method == null) return;

    import std.traits : Fields, FieldNameTuple, hasMember;
    static if (ifFieldTrue != null && hasMember!(T, ifFieldTrue))
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
    string ifFieldTrue = null,
    T, Args...
)(
    auto ref T obj,
    auto ref Args args
)
if (is(T == struct))
{
    static if (method == null) return;

    import std.meta : Reverse;
    import std.traits : Fields, FieldNameTuple, hasMember;
    static if (ifFieldTrue != null && hasMember!(T, ifFieldTrue))
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

    /// Broadcasts `method` to all fields that define this member function.
    ///
    /// First calls `method` on this object, if defined, then in all fields
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
        Args...
    ) (
        auto ref Args args
    )
    {
        traverseCallingSelfThenChildren!(method, ifFieldTrue)(this, args);
        traverseCallingReverseChildrenThenSelf!(lateMethod, ifFieldTrue)(this, args);
    }

    void _frame()
    {
        broadcast!("update", "lateUpdate", "active");
        broadcast!("draw", "lateDraw", "visible");
    }

    static T* create()
    {
        import gargula.memory : Memory;
        typeof(return) obj = Memory.make!T();
        obj.broadcast!("initialize", "lateInitialize");
        return obj;
    }
}


