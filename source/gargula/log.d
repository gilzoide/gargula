module gargula.log;

import std.string;

import gargula.wrapper.raylib;

/// Logging utilities
struct Log
{
    @disable this();

    private alias StringToCharP(T : inout(string)) = const(char)*;
    private alias StringToCharP(T) = T;

    /// Log a `level` level message, converting `string` values to `const(char)*`
    static void Log(string fmt, Args...)(int level, const auto ref Args args)
    {
        import std.meta : staticMap;
        staticMap!(StringToCharP, Args) result;
        static foreach (i, a; args)
        {
            static if (__traits(compiles, toStringz(a)))
            {
                result[i] = toStringz(a);
            }
            else
            {
                result[i] = a;
            }
        }
        TraceLog(level, cast(const char*) fmt, result);
    }

    /// Log a trace level message
    static void Trace(string fmt, Args...)(const auto ref Args args)
    {
        Log!fmt(LOG_TRACE, args);
    }
    /// Log a debug level message
    static void Debug(string fmt, Args...)(const auto ref Args args)
    {
        Log!fmt(LOG_DEBUG, args);
    }
    /// Log a info level message
    static void Info(string fmt, Args...)(const auto ref Args args)
    {
        Log!fmt(LOG_INFO, args);
    }
    /// Log a warning level message
    static void Warning(string fmt, Args...)(const auto ref Args args)
    {
        Log!fmt(LOG_WARNING, args);
    }
    /// Log an error level message
    static void Error(string fmt, Args...)(const auto ref Args args)
    {
        Log!fmt(LOG_ERROR, args);
    }
    /// Log a fatal level message
    static void Fatal(string fmt, Args...)(const auto ref Args args)
    {
        Log!fmt(LOG_FATAL, args);
    }
}

struct Logger(string _prefix)
{
    enum string prefix = _prefix ~ ": ";

    /// Log a trace level message, optionally prefixed by `prefix: `
    void Trace(string _fmt, bool addPrefix = true, Args...)(const auto ref Args args)
    {
        enum fmt = (addPrefix ? prefix ~ _fmt : _fmt);
        Log.Trace!fmt(args);
    }
    /// Log a debug level message, optionally prefixed by `prefix: `
    void Debug(string _fmt, bool addPrefix = true, Args...)(const auto ref Args args)
    {
        enum fmt = (addPrefix ? prefix ~ _fmt : _fmt);
        Log.Debug!fmt(args);
    }
    /// Log an info level message, optionally prefixed by `prefix: `
    void Info(string _fmt, bool addPrefix = true, Args...)(const auto ref Args args)
    {
        enum fmt = (addPrefix ? prefix ~ _fmt : _fmt);
        Log.Info!fmt(args);
    }
    /// Log a warning level message, optionally prefixed by `prefix: `
    void Warning(string _fmt, bool addPrefix = true, Args...)(const auto ref Args args)
    {
        enum fmt = (addPrefix ? prefix ~ _fmt : _fmt);
        Log.Warning!fmt(args);
    }
    /// Log a error level message, optionally prefixed by `prefix: `
    void Error(string _fmt, bool addPrefix = true, Args...)(const auto ref Args args)
    {
        enum fmt = (addPrefix ? prefix ~ _fmt : _fmt);
        Log.Error!fmt(args);
    }
    /// Log a fatal level message, optionally prefixed by `prefix: `
    void Fatal(string _fmt, bool addPrefix = true, Args...)(const auto ref Args args)
    {
        enum fmt = (addPrefix ? prefix ~ _fmt : _fmt);
        Log.Fatal!fmt(args);
    }

}
