import gargula;

enum GameConfig gameConfig = {
    title: "keyboard input",
    // Default FPS drawn on debug builds is on top of text, so disable it
    showDebugFPS: false,
};
alias Game = GameTemplate!(gameConfig);

struct Ball
{
    mixin Node;

    // Ball position, to be updated
    Vector2 position;

    // `update` is called each frame before `draw`
    void update()
    {
        if (IsKeyDown(KEY_RIGHT)) position.x += 2.0f;
        if (IsKeyDown(KEY_LEFT)) position.x -= 2.0f;
        if (IsKeyDown(KEY_UP)) position.y -= 2.0f;
        if (IsKeyDown(KEY_DOWN)) position.y += 2.0f;
    }

    void draw()
    {
        DrawCircleV(position, 50, MAROON);
    }
}

struct Scene
{
    mixin Node;

    // This scene has a Ball object, initially positioned at the middle of the window
    Ball ball = {
        position: Game.config.size / 2,
    };

    // This `draw` will be called before `Ball.draw`
    // To draw after all fields have been drawn, use `lateDraw` instead
    void draw()
    {
        DrawText("move the ball with arrow keys", 10, 10, 20, DARKGRAY);
    }
}

void main(string[] args)
{
    auto game = Game(args);
    game.create!Scene;
    game.run();
}
