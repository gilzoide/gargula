module gargula.game;

import gargula.log;
import gargula.wrapper.raylib;

debug
{
    version = Pausable;
    version (D_BetterC) {}
    else
    {
        import gargula.hotreload : haveHotReload;
        static if (haveHotReload)
        {
            version = HotReload;
        }
        version = SaveState;
    }
}

version (WebAssembly)
{
extern(C):
    alias loop_func = void function(void*);
    ///
    void emscripten_set_main_loop_arg(loop_func, void*, int, int);
}

extern(C) void __assert(const char* message, const char* file, int line)
{
    Log.Fatal!"Assertion error @ %s:%d: %s"(file, line, message);
}

struct GameConfig
{
    import gargula.resource.rendertexture : RenderTextureOptions;
    import gargula.resource.shader : ShaderOptions;
    import gargula.resource.texture : TextureOptions;

    /// Max number of objects at a time
    size_t maxObjects = 1024;

    /// Config flags for window
    uint windowFlags = FLAG_VSYNC_HINT;
    /// Whether Audio should be initialized along with Window
    bool initAudio = true;
    /// Whether Physac should be initialized along with Window
    bool enablePhysac = true;
    /// Whether FPS should be shown on debug builds
    bool showDebugFPS = true;
    /// Log level to set on debug builds
    int debugLogLevel = LOG_DEBUG;
    /// Log level to set on release builds
    int releaseLogLevel = LOG_WARNING;

    /// Initial window width
    int width = 800;
    /// Initial window height
    int height = 450;
    /// Target number of Frames per Second
    int targetFPS = -1;
    /// Initial window title
    string title = "Title";
    /// Default clear color, may be changed at runtime on GameTemplate instance
    Color clearColor = RAYWHITE;

    /// Font file paths
    string[] fonts = [];
    /// Music file paths
    string[] musics = [];
    /// Sound file paths
    string[] sounds = [];
    /// Texture file paths and options
    TextureOptions[] textures = [];
    /// Wave file paths
    string[] waves = [];

    /// RenderTexture Flyweight configurations
    RenderTextureOptions[] renderTextures = [];
    /// Shader codes
    ShaderOptions[] shaders = [];

    /// Combo keys for triggering reload or save/load state
    int[] debugComboKeys = [KEY_LEFT_ALT];
    /// Key that triggers a game pause/resume on debug
    int debugPauseKey = KEY_P;
    /// Key that triggers a single frame advance when game is paused on debug
    int debugAdvanceFrameKey = KEY_N;
    /// Key that triggers a game reload on debug
    int debugReloadKey = KEY_R;
    /// Key that triggers a save game state on debug
    int debugSaveStateKey = KEY_C;
    /// Key that triggers a load game state on debug
    int debugLoadStateKey = KEY_V;
    /// Key that toggles debug drawing for Chipmunk
    int debugDrawChipmunk = KEY_D;
    /// Delay to wait before reloading code
    float debugReloadCodeDelay = 0.5;

    /// Returns a Vector2 with window size
    @property Vector2 size() const
    {
        return Vector2(width, height);
    }
}

struct GameTemplate(GameConfig _config = GameConfig.init)
{
    import betterclist : list, List;

    import gargula.gamenode : GameNode;
    import gargula.resource.font : FontResource;
    import gargula.resource.music : MusicResource;
    import gargula.resource.rendertexture : RenderTextureResource;
    import gargula.resource.shader : ShaderResource;
    import gargula.resource.sound : SoundResource;
    import gargula.resource.texture : TextureResource;
    import gargula.resource.wave : WaveResource;
    import gargula.builtin : MusicStreamTemplate, SpriteVariations;

    /// Game configuration
    enum config = _config;
    private enum N = _config.maxObjects;
    private enum fonts = _config.fonts;
    private enum musics = _config.musics;
    private enum shaders = _config.shaders;
    private enum sounds = _config.sounds;
    private enum textures = _config.textures;
    private enum waves = _config.waves;
    private enum renderTextures = _config.renderTextures;

    /// Clear color
    Color clearColor = _config.clearColor;

    /// Dynamic list of root game objects
    package List!(GameNode, N) rootObjects;

    // Resource Flyweights
    alias Font = FontResource!(fonts).Flyweight;
    alias Music = MusicResource!(musics).Flyweight;
    alias RenderTexture = RenderTextureResource!(renderTextures).Flyweight;
    alias Shader = ShaderResource!(shaders).Flyweight;
    alias Sound = SoundResource!(sounds).Flyweight;
    alias Texture = TextureResource!(textures).Flyweight;
    alias Wave = WaveResource!(waves).Flyweight;
    // Nodes that depend on resources
    alias MusicStream = MusicStreamTemplate!(Music);
    mixin SpriteVariations!Texture;

    version (HotReload)
    {
        import gargula.hotreload : HotReload;
        package HotReload!GameTemplate hotreload;
    }
    version (SaveState)
    {
        import gargula.savestate : SaveState;
        package SaveState!GameTemplate saveState;
        package string initialState;
    }
    version (Pausable)
    {
        package bool isPaused;
    }
    version (D_BetterC) {}
    else this(string[] args)
    {
        debug SetTraceLogLevel(_config.debugLogLevel);
        else  SetTraceLogLevel(_config.releaseLogLevel);
        if (args.length > 0)
        {
            import std.string : toStringz;
            processArg0(args[0].toStringz);
        }
        processArgs(args);
        initWindow();
    }
    this(int argc, const char** argv)
    {
        debug SetTraceLogLevel(_config.debugLogLevel);
        else  SetTraceLogLevel(_config.releaseLogLevel);
        if (argc > 0)
        {
            processArg0(argv[0]);
        }
        initWindow();
    }

    private void processArg0(const char* arg0)
    {
        const char* dir = GetDirectoryPath(arg0);
        if (dir[0])
        {
            ChangeDirectory(dir);

            version (HotReload)
            {
                hotreload.initialize(
                    this,
                    ".",
                    GetFileName(arg0),
                    FontResource!(fonts).filenames,
                    MusicResource!(musics).filenames,
                    SoundResource!(sounds).filenames,
                    TextureResource!(textures).filenames,
                    WaveResource!(waves).filenames,
                );
            }
        }
    }

    private void processArgs(string[] args)
    {
        version (SaveState)
        {
            import std.getopt : getopt;
            getopt(
                args,
                "load", &initialState,
                "paused", &isPaused,
            );
        }
    }

    private void initWindow()
    {
        if (!IsWindowReady())
        {
            static if (_config.windowFlags > 0)
            {
                SetConfigFlags(_config.windowFlags);
            }
            InitWindow(_config.width, _config.height, cast(const char*) _config.title);
            static if (_config.initAudio)
            {
                InitAudioDevice();
            }
            static if (_config.enablePhysac)
            {
                import gargula.wrapper.physac : InitPhysics;
                InitPhysics();
            }
        }
    }

    /// Creates a new object of type `T` and adds it to root list.
    /// `T` must have a `create` method (like Nodes do).
    T* create(T)()
    {
        auto node = GameNode.create!T();
        addGameNode(node);
        return cast(T*) node.object;
    }

    /// Add an object to root list.
    void add(T)(T* object)
    in { assert(object != null, "Trying to add a null object to Game"); }
    do
    {
        GameNode node = object;
        addGameNode(node);
    }

    package GameNode addGameNode(return GameNode node)
    {
        rootObjects.push(node);
        return node;
    }

    package void destroyRemainingObjects()
    {
        foreach (ref o; rootObjects)
        {
            import gargula.memory : Memory;
            o.destroy(o.object);
            Memory.dispose!false(o.object);
        }
        rootObjects.clear();
    }

    private void unloadFlyweights()
    {
        Font.unloadAll();
        Music.unloadAll();
        RenderTexture.unloadAll();
        Sound.unloadAll();
        Texture.unloadAll();
        Wave.unloadAll();
    }

    package void cleanup()
    {
        destroyRemainingObjects();
        // Destroying all objects should suffice to destroy remaining
        // Flyweight instances, but just to be sure...
        unloadFlyweights();
        static if (_config.enablePhysac)
        {
            import gargula.wrapper.physac : ClosePhysics;
            ClosePhysics();
        }
        static if (_config.initAudio)
        {
            CloseAudioDevice();
        }
        CloseWindow();
    }

    /// Run main loop
    void run()
    {
        version (SaveState)
        {
            saveState.initialize(this, initialState);
        }

        static if (_config.targetFPS != GameConfig.init.targetFPS)
        {
            SetTargetFPS(_config.targetFPS);
        }
        scope(exit)
        {
            cleanup(); 
        }
        loopFrame();
    }

    private void frame()
    {
        BeginDrawing();

        version (HotReload)
        {
            hotreload.update(this);
        }
        version (SaveState)
        {
            saveState.update(this);
        }

        ClearBackground(clearColor);

        version (Pausable)
        {
            import std.algorithm : all;
            import gargula.wrapper.raylib : IsKeyDown, IsKeyPressed;

            bool forceUpdate = false;
            immutable debugComboKeys = _config.debugComboKeys;
            if (debugComboKeys.all!IsKeyDown)
            {
                if (IsKeyPressed(_config.debugPauseKey))
                {
                    isPaused = !isPaused;
                }
                if (IsKeyPressed(_config.debugAdvanceFrameKey))
                {
                    forceUpdate = true;
                }
                if (IsKeyPressed(_config.debugDrawChipmunk))
                {
                    import gargula.chipmunk.space : Space;
                    Space.debugDrawEnabled = !Space.debugDrawEnabled;
                }
            }
            if (!isPaused || forceUpdate)
            {
                static if (_config.enablePhysac)
                {
                    import gargula.wrapper.physac : UpdatePhysics;
                    UpdatePhysics();
                }
            }
            foreach (o; rootObjects)
            {
                if (!isPaused || forceUpdate)
                {
                    o.update();
                }
                o.draw();
            }
            if (isPaused)
            {
                DrawText(cast(const char*) "PAUSED", 0, 20, 20, LIME);
            }
        }
        else
        {
            static if (_config.enablePhysac)
            {
                import gargula.wrapper.physac : UpdatePhysics;
                UpdatePhysics();
            }
            foreach (o; rootObjects)
            {
                o.frame();
            }
        }

        static if (_config.showDebugFPS) debug DrawFPS(0, 0);

        EndDrawing();
    }

    version (WebAssembly)
    {
        extern(C) private static void callFrame(GameTemplate* game)
        {
            game.frame();
        }
        private void loopFrame()
        {
            emscripten_set_main_loop_arg(cast(loop_func) &callFrame, &this, 0, 1);
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
