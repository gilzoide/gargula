module gargula.builtin.tween;

import gargula.node;

/// Options for Tween Nodes
enum TweenOptions
{
    /// Default options
    none = 0,
    /// When Tween ends, it automatically inverts direction
    yoyo = 1 << 0,
    /// Calls `endCallback` delegate when tween ends
    endCallback = 1 << 1,
}

/// Tween Node with fixed easing function
struct Tween(string easingName = "linear", TweenOptions options = TweenOptions.none)
{
    mixin Node;

    import bettercmath.easings : Easing;
    import bettercmath.misc : lerp;
    import bettercmath.valuerange : ValueRange;

    import gargula.wrapper.raylib : GetFrameTime;

    /// Easing function used
    enum easingFunc = Easing!float.named!easingName;

    /// Duration in seconds
    float duration = 1;
    /// Current time
    float time = 0;
    /// Animation speed, rewinds on negative values, pauses on 0
    float speed = 1;
    /// If true, continue running after duration ended, starting again
    bool looping = false;
    /// Cached easing value result
    private float _value;

    static if (options & TweenOptions.yoyo)
    {
        /// If true, yoyo tweens loop when going forward even if `looping` is false
        bool yoyoLoops = true;
    }
    static if (options & TweenOptions.endCallback)
    {
        /// Callback called when tween ends
        void delegate() endCallback;
    }

    invariant
    {
        assert(duration > 0);
    }

    /// Reset time to 0
    void reset()
    {
        time = 0;
    }

    /// Returns whether Tween is rewinding, that is, time is being counted backwards
    bool isRewinding() const
    {
        return speed < 0;
    }

    /// Get current position in time relative to duration
    @property float position() const
    {
        return time / duration;
    }
    /// Set current position in time relative to duration
    @property void position(const float value)
    {
        time = value * duration;
    }

    /// Calculates value at current position
    float valueAtCurrentPosition() const
    {
        return easingFunc(position);
    }

    /// Get cached value
    float value() const
    {
        return _value;
    }
    /// Get cached value and returns the linear interpolation between `from` and `to` against it
    T value(T)(const T from, const T to)
    {
        return lerp(from, to, value);
    }
    /// Get cached value and returns the linear interpolation between `range` against it
    T value(T)(const ValueRange!T range) const
    {
        return range.lerp(_value);
    }

    ///
    void initialize()
    {
        _value = valueAtCurrentPosition();
    }

    ///
    void update()
    {
        time += GetFrameTime() * speed;
        if (time > duration || time < 0)
        {
            static if (options & TweenOptions.yoyo)
            {
                speed = -speed;
                active = looping || (yoyoLoops && isRewinding);
            }
            else
            {
                if (looping)
                {
                    time %= duration;
                }
                else
                {
                    active = false;
                }
            }

            import std.algorithm : clamp;
            time = clamp(time, 0, duration);
            static if (options & TweenOptions.endCallback)
            {
                if (endCallback) endCallback();
            }
        }
        _value = valueAtCurrentPosition();
    }
}

alias TweenYoyo(string easingName = "linear") = Tween!(easingName, TweenOptions.yoyo);
alias TweenCallback(string easingName = "linear") = Tween!(easingName, TweenOptions.endCallback);
alias TweenYoyoCallback(string easingName = "linear") = Tween!(easingName, TweenOptions.yoyo | TweenOptions.endCallback);
