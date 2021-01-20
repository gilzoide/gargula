module gargula.memory;

import core.stdc.stdlib;
import core.stdc.string;

/**
 * Memory management related functions.
 */
struct Memory
{
    @disable this();

    /// Allocate a raw block memory.
    static void[] allocate(size_t size)
    {
        void* buffer = malloc(size);
        return buffer[0 .. size];
    }

    /// Allocate an uninitialized instance of `T`.
    /// Result should be disposed with `Memory.dispose` when not needed anymore.
    static T* makeUninitialized(T)()
    {
        return cast(T*) allocate(T.sizeof);
    }
    /// Allocate an initialized instance of `T`.
    /// Result should be disposed with `Memory.dispose` when not needed anymore.
    static T* make(T)(const T initialValue = T.init)
    {
        typeof(return) value = makeUninitialized!T();
        memcpy(value, &initialValue, T.sizeof);
        return value;
    }

    /// Allocate an array of `size` uninitialized instances of `T`.
    /// Result should be disposed with `Memory.dispose` when not needed anymore.
    static T[] makeUninitializedArray(T)(size_t size)
    {
        auto bufferSize = size * T.sizeof;
        return cast(T[]) allocate(bufferSize);
    }
    /// Allocate an array of `size` initialized instances of `T`.
    /// Result should be disposed with `Memory.dispose` when not needed anymore.
    static T[] makeArray(T)(size_t size, const T initialValue = T.init)
    {
        typeof(return) array = makeUninitializedArray!T(size);
        array[] = initialValue;
        return array;
    }
    /// Allocate and initialize a copy of `values`.
    /// Result should be disposed with `Memory.dispose` when not needed anymore.
    static T[] makeArray(T, size_t N)(const T[N] values)
    {
        typeof(return) array = makeArray!T(N);
        memcpy(array.ptr, values.ptr, values.sizeof);
        return array;
    }

    /// Dispose memory pointed by `pointer` and reinitialize it to `null`.
    static void dispose(bool callDestroy = true, T)(ref T* pointer)
    {
        import std.traits : hasElaborateDestructor;
        static if (callDestroy && hasElaborateDestructor!T)
        {
            destroy(*pointer);
        }
        free(pointer);
        pointer = null;
    }

    /// Dispose memory referenced by `array` and reinitialize it to `null`.
    static void dispose(T)(ref T[] array)
    {
        // TODO: destroy
        free(array.ptr);
        array = null;
    }
}
