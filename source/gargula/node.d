module gargula.node;

/// Node in the object tree
mixin template Node()
{
    private alias T = typeof(this);

    import std.traits : Fields, FieldNameTuple, hasMember;
    void callSelfThenChildren(string method, Args...)(Args args)
    {
        static if (hasMember!(T, method))
        {
            __traits(getMember, this, method)(args);
        }
        static foreach (i, fieldName; FieldNameTuple!T)
        {
            static if (hasMember!(Fields!T[i], "callSelfThenChildren"))
            {
                __traits(getMember, this, fieldName).callSelfThenChildren!method(args);
            }
            else static if (hasMember!(Fields!T[i], method))
            {
                __traits(getMember, __traits(getMember, this, fieldName), method)(args);
            }
        }
    }
    void callReverseChildrenThenSelf(string method, Args...)(Args args)
    {
        import std.meta : Reverse;
        static foreach (i, fieldName; Reverse!(FieldNameTuple!T))
        {
            static if (hasMember!(Reverse!(Fields!T)[i], "callReverseChildrenThenSelf"))
            {
                __traits(getMember, this, fieldName).callReverseChildrenThenSelf!method(args);
            }
            else static if (hasMember!(Reverse!(Fields!T)[i], method))
            {
                __traits(getMember, __traits(getMember, this, fieldName), method)(args);
            }
        }
        static if (hasMember!(T, method))
        {
            __traits(getMember, this, method)(args);
        }
    }

    void _frame(float dt)
    {
        callSelfThenChildren!"update"(dt);
        callReverseChildrenThenSelf!"lateUpdate"(dt);

        callSelfThenChildren!"draw"();
        callReverseChildrenThenSelf!"lateDraw"();
    }

    static T* create()
    {
        import gargula.memory : Memory;
        typeof(return) obj = Memory.make!T();
        obj.callSelfThenChildren!"initialize"();
        obj.callReverseChildrenThenSelf!"lateInitialize"();
        return obj;
    }
}


