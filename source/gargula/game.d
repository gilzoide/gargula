module gargula.game;

import betterclist;

import gargula.wrapper.raylib;

extern(C):

version (WebAssembly)
{
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

struct Game(size_t N = 1024)
{
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

    /// Dynamic list of game objects
    private List!(GameObject, N) objects;

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

        foreach (o; objects)
        {
            o.frame(delta);
        }

        EndDrawing();
    }

    version (WebAssembly)
    {
        private static void callFrame(Game* game)
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
