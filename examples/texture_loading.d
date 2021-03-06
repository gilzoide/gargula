import gargula;

enum GameConfig gameConfig = {
    title: "texture loading",
    // Texture files declared here are stored in a Flyweight instance
    // and be reference counted/automatically unloaded when not needed
    textures: [
        {"oi.png", mipmaps: true},
    ],
};
alias Game = GameTemplate!(gameConfig);

struct Scene
{
    mixin Node;

    // Use `Game.Texture` instead of `Texture` to use the Flyweight
    Game.Texture texture;

    // This function is called by `game.create` and is used to initialize
    // state at runtime, as D does not support struct empty constructors
    void initialize()
    {
        // Textures in `gameConfig.textures` are created once when needed
        // and reused afterwards. Non identifier characters are converted
        // to underscores: "oi.png" -> "oi_png"
        texture = Game.Texture.oi_png;
    }

    void draw()
    {
        texture.draw((Game.config.size - texture.size) / 2, WHITE);

        DrawText("this IS a texture!", 360, 370, 10, GRAY);
    }
}

void main(string[] args)
{
    auto game = Game(args);
    game.create!Scene;
    game.run();
}

