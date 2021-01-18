module gargula.game;

import betterclist;

import gargula.wrapper.raylib;

version (WebAssembly)
{
extern(C):
    alias loop_func = void function(void*);
    ///
    void emscripten_set_main_loop_arg(loop_func, void*, int, int);
    ///
    void __assert(const char* message, const char* file, int line)
    {
        import core.stdc.stdio : printf;
        printf("Assertion error @ %s:%d: %s", file, line, message);
    }
}

private alias frameMethod = void delegate();
private struct GameObject
{
    void* object;
    frameMethod frame;
}

struct GameConfig
{
    /// Max number of objects at a time
    size_t maxObjects = 1024;
    /// Texture file paths
    string[] textures = [];
    /// Whether FPS should be shown on debug builds
    bool showDebugFPS = true;
    /// Initial window width
    int width = 800;
    /// Initial window height
    int height = 450;
    /// Target number of Frames per Second
    int targetFPS = 60;
    /// Initial window title
    string title = "Title";
    /// Default clear color, may be changed at runtime on GameTemplate instance
    Color clearColor = RAYWHITE;

    /// Returns a Vector2 with window size
    @property Vector2 size() const
    {
        return Vector2(width, height);
    }
}

struct GameTemplate(GameConfig _config = GameConfig.init)
{
    import gargula.resource : TextureResource;
    import gargula.builtin : SpriteTemplate, SpriteOptions;

    /// Game configuration
    enum config = _config;
    private enum N = _config.maxObjects;
    private enum textures = _config.textures;

    /// Clear color
    Color clearColor = _config.clearColor;

    /// Dynamic list of root game objects
    private List!(GameObject, N) rootObjects;

    // Resource Flyweights
    alias Texture = TextureResource!(textures);
    // Nodes that depend on resources
    alias Sprite = SpriteTemplate!(Texture);
    alias CenteredSprite = SpriteTemplate!(Texture, SpriteOptions.fixedPivot);
    alias AASprite = SpriteTemplate!(Texture, SpriteOptions.axisAligned);
    alias AACenteredSprite = SpriteTemplate!(Texture, SpriteOptions.axisAligned | SpriteOptions.fixedPivot);

    this(const string[] args)
    {
        if (args.length > 0)
        {
            const char* dir = GetDirectoryPath(cast(const char*) args[0]);
            if (dir[0])
            {
                ChangeDirectory(dir);
            }
        }
        InitWindow(_config.width, _config.height, cast(const char*) _config.title);
    }
    this(int argc, const char** argv)
    {
        if (argc > 0)
        {
            const char* dir = GetDirectoryPath(argv[0]);
            if (dir[0])
            {
                ChangeDirectory(dir);
            }
        }
        InitWindow(_config.width, _config.height, cast(const char*) _config.title);
    }

    /// Creates a new object of type `T` and adds it to root list.
    /// `T` must have a `create` method (like Nodes do).
    T* create(T)()
    {
        typeof(return) object = T.create();
        add(object);
        return object;
    }

    /// Add an object to root list.
    void add(T)(T* object)
    in { assert(object != null, "Trying to add a null object to Game"); }
    do
    {
        rootObjects.pushBack(GameObject(object, &object._frame));
    }

    /// Run main loop
    void run()
    {
        SetTargetFPS(_config.targetFPS);
        scope(exit)
        {
            CloseWindow();
        }
        loopFrame();
    }

    private void frame()
    {
        BeginDrawing();

        ClearBackground(clearColor);

        foreach (o; rootObjects)
        {
            o.frame();
        }

        static if (_config.showDebugFPS) debug DrawFPS(0, 0);

        EndDrawing();
    }

    version (WebAssembly)
    {
        extern(C) private static void callFrame(GameTemplate* game)
        {
            game.frame();
        }
        private void loopFrame()
        {
            emscripten_set_main_loop_arg(cast(loop_func) &callFrame, &this, 0, 1);
        }
    }
    else
    {
        private void loopFrame()
        {
            while (!WindowShouldClose())
            {
                frame();
            }
        }
    }
}

unittest
{
    alias Game = GameTemplate!();
}
