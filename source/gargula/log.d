module gargula.log;

import gargula.wrapper.raylib;

/// Logging utilities
struct Log
{
    @disable this();

    private alias StringToCharP(T : inout(string)) = const(char)*;
    private alias StringToCharP(T) = T;

    /// Log a `level` level message, converting `string` values to `const(char)*`
    static void Log(Args...)(int level, const char* fmt, const auto ref Args args)
    {
        import std.meta : staticMap;
        staticMap!(StringToCharP, Args) result;
        static foreach (i, a; args)
        {
            import std.string : toStringz;
            static if (__traits(compiles, toStringz(a)))
            {
                result[i] = toStringz(a);
            }
            else
            {
                result[i] = a;
            }
        }
        TraceLog(level, fmt, result);
    }

    /// Log a trace level message
    static void Trace(Args...)(const char* fmt, const auto ref Args args)
    {
        Log(LOG_TRACE, fmt, args);
    }
    /// Log a debug level message
    static void Debug(Args...)(const char* fmt, const auto ref Args args)
    {
        Log(LOG_DEBUG, fmt, args);
    }
    /// Log a info level message
    static void Info(Args...)(const char* fmt, const auto ref Args args)
    {
        Log(LOG_INFO, fmt, args);
    }
    /// Log a warning level message
    static void Warning(Args...)(const char* fmt, const auto ref Args args)
    {
        Log(LOG_WARNING, fmt, args);
    }
    /// Log an error level message
    static void Error(Args...)(const char* fmt, const auto ref Args args)
    {
        Log(LOG_ERROR, fmt, args);
    }
    /// Log a fatal level message
    static void Fatal(Args...)(const char* fmt, const auto ref Args args)
    {
        Log(LOG_FATAL, fmt, args);
    }
}

struct Logger
{
    string prefix = "";

    /// Log a trace level message, optionally prefixed by `prefix: `
    void Trace(bool addPrefix = true, Args...)(const char* fmt, const auto ref Args args)
    {
        static if (addPrefix)
        {
            fmt = this.prefix ~ ": " ~ fmt;
        }
        Log.Trace(fmt, args);
    }
    /// Log a debug level message, optionally prefixed by `prefix: `
    void Debug(bool addPrefix = true, Args...)(const char* fmt, const auto ref Args args)
    {
        static if (addPrefix)
        {
            fmt = this.prefix ~ ": " ~ fmt;
        }
        Log.Debug(fmt, args);
    }
    /// Log an info level message, optionally prefixed by `prefix: `
    void Info(bool addPrefix = true, Args...)(const char* fmt, const auto ref Args args)
    {
        static if (addPrefix)
        {
            fmt = this.prefix ~ ": " ~ fmt;
        }
        Log.Info(fmt, args);
    }
    /// Log a warning level message, optionally prefixed by `prefix: `
    void Warning(bool addPrefix = true, Args...)(const char* fmt, const auto ref Args args)
    {
        static if (addPrefix)
        {
            fmt = this.prefix ~ ": " ~ fmt;
        }
        Log.Warning(fmt, args);
    }
    /// Log a error level message, optionally prefixed by `prefix: `
    void Error(bool addPrefix = true, Args...)(const char* fmt, const auto ref Args args)
    {
        static if (addPrefix)
        {
            fmt = this.prefix ~ ": " ~ fmt;
        }
        Log.Error(fmt, args);
    }
    /// Log a fatal level message, optionally prefixed by `prefix: `
    void Fatal(bool addPrefix = true, Args...)(const char* fmt, const auto ref Args args)
    {
        static if (addPrefix)
        {
            fmt = this.prefix ~ ": " ~ fmt;
        }
        Log.Fatal(fmt, args);
    }

}
