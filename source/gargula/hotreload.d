module gargula.hotreload;

struct HotReload(Game)
{
    import std.string : toStringz;

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
            log!false("    > '%s'", file.ptr);
        }
    }

    void update(ref Game game)
    {
        bool shouldReload = false, shouldReloadSymbols = false;
        foreach (event; watcher.getEvents())
        {
            import std.algorithm : canFind;
            if (event.path == executableName && event.type == FileChangeEventType.modify)
            {
                log("Executable modified, will reload symbols");
                shouldReload = true;
                shouldReloadSymbols = true;
            }
            else if ((filesToWatch.canFind(event.path) && event.type == FileChangeEventType.modify)
                    || (filesToWatch.canFind(event.newPath) && event.type == FileChangeEventType.rename))
            {
                log("File modified '%s'", event.path.toStringz);
                shouldReload = true;
            }
            //else
            //{
                //log("- '%s' %d", event.path.toStringz, event.type);
            //}
        }

        if (shouldReload)
        {
            foreach (o; game.rootObjects)
            {
                log("Reloading '%s'", o.typeName.toStringz);
                o.destroy(o.object);
                o.initialize();
            }
        }
    }
}
