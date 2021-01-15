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

private alias frameMethod = void delegate(float);
private struct GameObject
{
    void* object;
    frameMethod frame;
}

struct GameConfig
{
    size_t maxObjects = 1024;
    string[] textures = [];
}

struct Game(GameConfig _config = GameConfig.init)
{
    import gargula.resource : TextureResource;
    import gargula.builtin : SpriteTemplate;

    private enum N = _config.maxObjects;
    private enum textures = _config.textures;

    /// Initial window width
    int width = 800;
    /// Initial window height
    int height = 600;
    /// Target number of Frames per Second
    int targetFPS = 60;
    /// Initial window title
    string title = "Title";
    /// Clear color
    Color clearColor = RAYWHITE;

    /// Dynamic list of root game objects
    private List!(GameObject, N) rootObjects;

    alias Texture = TextureResource!(textures);
    alias Sprite = SpriteTemplate!(Texture);

    /// Creates a new object of type `T` and adds it to root list.
    /// `T` must have a `create` method (like Nodes do).
    T* createObject(T)()
    {
        typeof(return) object = T.create();
        addObject(object);
        return object;
    }

    /// Add an object to root list.
    void addObject(T)(T* object)
    in { assert(object != null, "Trying to add a null object to Game"); }
    do
    {
        rootObjects.pushBack(GameObject(object, &object._frame));
    }

    /// Run main loop
    void run()
    {
        InitWindow(width, height, cast(const char*) title);
        SetTargetFPS(targetFPS);
        scope(exit)
        {
            CloseWindow();
        }
        loopFrame();
    }

    private void frame()
    {
        immutable float delta = GetFrameTime();
        BeginDrawing();

        ClearBackground(clearColor);
        debug DrawFPS(0, 0);

        foreach (o; rootObjects)
        {
            o.frame(delta);
        }

        EndDrawing();
    }

    version (WebAssembly)
    {
        extern(C) private static void callFrame(Game* game)
        {
            game.frame();
        }
        private void loopFrame()
        {
            emscripten_set_main_loop_arg(cast(loop_func) &Game.callFrame, &this, 0, 1);
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
