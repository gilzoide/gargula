module gargula.resource.shader;

import betterclist;
import flyweightbyid;

import gargula.node;
import gargula.wrapper.raylib;

struct ShaderOptions
{
    string name;
    string vertex = null;
    string fragment = null;
}

/// Shader node with draw/lateDraw
struct ShaderNode
{
    mixin Node;

    /// Shader data.
    Shader shader;
    alias shader this;

    ///
    void draw()
    {
        BeginShaderMode(shader);
    }
    ///
    void lateDraw()
    {
        EndShaderMode();
    }
}

struct ShaderResource(ShaderOptions[] _options)
{
    import std.algorithm : map;
    static immutable options = _options;

    static ShaderNode load(uint id)
    in { assert(id < options.length); }
    do
    {
        immutable option = options[id];
        Shader shader = LoadShader(cast(const char*) option.vertex, cast(const char*) option.fragment);
        ShaderNode node = { shader: shader };
        return node;
    }

    alias Flyweight = .Flyweight!(
        ShaderNode,
        load,
        unload!Shader,
        list!(_options[].map!"a.name"),
        FlyweightOptions.gshared
    );
}

/// Unload shader from GPU memory (VRAM)
void unload(T : Shader)(ref T shader)
{
    UnloadShader(shader);
    shader = T.init;
}
