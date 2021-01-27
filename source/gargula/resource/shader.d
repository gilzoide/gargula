module gargula.resource.shader;

import gargula.wrapper.raylib;

struct ShaderOptions
{
    string name;
    string vertex = "";
    string fragment = "";
}

struct ShaderResource(ShaderOptions[] _options)
{
    import std.algorithm : map;
    static immutable options = _options;

    Shader load(uint id)
    in { assert(id < options.length); }
    do
    {
        immutable option = options[id];
        return LoadShaderCode(option.vertex, option.fragment);
    }

    alias Flyweight = .Flyweight!(
        Shader,
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
