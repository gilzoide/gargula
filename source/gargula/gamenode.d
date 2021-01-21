module gargula.gamenode;

version (D_BetterC) {}
else debug
{
    version = HotReload;
    version = SaveState;
}

struct GameNode
{
    alias createMethod = void* delegate();
    alias initializeMethod = void delegate();
    alias frameMethod = void delegate();
    alias destroyMethod = void function(void*);

    void* object;
    frameMethod frame;
    destroyMethod destroy;
    version (HotReload)
    {
        initializeMethod initialize;
        string typeName;
    }
    version (SaveState)
    {
        import std.json : JSONValue;
        alias serializeMethod = JSONValue function(void*);
        alias deserializeMethod = void function(void*, const ref JSONValue);
        serializeMethod serialize;
        deserializeMethod deserialize;
        string mangledGameCreate;
    }

    static GameNode create(T)()
    {
        return GameNode(T.create());
    }

    this(T)(T* object)
    {
        this.object = object;
        frame = &object._frame;
        static if (__traits(compiles, &.destroy!(false, T)))
        {
            this.destroy = cast(destroyMethod) &.destroy!(false, T);
        }
        else
        {
            this.destroy = cast(destroyMethod) &.destroy!(T);
        }
        version (HotReload)
        {
            initialize = &object._initialize;
            typeName = T.stringof;
        }
        version (SaveState)
        {
            import gargula.savestate : deserializeInto, serialize;
            this.serialize = cast(serializeMethod) &serialize!(T);
            this.deserialize = cast(deserializeMethod) &deserializeInto!(T);
        }
    }
}

version (SaveState)
{
    alias createNodeFunc = GameNode function();
    __gshared createNodeFunc[string] createNodeFunctions;
}
