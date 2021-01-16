module gargula.log;

import gargula.wrapper.raylib;

/// Logging utilities
struct Log
{
    @disable this();

    /// Log a trace level message
    static void Trace(Args...)(string fmt, const auto ref Args args)
    {
        TraceLog(cast(int) TraceLogType.LOG_TRACE, cast(const char*) fmt, args);
    }
    /// Log a debug level message
    static void Debug(Args...)(string fmt, const auto ref Args args)
    {
        TraceLog(cast(int) TraceLogType.LOG_DEBUG, cast(const char*) fmt, args);
    }
    /// Log a info level message
    static void Info(Args...)(string fmt, const auto ref Args args)
    {
        TraceLog(cast(int) TraceLogType.LOG_INFO, cast(const char*) fmt, args);
    }
    /// Log a warning level message
    static void Warning(Args...)(string fmt, const auto ref Args args)
    {
        TraceLog(cast(int) TraceLogType.LOG_WARNING, cast(const char*) fmt, args);
    }
    /// Log an error level message
    static void Error(Args...)(string fmt, const auto ref Args args)
    {
        TraceLog(cast(int) TraceLogType.LOG_ERROR, cast(const char*) fmt, args);
    }
    /// Log a fatal level message
    static void Fatal(Args...)(string fmt, const auto ref Args args)
    {
        TraceLog(cast(int) TraceLogType.LOG_FATAL, cast(const char*) fmt, args);
    }
}
