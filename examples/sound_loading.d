import gargula;

enum GameConfig gameConfig = {
    title: "sound loading",
    // Sound files declared here are stored in a Flyweight instance
    // and be reference counted/automatically unloaded when not needed
    sounds: [
        "Uebaaa.wav",
    ],
    windowFlags: FLAG_WINDOW_RESIZABLE,
};
alias Game = GameTemplate!(gameConfig);

struct Scene
{
    mixin Node;

    // Use `Game.Sound` instead of `Sound` to use the Flyweight
    Game.Sound sound;

    // This function is called by `game.create` and is used to initialize
    // state at runtime, as D does not support struct empty constructors
    void initialize()
    {
        // Textures in `gameConfig.textures` are created once when needed
        // and reused afterwards. Non identifier characters are converted
        // to underscores: "Uebaaa.wav" -> "Uebaaa_wav"
        sound = Game.Sound.Uebaaa_wav;
    }

    void update()
    {
        if (IsKeyPressed(KEY_SPACE)) sound.play();
    }

    void draw()
    {
        DrawText("Press SPACE to PLAY the WAV sound!", 200, 180, 20, LIGHTGRAY);
    }
}

void main(string[] args)
{
    auto game = Game(args);
    game.create!Scene;
    game.run();
}


