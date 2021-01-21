module gargula.hotreload;

version (D_BetterC) {}
else debug version = HotReload;

version (HotReload)
{
    private void log(bool prefix = true, Args...)(string fmt, auto ref Args args)
    {
        import gargula.log : Log;
        static if (prefix)
        {
            fmt = "HOTRELOAD: " ~ fmt;
        }
        Log.Info(fmt, args);
    }

    import fswatch : FileChangeEventType, FileWatch;
    FileWatch watcher;
    string[] filesToWatch;
    void initialize(string baseDir, const char* exename, string[][] fileLists...)
    {
        import std.array : join;
        import std.conv : to;
        watcher = FileWatch(baseDir, true);
        filesToWatch = to!string(exename) ~ join(fileLists);

        log("Watching files");
        foreach (file; filesToWatch)
        {
            log!false("    > '%s'", file.ptr);
        }
    }

    void update(Game)(ref Game game)
    {
        bool shouldReload = false;
        foreach (event; watcher.getEvents())
        {
            import std.algorithm : canFind;
            import std.string : toStringz;
            if (filesToWatch.canFind(event.path) && event.type == FileChangeEventType.modify)
            {
                log("File modified '%s'", event.path.toStringz);
                shouldReload = true;
            }
        }

        if (shouldReload)
        {
            // TODO
        }
    }
}
else
{
    void initialize(Args...)(auto ref Args args) {}
    void update(Args...)(auto ref Args args) {}
}
