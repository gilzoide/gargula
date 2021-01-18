import gargula;

// 1. Configure your game
enum GameConfig gameConfig = {
    title: "basic window",
    // There are other available configs, check `gargula.game.GameConfig`
    // for all options. Some defaults:
    // ---
    // width: 800,
    // height: 450,
    // clearColor: RAYWHITE,
    // targetFPS: 60,
    // ---
};
// 2. Instantiate GameTemplate struct (tip: use an alias)
alias Game = GameTemplate!(gameConfig);


// 3. Declare your Game objects/scenes structure
struct BasicWindow
{
    // Game objects/scenes should be Nodes, so Game can instantiate it
    // correctly, call update/draw on all fields in the right order, 
    // and much more to come!
    mixin Node;

    void draw()
    {
        // Any raylib function can be used!
        // Check out https://www.raylib.com/cheatsheet/cheatsheet.html
        DrawText("Congrats! You created your first window!", 190, 200, 20, LIGHTGRAY);
    }
}

void main(string[] args)
{
    // 4. Instantiate Game, forwarding `args` so it can know from which
    // directory it was run (this matters for asset loading, for example)
    // and provide some CLI flags on debug builds (NYI)
    auto game = Game(args);
    // 5. Create instances of your scene using Game.create
    game.create!BasicWindow();
    // Or by creating it first, then registering with Game.add
    // ---
    // // `create` is defined by `mixin Node;`
    // auto basicWindow = BasicWindow.create();
    // game.add(basicWindow);
    // ---

    //6. Run your game loop!
    game.run();
}
