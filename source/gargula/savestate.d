module gargula.savestate;

import std.json;
import std.string : toStringz;

import flyweightbyid;

import gargula.log : Log;

enum skipSerialization(T) = is(T : Flyweight!Args, Args...) || is(T : U*, U);

JSONValue serialize(T)(ref T value)
if (!skipSerialization!T)
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

JSONValue serialize(T)(ref T value)
if (skipSerialization!T)
{
    JSONValue[string] json;
    return JSONValue(json);
}

void deserializeInto(T)(T* value, const ref JSONValue json)
if (!skipSerialization!T)
{
    if (json.isNull)
    {
        return;
    }

    static if (is(T == struct) || is(T == class))
    {
        import std.traits : FieldNameTuple;
        static foreach (i, field; FieldNameTuple!T)
        {
            if (field in json.object)
            {
                deserializeInto(&__traits(getMember, value, field), json.object[field]);
            }
        }
    }
    else static if (is(T : U[N], U, size_t N))
    {
        import std.algorithm : min;
        foreach (i; 0 .. min(json.array.length, N))
        {
            deserializeInto!U(&(*value)[i], json.array[i]);
        }
    }
    else
    {
        import std.conv : to;
        switch (json.type)
        {
            static if (__traits(compiles, JSONType))
            {
                case JSONType.true_: *value = cast(T) true; break;
                case JSONType.false_: *value = cast(T) false; break;
                case JSONType.integer: *value = cast(T) json.integer; break;
                case JSONType.uinteger: *value = cast(T) json.uinteger; break;
                case JSONType.float_: *value = cast(T) json.floating; break;
            }
            else
            {
                case JSON_TYPE.TRUE: *value = cast(T) true; break;
                case JSON_TYPE.FALSE: *value = cast(T) false; break;
                case JSON_TYPE.INTEGER: *value = cast(T) json.integer; break;
                case JSON_TYPE.UINTEGER: *value = cast(T) json.uinteger; break;
                case JSON_TYPE.FLOAT: *value = cast(T) json.floating; break;
            }
            default:
                Log.Error(
                    "SAVESTATE: invalid json type '%s' for type '%s'",
                    to!string(json.type).toStringz,
                    T.stringof.toStringz
                );
                break;
        }
    }
    //else static assert(false, "Unhandled type " ~ T.stringof);
}

void deserializeInto(T)(T* value, const ref JSONValue json)
if (skipSerialization!T)
{
    // No-op
}

package struct SaveState(Game)
{
    string initialSave;
    string lastSave;

    void initialize(ref Game game)
    {
        initialSave = serializeGameAsText(game);
        lastSave = initialSave;
    }

    JSONValue serializeGame(ref Game game)
    {
        JSONValue[] jsonObjects;
        foreach (o; game.rootObjects)
        {
            jsonObjects ~= JSONValue([
                "type": JSONValue(o.typeName),
                "value": o.serialize(o.object),
            ]);
        }
        return JSONValue(jsonObjects);
    }

    void deserializeGame(ref Game game, const ref JSONValue json)
    {
        game.destroyRemainingObjects();
        foreach (i, o; json.array)
        {
            import gargula.gamenode : createNodeFunctions;
            auto typeName = o["type"].str;
            auto func = createNodeFunctions.get(typeName, null);
            assert(func, "Trying to load state with an unknown type: " ~ typeName);
            auto node = game.addGameNode(func());
            node.deserialize(node.object, o["value"]);
        }
    }

    string serializeGameAsText(ref Game game)
    {
        JSONValue value = serializeGame(game);
        return value.toPrettyString();
    }

    void deserializeGameAsText(ref Game game, string jsonText)
    {
        try
        {
            JSONValue json = parseJSON(jsonText);
            deserializeGame(game, json);
        }
        catch (JSONException ex)
        {
            Log.Error("SAVESTATE: JSON error on load: %s", ex.toString().toStringz);
        }
    }

    void update(ref Game game)
    {
        import std.algorithm : all;
        import gargula.wrapper.raylib : IsKeyDown, IsKeyPressed;

        if (Game.config.debugComboKeys.all!IsKeyDown)
        {
            if (IsKeyPressed(Game.config.debugSaveStateKey))
            {
                lastSave = serializeGameAsText(game);
                Log.Info("SAVESTATE: '%s'", lastSave.toStringz);
            }
            if (IsKeyPressed(Game.config.debugLoadStateKey))
            {
                Log.Info("SAVESTATE: loading '%s'", lastSave.toStringz);
                deserializeGameAsText(game, lastSave);
            }
            if (IsKeyPressed(Game.config.debugReloadKey))
            {
                Log.Info("SAVESTATE: reloading game");
                deserializeGameAsText(game, initialSave);
            }
        }
    }
}

