module gargula.gamenode;

version (D_BetterC) {}
else debug
{
    import gargula.hotreload : haveHotReload;
    static if (haveHotReload)
    {
        version = HotReload;
    }
    version = SaveState;
    version = Pausable;
}

struct GameNode
{
    alias createMethod = void* delegate();
    alias initializeMethod = void delegate();
    alias updateMethod = void delegate();
    alias drawMethod = void delegate();
    alias frameMethod = void delegate();
    alias destroyMethod = void function(void*);

    void* object;
    version (Pausable)
    {
        updateMethod update;
        drawMethod draw;
        void frame()
        {
            update();
            draw();
        }
    }
    else
    {
        frameMethod frame;
    }
    destroyMethod destroy;
    version (HotReload)
    {
        initializeMethod initialize;
    }
    version (SaveState)
    {
        import std.json : JSONValue;
        alias serializeMethod = JSONValue function(void*);
        alias deserializeMethod = void function(void*, const ref JSONValue);
        serializeMethod serialize;
        deserializeMethod deserialize;
        string typeName;
    }

    static GameNode create(T)()
    {
        return GameNode(T.create());
    }

    this(T)(T* object)
    {
        this.object = object;
        version (Pausable)
        {
            update = &object._update;
            draw = &object._draw;
        }
        else
        {
            frame = &object._frame;
        }
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
        }
        version (SaveState)
        {
            import gargula.savestate : deserializeInto, serialize;
            this.serialize = cast(serializeMethod) &serialize!(T);
            this.deserialize = cast(deserializeMethod) &deserializeInto!(T);
            typeName = T.stringof;
        }
    }
}

version (SaveState)
{
    alias createNodeFunc = GameNode function();
    __gshared createNodeFunc[string] createNodeFunctions;
}
