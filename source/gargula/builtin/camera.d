module gargula.builtin.camera;

import gargula.node;
import gargula.wrapper.raylib;

/// Node containing a 2D camera
struct Camera2DNode
{
    /// Camera data
    Camera2D camera;
    alias camera this;

    // Returns camera 2D transform matrix
    Matrix getMatrix()
    {
        return GetCameraMatrix2D(camera);
    }
    
    /// Returns the screen space position for a 2d camera world space position
    Vector2 worldToScreen(Vector2 position)
    {
        return GetWorldToScreen2D(position, camera);
    }
    /// Returns the world space position for a 2d camera screen space position
    Vector2 screenToWorld(Vector2 position)
    {
        return GetScreenToWorld2D(position, camera);
    }

    ///
    void draw()
    {
        BeginMode2D(camera);
    }
    ///
    void lateDraw()
    {
        EndMode2D();
    }
}

/// Node containing a 3D camera
struct Camera3DNode
{
    /// Camera data
    Camera3D camera;
    alias camera this;
    
    /// Returns camera transform matrix (view matrix)
    Matrix getMatrix()
    {
        return GetCameraMatrix(camera);
    }
    
    /// Set camera mode (multiple camera modes available)
    void setMode(int mode)
    {
        SetCameraMode(camera, mode);
    }
    
    /// Returns a ray trace from mouse position
    Ray mouseRay()
    {
        return mouseRay(GetMousePosition());
    }
    /// Ditto
    Ray mouseRay(Vector2 mousePosition)
    {
        return GetMouseRay(mousePosition, camera);
    }
    
    /// Returns the screen space position for a 3d world space position
    Vector2 worldToScreen(Vector3 position)
    {
        return GetWorldToScreen(position, camera);
    }
    /// Returns size position for a 3d world space position
    Vector2 worldToScreen(Vector3 position, int width, int height)
    {
        return GetWorldToScreenEx(position, camera, width, height);
    }

    // Set camera pan key to combine with mouse movement (free camera)
    void setPanControl(int keyPan)
    {
        SetCameraPanControl(keyPan);
    }
    // Set camera alt key to combine with mouse movement (free camera)
    void setAltControl(int keyAlt)
    {
        SetCameraAltControl(keyAlt);
    }
    // Set camera smooth zoom key to combine with mouse (free camera)
    void setSmoothZoomControl(int keySmoothZoom)
    {
        SetCameraSmoothZoomControl(keySmoothZoom);
    }
    // Set camera move controls (1st person and 3rd person cameras)
    void setMoveControls(int keyFront, int keyBack, int keyRight, int keyLeft, int keyUp, int keyDown)
    {
        SetCameraMoveControls(keyFront, keyBack, keyRight, keyLeft, keyUp, keyDown);
    }

    ///
    void draw()
    {
        BeginMode3D(camera);
    }
    ///
    void lateDraw()
    {
        EndMode3D();
    }
    ///
    void update(float _)
    {
        UpdateCamera(&camera);
    }
}
