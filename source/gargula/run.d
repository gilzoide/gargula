import raylib;

extern(C):

struct WindowConfig
{
    int width = 800;
    int height = 600;
    int targetFPS = 60;
    string title = "Title";
}

void run()(const auto ref WindowConfig config = WindowConfig())
{
    InitWindow(config.width, config.height, cast(const char*) config.title);
    SetTargetFPS(config.targetFPS);
    scope(exit)
    {
        CloseWindow();
    }
    loopFrame();
}

version (WebAssembly)
{
    alias loop_func = void function();
    void emscripten_set_main_loop(loop_func, int, int);
    void loopFrame()
    {
        emscripten_set_main_loop(&frame, 0, 1);
    }
}
else
{
    void loopFrame()
    {
        while (!WindowShouldClose())
        {
            frame();
        }
    }
}

void frame()
{
    BeginDrawing();
    EndDrawing();
}
