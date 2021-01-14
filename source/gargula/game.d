module gargula.game;

import betterclist;
import raylib;

extern(C):

version (WebAssembly)
{
    alias loop_func = void function(void*);
    void emscripten_set_main_loop_arg(loop_func, void*, int, int);
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
    int width = 800;
    int height = 600;
    int targetFPS = 60;
    string title = "Title";

    private List!(GameObject, N) objects;

    void run()
    {
        InitWindow(width, height, cast(const char*) title);
        SetTargetFPS(targetFPS);
        scope(exit)
        {
            CloseWindow();
        }
        loopFrame(&this);
    }

    private void frame()
    {
        immutable float delta = GetFrameTime();
        BeginDrawing();

        foreach (o; objects)
        {
            o.frame(delta);
        }

        EndDrawing();
    }

    version (WebAssembly)
    {
        private static void loopFrame(Game* game)
        {
            emscripten_set_main_loop_arg(cast(loop_func) &Game.frame, game, 0, 1);
        }
    }
    else
    {
        private static void loopFrame(Game* game)
        {
            while (!WindowShouldClose())
            {
                game.frame();
            }
        }
    }
}
