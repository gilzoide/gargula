module gargula.log;

import gargula.wrapper.raylib;

/// Logging utilities
struct Log
{
    @disable this();

    private alias StringToCharP(T : inout(string)) = const(char)*;
    private alias StringToCharP(T) = T;

    /// Log a `level` level message, converting `string` values to `const(char)*`
    static void Log(Args...)(int level, string fmt, const auto ref Args args)
    {
        import std.meta : staticMap;
        import std.string : toStringz;
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
        TraceLog(level, fmt.toStringz, result);
    }

    /// Log a trace level message
    static void Trace(Args...)(string fmt, const auto ref Args args)
    {
        Log(LOG_TRACE, fmt, args);
    }
    /// Log a debug level message
    static void Debug(Args...)(string fmt, const auto ref Args args)
    {
        Log(LOG_DEBUG, fmt, args);
    }
    /// Log a info level message
    static void Info(Args...)(string fmt, const auto ref Args args)
    {
        Log(LOG_INFO, fmt, args);
    }
    /// Log a warning level message
    static void Warning(Args...)(string fmt, const auto ref Args args)
    {
        Log(LOG_WARNING, fmt, args);
    }
    /// Log an error level message
    static void Error(Args...)(string fmt, const auto ref Args args)
    {
        Log(LOG_ERROR, fmt, args);
    }
    /// Log a fatal level message
    static void Fatal(Args...)(string fmt, const auto ref Args args)
    {
        Log(LOG_FATAL, fmt, args);
    }
}
