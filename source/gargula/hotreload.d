module gargula.hotreload;

package struct HotReload(Game)
{
    import fswatch : FileChangeEventType, FileWatch;
    
    import gargula.builtin.tween;
    import gargula.log : Logger;

    Logger log = {
        prefix: "HOTRELOAD",
    };

    FileWatch watcher;
    string executableName;
    string[] filesToWatch;
    TweenCallback!() delay = {
        duration: Game.config.debugReloadCodeDelay,
    };
    bool reloadingCode = false;
    void initialize(ref Game game, string baseDir, const char* exename, string[][] fileLists...)
    {
        import std.array : join;
        import std.conv : to;
        watcher = FileWatch(baseDir, true);
        executableName = to!string(exename);
        filesToWatch = join(fileLists);

        log.Info("Watching files '%s'", exename);
        foreach (file; filesToWatch)
        {
            log.Debug!false("    > '%s'", file);
        }

        delay.endCallback = () {
            reloadCode(game);
        };
    }

    void update(ref Game game)
    {
        if (reloadingCode)
        {
            delay.update();
            return;
        }


        bool shouldReload = false;
        foreach (event; watcher.getEvents())
        {
            import std.algorithm : among, canFind;
            auto isSomeUpdateEvent = event.type.among(FileChangeEventType.modify, FileChangeEventType.create);
            if (isSomeUpdateEvent && event.path == executableName)
            {
                log.Info("Executable modified, reloading code in %g", delay.duration);
                reloadingCode = true;
                return;
            }
            else if ((isSomeUpdateEvent && filesToWatch.canFind(event.path))
                    || (filesToWatch.canFind(event.newPath) && event.type == FileChangeEventType.rename))
            {
                log.Info("File modified '%s'", event.path);
                shouldReload = true;
            }
            //else
            //{
                //log("- '%s' %d", event.path, event.type);
            //}
        }

        if (shouldReload)
        {
            foreach (o; game.rootObjects)
            {
                log.Info("Reloading '%s'", o.typeName);
                o.destroy(o.object);
                o.initialize();
            }
        }
    }

    private void reloadCode(ref Game game)
    {
        version (Posix)
        {
            import core.sys.posix.unistd : access, execl, X_OK;
            import core.stdc.stdio : perror;
            import std.string : toStringz;
            auto executableNameZ = executableName.toStringz;
            if (access(executableNameZ, X_OK) == 0)
            {
                log.Info("Reloading code!");
                string state = game.saveState.serializeGameAsText(game);
                game.cleanup();
                destroy(watcher);
                const int res = execl(
                    executableNameZ,
                    executableNameZ,
                    "--load".toStringz,
                    state.toStringz,
                    game.isPaused ? "--paused".toStringz : null,
                    null
                );
                if (res)
                {
                    import core.stdc.stdlib : exit;
                    perror("ERROR: HOTRELOAD: Couldn't reload code");
                    exit(-1);
                }
            }
            else
            {
                perror("ERROR: HOTRELOAD: Cannot exec");
            }
        }
        else
        {
            log.Info("Code reloading is not implemented for this platform yet!");
        }
    }
}
