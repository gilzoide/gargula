module gargula.savestate;

import std.json;

JSONValue serialize(T)(ref T value)
{
    static if (is(T == struct) || is(T == class))
    {
        import std.traits : FieldNameTuple;
        JSONValue[string] json;
        static foreach (i, field; FieldNameTuple!T)
        {
            if (__traits(getMember, value, field) != __traits(getMember, T.init, field))
            {
                json[field] = __traits(getMember, value, field).serialize;
            }
        }
        return JSONValue(json);
    }
    else
    {
        return JSONValue(value);
    }
}

package struct SaveState(Game)
{
    import gargula.log : Log;
    import gargula.wrapper.raylib : IsKeyDown, IsKeyPressed;

    JSONValue serializeGame(ref Game game)
    {
        JSONValue[] jsonObjects;
        foreach (o; game.rootObjects)
        {
            jsonObjects ~= JSONValue([o.typeName: o.serialize(o.object)]);
        }
        return JSONValue(jsonObjects);
    }

    string serializeGameAsText(ref Game game)
    {
        JSONValue value = serializeGame(game);
        return value.toPrettyString();
    }

    void update(ref Game game)
    {
        import std.algorithm : all;
        if (Game.config.debugComboKeys.all!IsKeyDown)
        {
            if (IsKeyPressed(Game.config.debugSaveStateKey))
            {
                Log.Info("state '%s'", serializeGameAsText(game).ptr);
            }
            if (IsKeyPressed(Game.config.debugLoadStateKey))
            {
            }
            if (IsKeyPressed(Game.config.debugReloadKey))
            {
            }
        }
    }
}

