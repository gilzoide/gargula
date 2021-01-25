module gargula.savestate;

import std.algorithm;
import std.json;
import std.string;
import std.traits;

import flyweightbyid;

import gargula.log : Log;
import gargula.wrapper.raylib;

/// Add this as attribute on fields to be skipped during serialization
enum SkipState;

enum skipSerialization(T) = false
    // TODO: serialize content pointed to?
    || is(T : U*, U)
    // function pointers
    || is(T : U function(Args), U, Args...)
    || is(T : U delegate(Args), U, Args...)
    // raylib resources
    || is(T : Font)
    || is(T : Music)
    || is(T : RenderTexture)
    || is(T : Sound)
    || is(T : Texture)
    || is(T : Wave)
    ;
template skipSerialization(T, string field)
{
    static if (__traits(compiles, __traits(getMember, T, field)))
    {
        alias member = __traits(getMember, T, field);
        enum skipSerialization = .skipSerialization!(typeof(member)) || hasUDA!(member, SkipState);
    }
    else
    {
        // Field is not accessible, skip
        enum skipSerialization = true;
    }
}

JSONValue serialize(T, T init = T.init)(ref T value)
{
    static if (skipSerialization!T)
    {
        JSONValue[string] json;
        return JSONValue(json);
    }
    else static if (__traits(compiles, { JSONValue v = value.toJSON!(T, init); }))
    {
        return value.toJSON!(T, init);
    }
    else static if (__traits(compiles, { JSONValue v = value.toJSON; }))
    {
        return value.toJSON;
    }
    else static if (is(T : U[], U))
    {
        JSONValue[] json = new JSONValue[value.length];
        foreach (i, v; value)
        {
            json[i] = serialize(v);
        }
        return JSONValue(json);
    }
    else static if (is(T == struct) || is(T == class))
    {
        import std.traits : FieldNameTuple;
        JSONValue[string] json;
        static foreach (i, field; FieldNameTuple!T)
        {
            static if (!skipSerialization!(T, field))
            {
                {
                    const auto currentValue = __traits(getMember, value, field);
                    enum initValue = __traits(getMember, init, field);
                    if (currentValue != initValue)
                    {
                        json[field] = currentValue.serialize!(typeof(currentValue), initValue);
                    }
                }
            }
        }
        return JSONValue(json);
    }
    else
    {
        return JSONValue(value);
    }
}

void deserializeInto(T)(T* value, const ref JSONValue json)
{
    if (json.isNull)
    {
        return;
    }

    static if (__traits(compiles, value.fromJSON(json)))
    {
        value.fromJSON(json);
    }
    else static if (is(T : string))
    {
        *value = json.str;
    }
    else static if (is(T : U[], U))
    {
        import std.algorithm : min;
        foreach (i; 0 .. min(json.array.length, value.length))
        {
            deserializeInto!U(&(*value)[i], json.array[i]);
        }
    }
    else static if (is(T == struct) || is(T == class))
    {
        import std.traits : FieldNameTuple;
        static foreach (i, field; FieldNameTuple!T)
        {
            static if (!skipSerialization!(T, field))
            {
                if (field in json.object)
                {
                    deserializeInto(&__traits(getMember, value, field), json.object[field]);
                }
            }
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
}

// Some custom serializations
JSONValue toJSON(T, T init = T.init)(ref T value)
if (is(T : Flyweight!Args, Args...))
{
    enum initObject = init.object;
    return value.object.serialize!(typeof(value.object), initObject)();
}
void fromJSON(Args...)(Flyweight!Args* value, JSONValue json)
{
    deserializeInto(&value.object, json);
}

package struct SaveState(Game)
{
    string initialSave;
    string lastSave;

    void initialize(ref Game game, string initialState)
    {
        if (initialState.length > 0)
        {
            initialSave = initialState;
            Log.Info("SAVESTATE: initializing game state '%s'", initialState);
            deserializeGameAsText(game, initialState);
        }
        else
        {
            initialSave = serializeGameAsText(game);
        }
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
        return value.toPrettyString(JSONOptions.specialFloatLiterals);
    }

    void deserializeGameAsText(ref Game game, string jsonText)
    {
        try
        {
            JSONValue json = parseJSON(jsonText, JSONOptions.specialFloatLiterals);
            deserializeGame(game, json);
        }
        catch (JSONException ex)
        {
            Log.Error("SAVESTATE: JSON error on load: %s", ex.toString());
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
                Log.Info("SAVESTATE: '%s'", lastSave);
            }
            if (IsKeyPressed(Game.config.debugLoadStateKey))
            {
                Log.Info("SAVESTATE: loading '%s'", lastSave);
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

