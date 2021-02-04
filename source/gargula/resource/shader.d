module gargula.resource.shader;

import betterclist;
import flyweightbyid;

import gargula.node;
import gargula.wrapper.raylib;

enum shaderLocationStartingIndex = LOC_MAP_BRDF + 1;

struct ShaderOptions
{
    string name;
    string vertex = null;
    string fragment = null;

    struct Uniform
    {
        string name;
        int type;

        string dtypename() const
        {
            switch (type)
            {
                case UNIFORM_FLOAT: return "float";
                case UNIFORM_VEC2: return "float[2]";
                case UNIFORM_VEC3: return "float[3]";
                case UNIFORM_VEC4: return "float[4]";
                case UNIFORM_INT: return "int";
                case UNIFORM_IVEC2: return "int[2]";
                case UNIFORM_IVEC3: return "int[3]";
                case UNIFORM_IVEC4: return "int[4]";
                case UNIFORM_SAMPLER2D: return "Texture";
                default: assert(false, "Invalid uniform type value " ~ type.stringof);
            }
        }
    }

    Uniform[] uniforms = [];
}

/// Shader node with draw/lateDraw
struct ShaderNodeTemplate(ShaderOptions[] _options)
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

    // Generate setter properties for uniforms
    static foreach (o; _options)
    {
        static foreach (i, u; o.uniforms)
        {
            static if (u.type == UNIFORM_FLOAT)
            {
                mixin("@property void " ~ u.name ~ "(T : " ~ u.dtypename() ~ ")(const auto ref T value)"
                    ~ "{"
                        ~ "shader.setValue(shader.locs[" ~ (shaderLocationStartingIndex + i).stringof ~ "], value);"
                    ~ "}"
                );
            }
        }
    }
}

alias ShaderNode = ShaderNodeTemplate!([]);

struct ShaderResource(ShaderOptions[] _options)
{
    import std.algorithm : map;
    static immutable options = _options;

    alias ShaderNode = ShaderNodeTemplate!(_options);

    static ShaderNode load(uint id)
    in { assert(id < options.length); }
    do
    {
        immutable option = options[id];
        Shader shader = LoadShader(cast(const char*) option.vertex, cast(const char*) option.fragment);
        ShaderNode node = { shader: shader };
        // Initialize uniform locations
        foreach (i, u; option.uniforms)
        {
            shader.locs[shaderLocationStartingIndex + i] = shader.getLocation(cast(const char*) u.name);
        }
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
    shader.id = T.init.id;
}

/// Get shader uniform location
int getLocation(T : Shader)(ref T shader, const char* uniformName)
{
    return GetShaderLocation(shader, uniformName);
}

/// Get shader attribute location 
int getLocationAttrib(T : Shader)(ref T shader, const char* attribName)
{
    return GetShaderLocationAttrib(shader, attribName);
}

/// Set shader uniform value
void setValue(T : Shader, U)(ref T shader, int uniformLoc, const auto ref U value)
{
    static if (is(U : Matrix))
    {
        SetShaderValueMatrix(shader, uniformLoc, value);
    }
    else static if (is(U : Texture))
    {
        SetShaderValueTexture(shader, uniformLoc, value);
    }
    else static if (is(U == float))
    {
        SetShaderValue(shader, uniformLoc, &value, UNIFORM_FLOAT);
    }
    else static if (is(U : float[N], size_t N))
    {
        SetShaderValueV(shader, uniformLoc, value.ptr, UNIFORM_FLOAT, N);
    }
    else static if (is(U : float[N][M], size_t N, size_t M))
    {
        SetShaderValueV(shader, uniformLoc, value.ptr, UNIFORM_FLOAT, N * M);
    }
    else static if (is(U == int))
    {
        SetShaderValue(shader, uniformLoc, &value, UNIFORM_INT);
    }
    else static if (is(U : int[N], size_t N))
    {
        SetShaderValueV(shader, uniformLoc, value.ptr, UNIFORM_INT, N);
    }
    else static if (is(U : int[N][M], size_t N, size_t M))
    {
        SetShaderValueV(shader, uniformLoc, value.ptr, UNIFORM_INT, N * M);
    }
    else static assert(false, "Invalid uniform value of type " ~ U.stringof);
}
