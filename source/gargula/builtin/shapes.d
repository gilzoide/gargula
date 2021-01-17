module gargula.builtin.shapes;

import gargula.wrapper.raylib;

// 2D shapes

// 3D shapes

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
