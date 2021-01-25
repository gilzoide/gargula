module gargula.hotreload;

package struct HotReload(Game)
{
    import fswatch : FileChangeEventType, FileWatch;

    private static void log(bool prefix = true, Args...)(string fmt, auto ref Args args)
    {
        import gargula.log : Log;
        static if (prefix)
        {
            fmt = "HOTRELOAD: " ~ fmt;
        }
        Log.Info(fmt, args);
    }

    FileWatch watcher;
    string executableName;
    string[] filesToWatch;
    void initialize(string baseDir, const char* exename, string[][] fileLists...)
    {
        import std.array : join;
        import std.conv : to;
        watcher = FileWatch(baseDir, true);
        executableName = to!string(exename);
        filesToWatch = join(fileLists);

        log("Watching files");
        foreach (file; filesToWatch)
        {
            log!false("    > '%s'", file);
        }
    }

    void update(ref Game game)
    {
        bool shouldReload = false, shouldReloadCode = false;
        foreach (event; watcher.getEvents())
        {
            import std.algorithm : among, canFind;
            auto isSomeUpdateEvent = event.type.among(FileChangeEventType.modify, FileChangeEventType.create);
            if (isSomeUpdateEvent && event.path == executableName)
            {
                log("Executable modified, will reload symbols");
                shouldReload = true;
                shouldReloadCode = true;
            }
            else if ((isSomeUpdateEvent && filesToWatch.canFind(event.path))
                    || (filesToWatch.canFind(event.newPath) && event.type == FileChangeEventType.rename))
            {
                log("File modified '%s'", event.path);
                shouldReload = true;
            }
            //else
            //{
                //log("- '%s' %d", event.path, event.type);
            //}
        }

        if (shouldReloadCode)
        {
            reloadCode(game);
        }
        else if (shouldReload)
        {
            foreach (o; game.rootObjects)
            {
                log("Reloading '%s'", o.typeName);
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
                log("Reloading code!");
                string state = game.saveState.serializeGameAsText(game);
                game.cleanup();
                destroy(watcher);
                const int res = execl(
                    executableNameZ,
                    executableNameZ,
                    "--load".toStringz,
                    state.toStringz,
                    null
                );
                if (res)
                {
                    import core.stdc.stdlib : exit;
                    perror("Error reloading code!!!");
                    exit(-1);
                }
            }
            else
            {
                perror("Cannot exec");
            }
        }
        else
        {
            log("Code reloading is not implemented for this platform yet!");
        }
    }
}
