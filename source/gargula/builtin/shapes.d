module gargula.builtin.shapes;

import gargula.wrapper.raylib;

// 2D shapes

// 3D shapes

/// Draw a cube
struct CubeNode
{
    /// Cube position
    Vector3 position = 0;
    /// Cube size
    Vector3 size = 1;

    /// Color
    Color color = WHITE;
    /// Whether to draw wireframe
    bool wires = false;

    BoundingBox boundingBox() const
    {
        BoundingBox result;
        result.origin = position;
        result.size = size;
        return result;
    }
    
    ///
    void draw()
    {
        if (wires)
        {
            DrawCubeV(position, size, color);
        }
        else
        {
            DrawCubeWiresV(position, size, color);
        }
    }
}

/// Draw a sphere
struct SphereNode
{
    /// Sphere center position
    Vector3 position;
    /// Radius
    float radius = 1;
    /// Color
    Color color = WHITE;

    /// Number of rings
    int rings = 16;
    /// Number of slices
    int slices = 16;
    /// Whether to draw wireframe
    bool wires = false;

    ///
    void draw()
    {
        if (wires)
        {
            DrawSphereWires(position, radius, rings, slices, color);
        }
        else
        {
            DrawSphereEx(position, radius, rings, slices, color);
        }
    }
}
