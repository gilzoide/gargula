import gargula;

enum GameConfig gameConfig = {
    title: "mouse input",
    // Default FPS drawn on debug builds is on top of text, so disable it
    showDebugFPS: false,
};
alias Game = GameTemplate!(gameConfig);

struct Ball
{
    mixin Node;

    // Ball position, to be updated
    Vector2 position;
    // Ball color, updated on mouse button pressed
    Color color = DARKBLUE;

    // `update` is called each frame before `draw`
    void update()
    {
        position = GetMousePosition();

        if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON)) color = MAROON;
        else if (IsMouseButtonPressed(MOUSE_MIDDLE_BUTTON)) color = LIME;
        else if (IsMouseButtonPressed(MOUSE_RIGHT_BUTTON)) color = DARKBLUE;
    }

    void draw()
    {
        DrawCircleV(position, 40, color);
    }
}

struct Scene
{
    mixin Node;

    // This scene has a Ball object, initially positioned at [-100, -100]
    Ball ball = {
        position: [-100, -100],
    };

    // This `lateDraw` will be called after `Ball.draw`
    // To draw before all fields have been drawn, use `draw` instead
    void lateDraw()
    {
        DrawText("move ball with mouse and click mouse button to change color", 10, 10, 20, DARKGRAY);
    }
}

void main(string[] args)
{
    auto game = Game(args);
    game.create!Scene;
    game.run();
}
