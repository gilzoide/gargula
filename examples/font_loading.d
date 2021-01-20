import gargula;

enum GameConfig gameConfig = {
    title: "font loading",
    // Font files declared here are stored in a Flyweight instance
    // and be reference counted/automatically unloaded when not needed
    fonts: [
        "SatellaRegular.ttf",
    ],
};
alias Game = GameTemplate!(gameConfig);

struct Scene
{
    mixin Node;

    // Use `Game.Font` instead of `Font` to use the Flyweight
    Game.Font font;

    // This function is called by `game.create` and is used to initialize
    // state at runtime, as D does not support struct empty constructors
    void initialize()
    {
        // Textures in `gameConfig.textures` are created once when needed
        // and reused afterwards. Non identifier characters are converted
        // to underscores: "SatellaRegular.ttf" -> "SatellaRegular_ttf"
        font = Game.Font.SatellaRegular_ttf;
    }

    void draw()
    {
        const char* msg = "Loaded Font!";
        immutable float spacing = 2;
        immutable Vector2 textPosition = [
            Game.config.width / 2 - MeasureTextEx(font, msg, font.baseSize, spacing).x / 2,
            Game.config.height / 2 - font.baseSize / 2,
        ];
        DrawTextEx(font, msg, textPosition, font.baseSize, spacing, BLACK);
    }
}

void main(string[] args)
{
    auto game = Game(args);
    game.create!Scene;
    game.run();
}


