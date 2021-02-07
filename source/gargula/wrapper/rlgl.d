/**********************************************************************************************
*
*   rlgl v3.1 - raylib OpenGL abstraction layer
*
*   rlgl is a wrapper for multiple OpenGL versions (1.1, 2.1, 3.3 Core, ES 2.0) to
*   pseudo-OpenGL 1.1 style functions (rlVertex, rlTranslate, rlRotate...).
*
*   When chosing an OpenGL version greater than OpenGL 1.1, rlgl stores vertex data on internal
*   VBO buffers (and VAOs if available). It requires calling 3 functions:
*       rlglInit()  - Initialize internal buffers and auxiliar resources
*       rlglDraw()  - Process internal buffers and send required draw calls
*       rlglClose() - De-initialize internal buffers data and other auxiliar resources
*
*   CONFIGURATION:
*
*   #define GRAPHICS_API_OPENGL_11
*   #define GRAPHICS_API_OPENGL_21
*   #define GRAPHICS_API_OPENGL_33
*   #define GRAPHICS_API_OPENGL_ES2
*       Use selected OpenGL graphics backend, should be supported by platform
*       Those preprocessor defines are only used on rlgl module, if OpenGL version is
*       required by any other module, use rlGetVersion() tocheck it
*
*   #define RLGL_IMPLEMENTATION
*       Generates the implementation of the library into the included file.
*       If not defined, the library is in header only mode and can be included in other headers
*       or source files without problems. But only ONE file should hold the implementation.
*
*   #define RLGL_STANDALONE
*       Use rlgl as standalone library (no raylib dependency)
*
*   #define SUPPORT_VR_SIMULATOR
*       Support VR simulation functionality (stereo rendering)
*
*   DEPENDENCIES:
*       raymath     - 3D math functionality (Vector3, Matrix, Quaternion)
*       GLAD        - OpenGL extensions loading (OpenGL 3.3 Core only)
*
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2014-2021 Ramon Santamaria (@raysan5)
*
*   This software is provided "as-is", without any express or implied warranty. In no event
*   will the authors be held liable for any damages arising from the use of this software.
*
*   Permission is granted to anyone to use this software for any purpose, including commercial
*   applications, and to alter it and redistribute it freely, subject to the following restrictions:
*
*     1. The origin of this software must not be misrepresented; you must not claim that you
*     wrote the original software. If you use this software in a product, an acknowledgment
*     in the product documentation would be appreciated but is not required.
*
*     2. Altered source versions must be plainly marked as such, and must not be misrepresented
*     as being the original software.
*
*     3. This notice may not be removed or altered from any source distribution.
*
**********************************************************************************************/

module gargula.wrapper.rlgl;

import gargula.wrapper.raylib;
extern (C):
@nogc nothrow:

// We are building or using rlgl as a static library (or Linux shared library)

// We are building raylib as a Win32 shared library (.dll)

// We are using raylib as a Win32 shared library (.dll)

// Support TRACELOG macros

// Allow custom memory allocators

// Required for: Model, Shader, Texture2D, TRACELOG()

// Required for: Vector3, Matrix

// Security check in case no GRAPHICS_API_OPENGL_* defined

// Security check in case multiple GRAPHICS_API_OPENGL_* defined

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------
// Default internal render batch limits

// This is the maximum amount of elements (quads) per batch
// NOTE: Be careful with text, every letter maps to a quad
enum DEFAULT_BATCH_BUFFER_ELEMENTS = 8192;

// We reduce memory sizes for embedded systems (RPI and HTML5)
// NOTE: On HTML5 (emscripten) this is allocated on heap,
// by default it's only 16MB!...just take care...

enum DEFAULT_BATCH_BUFFERS = 1; // Default number of batch buffers (multi-buffering)

enum DEFAULT_BATCH_DRAWCALLS = 256; // Default number of batch draw calls (by state changes: mode, texture)

enum MAX_BATCH_ACTIVE_TEXTURES = 4; // Maximum number of additional textures that can be activated on batch drawing (SetShaderValueTexture())

// Internal Matrix stack

enum MAX_MATRIX_STACK_SIZE = 32; // Maximum size of Matrix stack

// Shader and material limits

enum MAX_SHADER_LOCATIONS = 32; // Maximum number of shader locations supported

enum MAX_MATERIAL_MAPS = 12; // Maximum number of shader maps supported

// Projection matrix culling

enum RL_CULL_DISTANCE_NEAR = 0.01; // Default near cull distance

enum RL_CULL_DISTANCE_FAR = 1000.0; // Default far cull distance

// Texture parameters (equivalent to OpenGL defines)
enum RL_TEXTURE_WRAP_S = 0x2802; // GL_TEXTURE_WRAP_S
enum RL_TEXTURE_WRAP_T = 0x2803; // GL_TEXTURE_WRAP_T
enum RL_TEXTURE_MAG_FILTER = 0x2800; // GL_TEXTURE_MAG_FILTER
enum RL_TEXTURE_MIN_FILTER = 0x2801; // GL_TEXTURE_MIN_FILTER
enum RL_TEXTURE_ANISOTROPIC_FILTER = 0x3000; // Anisotropic filter (custom identifier)

enum RL_FILTER_NEAREST = 0x2600; // GL_NEAREST
enum RL_FILTER_LINEAR = 0x2601; // GL_LINEAR
enum RL_FILTER_MIP_NEAREST = 0x2700; // GL_NEAREST_MIPMAP_NEAREST
enum RL_FILTER_NEAREST_MIP_LINEAR = 0x2702; // GL_NEAREST_MIPMAP_LINEAR
enum RL_FILTER_LINEAR_MIP_NEAREST = 0x2701; // GL_LINEAR_MIPMAP_NEAREST
enum RL_FILTER_MIP_LINEAR = 0x2703; // GL_LINEAR_MIPMAP_LINEAR

enum RL_WRAP_REPEAT = 0x2901; // GL_REPEAT
enum RL_WRAP_CLAMP = 0x812F; // GL_CLAMP_TO_EDGE
enum RL_WRAP_MIRROR_REPEAT = 0x8370; // GL_MIRRORED_REPEAT
enum RL_WRAP_MIRROR_CLAMP = 0x8742; // GL_MIRROR_CLAMP_EXT

// Matrix modes (equivalent to OpenGL)
enum RL_MODELVIEW = 0x1700; // GL_MODELVIEW
enum RL_PROJECTION = 0x1701; // GL_PROJECTION
enum RL_TEXTURE = 0x1702; // GL_TEXTURE

// Primitive assembly draw modes
enum RL_LINES = 0x0001; // GL_LINES
enum RL_TRIANGLES = 0x0004; // GL_TRIANGLES
enum RL_QUADS = 0x0007; // GL_QUADS

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
enum
{
    OPENGL_11 = 1,
    OPENGL_21 = 2,
    OPENGL_33 = 3,
    OPENGL_ES_20 = 4
}

enum
{
    RL_ATTACHMENT_COLOR_CHANNEL0 = 0,
    RL_ATTACHMENT_COLOR_CHANNEL1 = 1,
    RL_ATTACHMENT_COLOR_CHANNEL2 = 2,
    RL_ATTACHMENT_COLOR_CHANNEL3 = 3,
    RL_ATTACHMENT_COLOR_CHANNEL4 = 4,
    RL_ATTACHMENT_COLOR_CHANNEL5 = 5,
    RL_ATTACHMENT_COLOR_CHANNEL6 = 6,
    RL_ATTACHMENT_COLOR_CHANNEL7 = 7,
    RL_ATTACHMENT_DEPTH = 100,
    RL_ATTACHMENT_STENCIL = 200
}

enum
{
    RL_ATTACHMENT_CUBEMAP_POSITIVE_X = 0,
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_X = 1,
    RL_ATTACHMENT_CUBEMAP_POSITIVE_Y = 2,
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_Y = 3,
    RL_ATTACHMENT_CUBEMAP_POSITIVE_Z = 4,
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_Z = 5,
    RL_ATTACHMENT_TEXTURE2D = 100,
    RL_ATTACHMENT_RENDERBUFFER = 200
}

// Boolean type

// Color type, RGBA (32bit)

// Rectangle type

// Texture type
// NOTE: Data stored in GPU memory

// OpenGL texture id
// Texture base width
// Texture base height
// Mipmap levels, 1 by default
// Data format (PixelFormat)

// Texture2D type, same as Texture

// TextureCubemap type, actually, same as Texture

// Vertex data definning a mesh

// number of vertices stored in arrays
// number of triangles stored (indexed or not)
// vertex position (XYZ - 3 components per vertex) (shader-location = 0)
// vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
// vertex second texture coordinates (useful for lightmaps) (shader-location = 5)
// vertex normals (XYZ - 3 components per vertex) (shader-location = 2)
// vertex tangents (XYZW - 4 components per vertex) (shader-location = 4)
// vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
// vertex indices (in case vertex data comes indexed)

// Animation vertex data
// Animated vertex positions (after bones transformations)
// Animated normals (after bones transformations)
// Vertex bone ids, up to 4 bones influence by vertex (skinning)
// Vertex bone weight, up to 4 bones influence by vertex (skinning)

// OpenGL identifiers
// OpenGL Vertex Array Object id
// OpenGL Vertex Buffer Objects id (7 types of vertex data)

// Shader type (generic)

// Shader program id
// Shader locations array (MAX_SHADER_LOCATIONS)

// Material texture map

// Material map texture
// Material map color
// Material map value

// Material type (generic)

// Material shader
// Material maps (MAX_MATERIAL_MAPS)
// Material generic parameters (if required)

// Camera type, defines a camera position/orientation in 3d space

// Camera position
// Camera target it looks-at
// Camera up vector (rotation over its axis)
// Camera field-of-view apperture in Y (degrees)

// Head-Mounted-Display device parameters

// HMD horizontal resolution in pixels
// HMD vertical resolution in pixels
// HMD horizontal size in meters
// HMD vertical size in meters
// HMD screen center in meters
// HMD distance between eye and display in meters
// HMD lens separation distance in meters
// HMD IPD (distance between pupils) in meters
// HMD lens distortion constant parameters
// HMD chromatic aberration correction parameters

// VR Stereo rendering configuration for simulator

// VR stereo rendering distortion shader
// VR stereo rendering eyes projection matrices
// VR stereo rendering eyes view offset matrices
// VR stereo rendering right eye viewport [x, y, w, h]
// VR stereo rendering left eye viewport [x, y, w, h]

// TraceLog message types

// Texture formats (support depends on OpenGL version)

// 8 bit per pixel (no alpha)

// 16 bpp
// 24 bpp
// 16 bpp (1 bit alpha)
// 16 bpp (4 bit alpha)
// 32 bpp
// 32 bpp (1 channel - float)
// 32*3 bpp (3 channels - float)
// 32*4 bpp (4 channels - float)
// 4 bpp (no alpha)
// 4 bpp (1 bit alpha)
// 8 bpp
// 8 bpp
// 4 bpp
// 4 bpp
// 8 bpp
// 4 bpp
// 4 bpp
// 8 bpp
// 2 bpp

// Texture parameters: filter mode
// NOTE 1: Filtering considers mipmaps if available in the texture
// NOTE 2: Filter is accordingly set for minification and magnification

// No filter, just pixel aproximation
// Linear filtering
// Trilinear filtering (linear with mipmaps)
// Anisotropic filtering 4x
// Anisotropic filtering 8x
// Anisotropic filtering 16x

// Color blending modes (pre-defined)

// Blend textures considering alpha (default)
// Blend textures adding colors
// Blend textures multiplying colors
// Blend textures adding colors (alternative)
// Blend textures subtracting colors (alternative)
// Belnd textures using custom src/dst factors (use SetBlendModeCustom())

// Shader location point type

// LOC_MAP_DIFFUSE
// LOC_MAP_SPECULAR

// Shader uniform data types

// Material map type

// MAP_DIFFUSE
// MAP_SPECULAR

// NOTE: Uses GL_TEXTURE_CUBE_MAP
// NOTE: Uses GL_TEXTURE_CUBE_MAP
// NOTE: Uses GL_TEXTURE_CUBE_MAP

// Prevents name mangling of functions

//------------------------------------------------------------------------------------
// Functions Declaration - Matrix operations
//------------------------------------------------------------------------------------
void rlMatrixMode (int mode); // Choose the current matrix to be transformed
void rlPushMatrix (); // Push the current matrix to stack
void rlPopMatrix (); // Pop lattest inserted matrix from stack
void rlLoadIdentity (); // Reset current matrix to identity matrix
void rlTranslatef (float x, float y, float z); // Multiply the current matrix by a translation matrix
void rlRotatef (float angleDeg, float x, float y, float z); // Multiply the current matrix by a rotation matrix
void rlScalef (float x, float y, float z); // Multiply the current matrix by a scaling matrix
void rlMultMatrixf (float* matf); // Multiply the current matrix by another matrix
void rlFrustum (double left, double right, double bottom, double top, double znear, double zfar);
void rlOrtho (double left, double right, double bottom, double top, double znear, double zfar);
void rlViewport (int x, int y, int width, int height); // Set the viewport area

//------------------------------------------------------------------------------------
// Functions Declaration - Vertex level operations
//------------------------------------------------------------------------------------
void rlBegin (int mode); // Initialize drawing mode (how to organize vertex)
void rlEnd (); // Finish vertex providing
void rlVertex2i (int x, int y); // Define one vertex (position) - 2 int
void rlVertex2f (float x, float y); // Define one vertex (position) - 2 float
void rlVertex3f (float x, float y, float z); // Define one vertex (position) - 3 float
void rlTexCoord2f (float x, float y); // Define one vertex (texture coordinate) - 2 float
void rlNormal3f (float x, float y, float z); // Define one vertex (normal) - 3 float
void rlColor4ub (ubyte r, ubyte g, ubyte b, ubyte a); // Define one vertex (color) - 4 byte
void rlColor3f (float x, float y, float z); // Define one vertex (color) - 3 float
void rlColor4f (float x, float y, float z, float w); // Define one vertex (color) - 4 float

//------------------------------------------------------------------------------------
// Functions Declaration - OpenGL equivalent functions (common to 1.1, 3.3+, ES2)
// NOTE: This functions are used to completely abstract raylib code from OpenGL layer
//------------------------------------------------------------------------------------
void rlEnableTexture (uint id); // Enable texture usage
void rlDisableTexture (); // Disable texture usage
void rlTextureParameters (uint id, int param, int value); // Set texture parameters (filter, wrap)
void rlEnableShader (uint id); // Enable shader program usage
void rlDisableShader (); // Disable shader program usage
void rlEnableFramebuffer (uint id); // Enable render texture (fbo)
void rlDisableFramebuffer (); // Disable render texture (fbo), return to default framebuffer
void rlEnableDepthTest (); // Enable depth test
void rlDisableDepthTest (); // Disable depth test
void rlEnableDepthMask (); // Enable depth write
void rlDisableDepthMask (); // Disable depth write
void rlEnableBackfaceCulling (); // Enable backface culling
void rlDisableBackfaceCulling (); // Disable backface culling
void rlEnableScissorTest (); // Enable scissor test
void rlDisableScissorTest (); // Disable scissor test
void rlScissor (int x, int y, int width, int height); // Scissor test
void rlEnableWireMode (); // Enable wire mode
void rlDisableWireMode (); // Disable wire mode
void rlSetLineWidth (float width); // Set the line drawing width
float rlGetLineWidth (); // Get the line drawing width
void rlEnableSmoothLines (); // Enable line aliasing
void rlDisableSmoothLines (); // Disable line aliasing

void rlClearColor (ubyte r, ubyte g, ubyte b, ubyte a); // Clear color buffer with color
void rlClearScreenBuffers (); // Clear used screen buffers (color and depth)
void rlUpdateBuffer (int bufferId, void* data, int dataSize); // Update GPU buffer with new data
uint rlLoadAttribBuffer (uint vaoId, int shaderLoc, void* buffer, int size, bool dynamic); // Load a new attributes buffer

//------------------------------------------------------------------------------------
// Functions Declaration - rlgl functionality
//------------------------------------------------------------------------------------
void rlglInit (int width, int height); // Initialize rlgl (buffers, shaders, textures, states)
void rlglClose (); // De-inititialize rlgl (buffers, shaders, textures)
void rlglDraw (); // Update and draw default internal buffers
void rlCheckErrors (); // Check and log OpenGL error codes

int rlGetVersion (); // Returns current OpenGL version
bool rlCheckBufferLimit (int vCount); // Check internal buffer overflow for a given number of vertex
void rlSetDebugMarker (const(char)* text); // Set debug marker for analysis
void rlSetBlendMode (int glSrcFactor, int glDstFactor, int glEquation); // // Set blending mode factor and equation (using OpenGL factors)
void rlLoadExtensions (void* loader); // Load OpenGL extensions

// Textures data management
uint rlLoadTexture (void* data, int width, int height, int format, int mipmapCount); // Load texture in GPU
uint rlLoadTextureDepth (int width, int height, bool useRenderBuffer); // Load depth texture/renderbuffer (to be attached to fbo)
uint rlLoadTextureCubemap (void* data, int size, int format); // Load texture cubemap
void rlUpdateTexture (uint id, int offsetX, int offsetY, int width, int height, int format, const(void)* data); // Update GPU texture with new data
void rlGetGlTextureFormats (int format, uint* glInternalFormat, uint* glFormat, uint* glType); // Get OpenGL internal formats
void rlUnloadTexture (uint id); // Unload texture from GPU memory

void rlGenerateMipmaps (Texture2D* texture); // Generate mipmap data for selected texture
void* rlReadTexturePixels (Texture2D texture); // Read texture pixel data
ubyte* rlReadScreenPixels (int width, int height); // Read screen pixel data (color buffer)

// Framebuffer management (fbo)
uint rlLoadFramebuffer (int width, int height); // Load an empty framebuffer
void rlFramebufferAttach (uint fboId, uint texId, int attachType, int texType); // Attach texture/renderbuffer to a framebuffer
bool rlFramebufferComplete (uint id); // Verify framebuffer is complete
void rlUnloadFramebuffer (uint id); // Delete framebuffer from GPU

// Vertex data management
void rlLoadMesh (Mesh* mesh, bool dynamic); // Upload vertex data into GPU and provided VAO/VBO ids
void rlUpdateMesh (Mesh mesh, int buffer, int count); // Update vertex or index data on GPU (upload new data to one buffer)
void rlUpdateMeshAt (Mesh mesh, int buffer, int count, int index); // Update vertex or index data on GPU, at index
void rlDrawMesh (Mesh mesh, Material material, Matrix transform); // Draw a 3d mesh with material and transform
void rlDrawMeshInstanced (Mesh mesh, Material material, Matrix* transforms, int count); // Draw a 3d mesh with material and transform
void rlUnloadMesh (Mesh mesh); // Unload mesh data from CPU and GPU

// NOTE: There is a set of shader related functions that are available to end user,
// to avoid creating function wrappers through core module, they have been directly declared in raylib.h

//------------------------------------------------------------------------------------
// Shaders System Functions (Module: rlgl)
// NOTE: This functions are useless when using OpenGL 1.1
//------------------------------------------------------------------------------------
// Shader loading/unloading functions
// Load shader from files and bind default locations
// Load shader from code strings and bind default locations
// Unload shader from GPU memory (VRAM)

// Get default shader
// Get default texture
// Get texture to draw shapes
// Get texture rectangle to draw shapes

// Shader configuration functions
// Get shader uniform location
// Get shader attribute location
// Set shader uniform value
// Set shader uniform value vector
// Set shader uniform value (matrix 4x4)
// Set a custom projection matrix (replaces internal projection matrix)
// Set a custom modelview matrix (replaces internal modelview matrix)
// Get internal modelview matrix

// Texture maps generation (PBR)
// NOTE: Required shaders should be provided
// Generate cubemap texture from 2D panorama texture
// Generate irradiance texture using cubemap data
// Generate prefilter texture using cubemap data
// Generate BRDF texture using cubemap data

// Shading begin/end functions
// Begin custom shader drawing
// End custom shader drawing (use default shader)
// Begin blending mode (alpha, additive, multiplied)
// End blending mode (reset to default: alpha blending)

// VR control functions
// Init VR simulator for selected device parameters
// Close VR simulator for current device
// Update VR tracking (position and orientation) and camera
// Set stereo rendering configuration parameters
// Detect if VR simulator is ready
// Enable/Disable VR experience
// Begin VR simulator stereo rendering
// End VR simulator stereo rendering

// Load chars array from text file
// Get pixel data size in bytes (image or texture)

// RLGL_H

/***********************************************************************************
*
*   RLGL IMPLEMENTATION
*
************************************************************************************/

// Required for: fopen(), fseek(), fread(), fclose() [LoadFileText]

// Check if config flags have been externally provided on compilation line

// Defines module configuration flags

// Required for: Vector3 and Matrix functions

// Required for: malloc(), free()
// Required for: strcmp(), strlen() [Used in rlglInit(), on extensions loading]
// Required for: atan2f()

// OpenGL 1.1 library for OSX

// APIENTRY for OpenGL function pointer declarations is required

// WINGDIAPI definition. Some Windows OpenGL headers need it

// OpenGL 1.1 library

// OpenGL 2.1 uses mostly OpenGL 3.3 Core functionality

// OpenGL 3 library for OSX
// OpenGL 3 extensions library for OSX

// GLAD extensions loading library, includes OpenGL headers

// GLAD extensions loading library, includes OpenGL headers

// EGL library
// OpenGL ES 2.0 library
// OpenGL ES 2.0 extensions library

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------

// Default shader vertex attribute names to set location points

// Binded by default to shader location: 0

// Binded by default to shader location: 1

// Binded by default to shader location: 2

// Binded by default to shader location: 3

// Binded by default to shader location: 4

// Binded by default to shader location: 5

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------

// Dynamic vertex buffers (position + texcoords + colors + indices arrays)

// Number of elements in the buffer (QUADS)

// Vertex position counter to process (and draw) from full buffer
// Vertex texcoord counter to process (and draw) from full buffer
// Vertex color counter to process (and draw) from full buffer

// Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
// Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
// Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)

// Vertex indices (in case vertex data comes indexed) (6 indices per quad)

// Vertex indices (in case vertex data comes indexed) (6 indices per quad)

// OpenGL Vertex Array Object id
// OpenGL Vertex Buffer Objects id (4 types of vertex data)

// Draw call type
// NOTE: Only texture changes register a new draw, other state-change-related elements are not
// used at this moment (vaoId, shaderId, matrices), raylib just forces a batch draw call if any
// of those state-change happens (this is done in core module)

// Drawing mode: LINES, TRIANGLES, QUADS
// Number of vertex of the draw
// Number of vertex required for index alignment (LINES, TRIANGLES)
//unsigned int vaoId;       // Vertex array id to be used on the draw -> Using RLGL.currentBatch->vertexBuffer.vaoId
//unsigned int shaderId;    // Shader id to be used on the draw -> Using RLGL.currentShader.id
// Texture id to be used on the draw -> Use to create new draw call if changes

//Matrix projection;        // Projection matrix for this draw -> Using RLGL.projection
//Matrix modelview;         // Modelview matrix for this draw -> Using RLGL.modelview

// RenderBatch type

// Number of vertex buffers (multi-buffering support)
// Current buffer tracking in case of multi-buffering
// Dynamic buffer(s) for vertex data

// Draw calls array, depends on textureId
// Draw calls counter
// Current depth value for next draw

// VR Stereo rendering configuration for simulator

// VR stereo rendering distortion shader
// VR stereo rendering eyes projection matrices
// VR stereo rendering eyes view offset matrices
// VR stereo rendering right eye viewport [x, y, w, h]
// VR stereo rendering left eye viewport [x, y, w, h]

// Current render batch
// Default internal render batch

// Current matrix mode
// Current matrix pointer
// Default modelview matrix
// Default projection matrix
// Transform matrix to be used with rlTranslate, rlRotate, rlScale
// Require transform matrix application to current draw-call vertex (if required)
// Matrix stack for push/pop
// Matrix stack counter

// Texture used on shapes drawing (usually a white pixel)
// Texture source rectangle used on shapes drawing
// Default texture used on shapes/poly drawing (required by shader)
// Active texture ids to be enabled on batch drawing (0 active by default)
// Default vertex shader id (used by default shader program)
// Default fragment shader Id (used by default shader program)
// Basic shader, support vertex color and diffuse texture
// Shader to be used on rendering (by default, defaultShader)

// Blending mode active
// Blending source factor
// Blending destination factor
// Blending equation

// Default framebuffer width
// Default framebuffer height

// VAO support (OpenGL ES2 could not support VAO extension)
// NPOT textures full support
// Depth textures supported
// float textures support (32 bit per channel)
// DDS texture compression support
// ETC1 texture compression support
// ETC2/EAC texture compression support
// PVR texture compression support
// ASTC texture compression support
// Clamp mirror wrap mode supported
// Anisotropic texture filtering support
// Debug marker support

// Maximum anisotropy level supported (minimum is 2.0f)
// Maximum bits for depth component

// Extensions supported flags

// VR stereo configuration for simulator
// VR stereo rendering framebuffer id
// VR stereo color texture (attached to framebuffer)
// VR simulator ready flag
// VR stereo rendering enabled/disabled flag

// SUPPORT_VR_SIMULATOR

// GRAPHICS_API_OPENGL_33 || GRAPHICS_API_OPENGL_ES2

//----------------------------------------------------------------------------------
// Global Variables Definition
//----------------------------------------------------------------------------------

// GRAPHICS_API_OPENGL_33 || GRAPHICS_API_OPENGL_ES2

// NOTE: VAO functionality is exposed through extensions (OES)
// Entry point pointer to function glGenVertexArrays()
// Entry point pointer to function glBindVertexArray()
// Entry point pointer to function glDeleteVertexArrays()

//----------------------------------------------------------------------------------
// Module specific Functions Declaration
//----------------------------------------------------------------------------------

// Compile custom shader and return shader id
// Load custom shader program

// Load default shader (just vertex positioning and texture coloring)
// Bind default shader locations (attributes and uniforms)
// Unload default shader

// Load a render batch system
// Unload render batch system
// Draw render batch data (Update->Draw->Reset)
// Set the active render batch for rlgl
// Set default render batch for rlgl
//static bool CheckRenderBatchLimit(RenderBatch batch, int vCount);   // Check render batch vertex buffer limits

// Generate and draw cube
// Generate and draw quad

// Set internal projection and modelview matrix depending on eye

// GRAPHICS_API_OPENGL_33 || GRAPHICS_API_OPENGL_ES2

//----------------------------------------------------------------------------------
// Module Functions Definition - Matrix operations
//----------------------------------------------------------------------------------

// Fallback to OpenGL 1.1 function calls
//---------------------------------------

// Choose the current matrix to be transformed

//else if (mode == RL_TEXTURE) // Not supported

// Push the current matrix into RLGL.State.stack

// Pop lattest inserted matrix from RLGL.State.stack

// Reset current matrix to identity matrix

// Multiply the current matrix by a translation matrix

// NOTE: We transpose matrix with multiplication order

// Multiply the current matrix by a rotation matrix

// NOTE: We transpose matrix with multiplication order

// Multiply the current matrix by a scaling matrix

// NOTE: We transpose matrix with multiplication order

// Multiply the current matrix by another matrix

// Matrix creation from array

// Multiply the current matrix by a perspective matrix generated by parameters

// Multiply the current matrix by an orthographic matrix generated by parameters

// NOTE: If left-right and top-botton values are equal it could create
// a division by zero on MatrixOrtho(), response to it is platform/compiler dependant

// Set the viewport area (transformation from normalized device coordinates to window coordinates)

//----------------------------------------------------------------------------------
// Module Functions Definition - Vertex level operations
//----------------------------------------------------------------------------------

// Fallback to OpenGL 1.1 function calls
//---------------------------------------

// Initialize drawing mode (how to organize vertex)

// Draw mode can be RL_LINES, RL_TRIANGLES and RL_QUADS
// NOTE: In all three cases, vertex are accumulated over default internal vertex buffer

// Make sure current RLGL.currentBatch->draws[i].vertexCount is aligned a multiple of 4,
// that way, following QUADS drawing will keep aligned with index processing
// It implies adding some extra alignment vertex at the end of the draw,
// those vertex are not processed but they are considered as an additional offset
// for the next set of vertex to be drawn

// Finish vertex providing

// Make sure vertexCount is the same for vertices, texcoords, colors and normals
// NOTE: In OpenGL 1.1, one glColor call can be made for all the subsequent glVertex calls

// Make sure colors count match vertex count

// Make sure texcoords count match vertex count

// TODO: Make sure normals count match vertex count... if normals support is added in a future... :P

// NOTE: Depth increment is dependant on rlOrtho(): z-near and z-far values,
// as well as depth buffer bit-depth (16bit or 24bit or 32bit)
// Correct increment formula would be: depthInc = (zfar - znear)/pow(2, bits)

// Verify internal buffers limits
// NOTE: This check is combined with usage of rlCheckBufferLimit()

// WARNING: If we are between rlPushMatrix() and rlPopMatrix() and we need to force a DrawRenderBatch(),
// we need to call rlPopMatrix() before to recover *RLGL.State.currentMatrix (RLGL.State.modelview) for the next forced draw call!
// If we have multiple matrix pushed, it will require "RLGL.State.stackCounter" pops before launching the draw

// Define one vertex (position)
// NOTE: Vertex position data is the basic information required for drawing

// Transform provided vector if required

// Verify that current vertex buffer elements limit has not been reached

// Define one vertex (position)

// Define one vertex (position)

// Define one vertex (texture coordinate)
// NOTE: Texture coordinates are limited to QUADS only

// Define one vertex (normal)
// NOTE: Normals limited to TRIANGLES only?

// TODO: Normals usage...

// Define one vertex (color)

// Define one vertex (color)

// Define one vertex (color)

//----------------------------------------------------------------------------------
// Module Functions Definition - OpenGL equivalent functions (common to 1.1, 3.3+, ES2)
//----------------------------------------------------------------------------------

// Enable texture usage

// Make sure current RLGL.currentBatch->draws[i].vertexCount is aligned a multiple of 4,
// that way, following QUADS drawing will keep aligned with index processing
// It implies adding some extra alignment vertex at the end of the draw,
// those vertex are not processed but they are considered as an additional offset
// for the next set of vertex to be drawn

// Disable texture usage

// NOTE: If quads batch limit is reached,
// we force a draw call and next batch starts

// Set texture parameters (wrap mode/filter mode)

// Enable shader program usage

// Disable shader program usage

// Enable rendering to texture (fbo)

// Disable rendering to texture

// Enable depth test

// Disable depth test

// Enable depth write

// Disable depth write

// Enable backface culling

// Disable backface culling

// Enable scissor test

// Disable scissor test

// Scissor test

// Enable wire mode

// NOTE: glPolygonMode() not available on OpenGL ES

// Disable wire mode

// NOTE: glPolygonMode() not available on OpenGL ES

// Set the line drawing width

// Get the line drawing width

// Enable line aliasing

// Disable line aliasing

// Unload framebuffer from GPU memory
// NOTE: All attached textures/cubemaps/renderbuffers are also deleted

// Query depth attachment to automatically delete texture/renderbuffer

// Bind framebuffer to query depth texture type

// NOTE: If a texture object is deleted while its image is attached to the *currently bound* framebuffer,
// the texture image is automatically detached from the currently bound framebuffer.

// Clear color buffer with color

// Color values clamp to 0.0f(0) and 1.0f(255)

// Clear used screen buffers (color and depth)

// Clear used buffers: Color and Depth (Depth is used for 3D)
//glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);     // Stencil buffer not used...

// Update GPU buffer with new data

//----------------------------------------------------------------------------------
// Module Functions Definition - rlgl Functions
//----------------------------------------------------------------------------------

// Initialize rlgl: OpenGL extensions, default buffers/shaders/textures, OpenGL states

// Check OpenGL information and capabilities
//------------------------------------------------------------------------------
// Print current OpenGL and GLSL version

// NOTE: We can get a bunch of extra information about GPU capabilities (glGet*)
//int maxTexSize;
//glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxTexSize);
//TRACELOG(LOG_INFO, "GL: Maximum texture size: %i", maxTexSize);

//GL_MAX_TEXTURE_IMAGE_UNITS
//GL_MAX_VIEWPORT_DIMS

//int numAuxBuffers;
//glGetIntegerv(GL_AUX_BUFFERS, &numAuxBuffers);
//TRACELOG(LOG_INFO, "GL: Number of aixiliar buffers: %i", numAuxBuffers);

//GLint numComp = 0;
//GLint format[32] = { 0 };
//glGetIntegerv(GL_NUM_COMPRESSED_TEXTURE_FORMATS, &numComp);
//glGetIntegerv(GL_COMPRESSED_TEXTURE_FORMATS, format);
//for (int i = 0; i < numComp; i++) TRACELOG(LOG_INFO, "GL: Supported compressed format: 0x%x", format[i]);

// NOTE: We don't need that much data on screen... right now...

// TODO: Automatize extensions loading using rlLoadExtensions() and GLAD
// Actually, when rlglInit() is called in InitWindow() in core.c,
// OpenGL context has already been created and required extensions loaded

// Get supported extensions list

// NOTE: On OpenGL 3.3 VAO and NPOT are supported by default

// Multiple texture extensions supported by default

// We get a list of available extensions and we check for some of them (compressed textures)
// NOTE: We don't need to check again supported extensions but we do (GLAD already dealt with that)

// Allocate numExt strings pointers

// Get extensions strings

// Allocate 512 strings pointers (2 KB)

// One big const string

// NOTE: We have to duplicate string because glGetString() returns a const string

// NOTE: Duplicated string (extensionsDup) must be deallocated

// Show supported extensions
//for (int i = 0; i < numExt; i++)  TRACELOG(LOG_INFO, "Supported extension: %s", extList[i]);

// Check required extensions

// Check VAO support
// NOTE: Only check on OpenGL ES, OpenGL 3.3 has VAO support as core feature

// The extension is supported by our hardware and driver, try to get related functions pointers
// NOTE: emscripten does not support VAOs natively, it uses emulation and it reduces overall performance...

//glIsVertexArray = (PFNGLISVERTEXARRAYOESPROC)eglGetProcAddress("glIsVertexArrayOES");     // NOTE: Fails in WebGL, omitted

// Check NPOT textures support
// NOTE: Only check on OpenGL ES, OpenGL 3.3 has NPOT textures full support as core feature

// Check texture float support

// Check depth texture support

// DDS texture compression support

// ETC1 texture compression support

// ETC2/EAC texture compression support

// PVR texture compression support

// ASTC texture compression support

// Anisotropic texture filter support

// GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT

// Clamp mirror wrap mode supported

// Debug marker support

// Free extensions pointers

// Duplicated string must be deallocated

// Initialize buffers, default shaders and default textures
//----------------------------------------------------------
// Init default white texture
// 1 pixel RGBA (4 bytes)

// Init default Shader (customized for GL 3.3 and ES2)

// Init default vertex arrays buffers

// Init stack matrices (emulating OpenGL 1.1)

// Init internal matrices

// GRAPHICS_API_OPENGL_33 || GRAPHICS_API_OPENGL_ES2

// Initialize OpenGL default states
//----------------------------------------------------------
// Init state: Depth test
// Type of depth testing to apply
// Disable depth testing for 2D (only used for 3D)

// Init state: Blending mode
// Color blending function (how colors are mixed)
// Enable color blending (required to work with transparencies)

// Init state: Culling
// NOTE: All shapes/models triangles are drawn CCW
// Cull the back face (default)
// Front face are defined counter clockwise (default)
// Enable backface culling

// Init state: Cubemap seamless

// Seamless cubemaps (not supported on OpenGL ES 2.0)

// Init state: Color hints (deprecated in OpenGL 3.0+)
// Improve quality of color and texture coordinate interpolation
// Smooth shading between vertex (vertex colors interpolation)

// Store screen size into global variables

// Init texture and rectangle used on basic shapes drawing

// Init state: Color/Depth buffers clear
// Set clear color (black)
// Set clear depth value (default)
// Clear color and depth buffers (depth buffer required for 3D)

// Vertex Buffer Object deinitialization (memory free)

// Unload default shader
// Unload default texture

// Update and draw internal buffers

// NOTE: Stereo rendering is checked inside

// Check and log OpenGL error codes

// GL_INVALID_ENUM:

//GL_INVALID_VALUE:

//GL_INVALID_OPERATION:

// GL_STACK_OVERFLOW:

// GL_STACK_UNDERFLOW:

// GL_OUT_OF_MEMORY:

// GL_INVALID_FRAMEBUFFER_OPERATION:

// Returns current OpenGL version

// NOTE: Force OpenGL 3.3 on OSX

// Check internal buffer overflow for a given number of vertex

// Set debug marker

// Set blending mode factor and equation

// Load OpenGL extensions
// NOTE: External loader function could be passed as a pointer

// NOTE: glad is generated and contains only required OpenGL 3.3 Core extensions (and lower versions)

// With GLAD, we can check if an extension is supported using the GLAD_GL_xxx booleans
//if (GLAD_GL_ARB_vertex_array_object) // Use GL_ARB_vertex_array_object

// Convert image data to OpenGL texture (returns OpenGL valid Id)

// Free any old binding

// Check texture format support by OpenGL 1.1 (compressed textures not supported)

// GRAPHICS_API_OPENGL_11

// Generate texture id

//glActiveTexture(GL_TEXTURE0);     // If not defined, using GL_TEXTURE0 by default (shader texture)

// Mipmap data offset

// Load the different mipmap levels

// Security check for NPOT textures

// Texture parameters configuration
// NOTE: glTexParameteri does NOT affect texture uploading, just the way it's used

// NOTE: OpenGL ES 2.0 with no GL_OES_texture_npot support (i.e. WebGL) has limited NPOT support, so CLAMP_TO_EDGE must be used

// Set texture to repeat on x-axis
// Set texture to repeat on y-axis

// NOTE: If using negative texture coordinates (LoadOBJ()), it does not work!
// Set texture to clamp on x-axis
// Set texture to clamp on y-axis

// Set texture to repeat on x-axis
// Set texture to repeat on y-axis

// Magnification and minification filters
// Alternative: GL_LINEAR
// Alternative: GL_LINEAR

// Activate Trilinear filtering if mipmaps are available

// At this point we have the texture loaded in GPU and texture parameters configured

// NOTE: If mipmaps were not in data, they are not generated automatically

// Unbind current texture

// Load depth texture/renderbuffer (to be attached to fbo)
// WARNING: OpenGL ES 2.0 requires GL_OES_depth_texture/WEBGL_depth_texture extensions

// In case depth textures not supported, we force renderbuffer usage

// NOTE: We let the implementation to choose the best bit-depth
// Possible formats: GL_DEPTH_COMPONENT16, GL_DEPTH_COMPONENT24, GL_DEPTH_COMPONENT32 and GL_DEPTH_COMPONENT32F

// Create the renderbuffer that will serve as the depth attachment for the framebuffer
// NOTE: A renderbuffer is simpler than a texture and could offer better performance on embedded devices

// Load texture cubemap
// NOTE: Cubemap data is expected to be 6 images in a single data array (one after the other),
// expected the following convention: +X, -X, +Y, -Y, +Z, -Z

// Load cubemap faces

// Instead of using a sized internal texture format (GL_RGB16F, GL_RGB32F), we let the driver to choose the better format for us (GL_RGB)

// Set cubemap texture sampling parameters

// Flag not supported on OpenGL ES 2.0

// Update already loaded texture in GPU with new data
// NOTE: We don't know safely if internal texture format is the expected one...

// Get OpenGL internal formats and data type from raylib PixelFormat

// NOTE: on OpenGL ES 2.0 (WebGL), internalFormat must match format and options allowed are: GL_LUMINANCE, GL_RGB, GL_RGBA

// NOTE: Requires extension OES_texture_float
// NOTE: Requires extension OES_texture_float
// NOTE: Requires extension OES_texture_float

// NOTE: Requires OpenGL ES 2.0 or OpenGL 4.3
// NOTE: Requires OpenGL ES 3.0 or OpenGL 4.3
// NOTE: Requires OpenGL ES 3.0 or OpenGL 4.3
// NOTE: Requires PowerVR GPU
// NOTE: Requires PowerVR GPU
// NOTE: Requires OpenGL ES 3.1 or OpenGL 4.3
// NOTE: Requires OpenGL ES 3.1 or OpenGL 4.3

// Unload texture from GPU memory

// Load a framebuffer to be used for rendering
// NOTE: No textures attached

// Create the framebuffer object
// Unbind any framebuffer

// Attach color buffer texture to an fbo (unloads previous attachment)
// NOTE: Attach type: 0-Color, 1-Depth renderbuffer, 2-Depth texture

// Verify render texture is complete

// Generate mipmap data for selected texture

// Check if texture is power-of-two (POT)

// WARNING: Manual mipmap generation only works for RGBA 32bit textures!

// Retrieve texture data from VRAM

// NOTE: data size is reallocated to fit mipmaps data
// NOTE: CPU mipmap generation only supports RGBA 32bit data

// Load the mipmaps

// Once mipmaps have been generated and data has been uploaded to GPU VRAM, we can discard RAM data

//glHint(GL_GENERATE_MIPMAP_HINT, GL_DONT_CARE);   // Hint for mipmaps generation algorythm: GL_FASTEST, GL_NICEST, GL_DONT_CARE
// Generate mipmaps automatically

// Activate Trilinear filtering for mipmaps

// Upload vertex data into a VAO (if supported) and VBO

// Check if mesh has already been loaded in GPU

// Vertex Array Object
// Vertex positions VBO
// Vertex texcoords VBO
// Vertex normals VBO
// Vertex colors VBO
// Vertex tangents VBO
// Vertex texcoords2 VBO
// Vertex indices VBO

// Initialize Quads VAO (Buffer A)

// NOTE: Attributes must be uploaded considering default locations points

// Enable vertex attributes: position (shader-location = 0)

// Enable vertex attributes: texcoords (shader-location = 1)

// Enable vertex attributes: normals (shader-location = 2)

// Default color vertex attribute set to WHITE

// Default color vertex attribute (shader-location = 3)

// Default color vertex attribute set to WHITE

// Default tangent vertex attribute (shader-location = 4)

// Default tangents vertex attribute

// Default texcoord2 vertex attribute (shader-location = 5)

// Default texcoord2 vertex attribute

// Load a new attributes buffer

// Update vertex or index data on GPU (upload new data to one buffer)

// Update vertex or index data on GPU, at index
// WARNING: error checking is in place that will cause the data to not be
//          updated if offset + size exceeds what the buffer can hold

// Activate mesh VAO

// Update vertices (vertex position)

// Update texcoords (vertex texture coordinates)

// Update normals (vertex normals)

// Update colors (vertex colors)

// Update tangents (vertex tangents)

// Update texcoords2 (vertex second texture coordinates)

// Update indices (triangle index buffer)

// the * 3 is because each triangle has 3 indices

// Unbind the current VAO

// Another option would be using buffer mapping...
//mesh.vertices = glMapBuffer(GL_ARRAY_BUFFER, GL_READ_WRITE);
// Now we can modify vertices
//glUnmapBuffer(GL_ARRAY_BUFFER);

// Draw a 3d mesh with material and transform

// NOTE: On OpenGL 1.1 we use Vertex Arrays to draw model
// Enable vertex array
// Enable texture coords array
// Enable normals array
// Enable colors array

// Pointer to vertex coords array
// Pointer to texture coords array
// Pointer to normals array
// Pointer to colors array

// Disable vertex array
// Disable texture coords array
// Disable normals array
// Disable colors array

// Bind shader program

// Matrices and other values required by shader
//-----------------------------------------------------
// Calculate and send to shader model matrix (used by PBR shader)

// Upload to shader material.colDiffuse

// Upload to shader material.colSpecular (if available)

// At this point the modelview matrix just contains the view matrix (camera)
// That's because BeginMode3D() sets it an no model-drawing function modifies it, all use rlPushMatrix() and rlPopMatrix()
// View matrix (camera)
// Projection matrix (perspective)

// TODO: Consider possible transform matrices in the RLGL.State.stack
// Is this the right order? or should we start with the first stored matrix instead of the last one?
//Matrix matStackTransform = MatrixIdentity();
//for (int i = RLGL.State.stackCounter; i > 0; i--) matStackTransform = MatrixMultiply(RLGL.State.stack[i], matStackTransform);

// Transform to camera-space coordinates

//-----------------------------------------------------

// Bind active texture maps (if available)

// Bind vertex array objects (or VBOs)

// Bind mesh VBO data: vertex position (shader-location = 0)

// Bind mesh VBO data: vertex texcoords (shader-location = 1)

// Bind mesh VBO data: vertex normals (shader-location = 2, if available)

// Bind mesh VBO data: vertex colors (shader-location = 3, if available)

// Set default value for unused attribute
// NOTE: Required when using default shader and no VAO support

// Bind mesh VBO data: vertex tangents (shader-location = 4, if available)

// Bind mesh VBO data: vertex texcoords2 (shader-location = 5, if available)

// Calculate model-view-projection matrix (MVP)
// Transform to screen-space coordinates

// Send combined model-view-projection matrix to shader

// Draw call!
// Indexed vertices draw

// Unbind all binded texture maps

// Set shader active texture

// Unbind current active texture

// Unind vertex array objects (or VBOs)

// Unbind shader program

// Restore RLGL.State.projection/RLGL.State.modelview matrices
// NOTE: In stereo rendering matrices are being modified to fit every eye

// Draw a 3d mesh with material and transform

// Bind shader program

// Upload to shader material.colDiffuse

// Upload to shader material.colSpecular (if available)

// Bind active texture maps (if available)

// Bind vertex array objects (or VBOs)

// At this point the modelview matrix just contains the view matrix (camera)
// For instanced shaders "mvp" is not premultiplied by any instance transform, only RLGL.State.transform

// This could alternatively use a static VBO and either glMapBuffer or glBufferSubData.
// It isn't clear which would be reliably faster in all cases and on all platforms, and
// anecdotally glMapBuffer seems very slow (syncs) while glBufferSubData seems no faster
// since we're transferring all the transform matrices anyway.

// Instances are put in LOC_MATRIX_MODEL attribute location with space for 4x Vector4, eg:
// layout (location = 12) in mat4 instance;

// Draw call!

// Unbind all binded texture maps

// Set shader active texture

// Unbind current active texture

// Unind vertex array objects (or VBOs)

// Unbind shader program

// Unload mesh data from CPU and GPU

// DEFAULT_MESH_VERTEX_BUFFERS (model.c)

// Read screen pixel data (color buffer)

// NOTE 1: glReadPixels returns image flipped vertically -> (0,0) is the bottom left corner of the framebuffer
// NOTE 2: We are getting alpha channel! Be careful, it can be transparent if not cleared properly!

// Flip image vertically!

// Flip line

// Set alpha component value to 255 (no trasparent image retrieval)
// NOTE: Alpha value has already been applied to RGB in framebuffer, we don't need it!

// NOTE: image data should be freed

// Read texture pixel data

// NOTE: Using texture.id, we can retrieve some texture info (but not on OpenGL ES 2.0)
// Possible texture info: GL_TEXTURE_RED_SIZE, GL_TEXTURE_GREEN_SIZE, GL_TEXTURE_BLUE_SIZE, GL_TEXTURE_ALPHA_SIZE
//int width, height, format;
//glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_WIDTH, &width);
//glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_HEIGHT, &height);
//glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_INTERNAL_FORMAT, &format);

// NOTE: Each row written to or read from by OpenGL pixel operations like glGetTexImage are aligned to a 4 byte boundary by default, which may add some padding.
// Use glPixelStorei to modify padding with the GL_[UN]PACK_ALIGNMENT setting.
// GL_PACK_ALIGNMENT affects operations that read from OpenGL memory (glReadPixels, glGetTexImage, etc.)
// GL_UNPACK_ALIGNMENT affects operations that write to OpenGL memory (glTexImage, etc.)

// glGetTexImage() is not available on OpenGL ES 2.0
// Texture2D width and height are required on OpenGL ES 2.0. There is no way to get it from texture id.
// Two possible Options:
// 1 - Bind texture to color fbo attachment and glReadPixels()
// 2 - Create an fbo, activate it, render quad with texture, glReadPixels()
// We are using Option 1, just need to care for texture format on retrieval
// NOTE: This behaviour could be conditioned by graphic driver...

// TODO: Create depth texture/renderbuffer for fbo?

// Attach our texture to FBO

// We read data as RGBA because FBO texture is configured as RGBA, despite binding another texture format

// Clean up temporal fbo

//----------------------------------------------------------------------------------
// Module Functions Definition - Shaders Functions
// NOTE: Those functions are exposed directly to the user in raylib.h
//----------------------------------------------------------------------------------

// Get default internal texture (white texture)

// Get texture to draw shapes (RAII)

// Get texture rectangle to draw shapes

// Define default texture used to draw shapes

// Get default shader

// Load shader from files and bind default locations
// NOTE: If shader string is NULL, using default vertex/fragment shaders

// NOTE: Shader.locs is allocated by LoadShaderCode()

// Load shader from code strings
// NOTE: If shader string is NULL, using default vertex/fragment shaders

// NOTE: All locations must be reseted to -1 (no location)

// Detach shader before deletion to make sure memory is freed

// Detach shader before deletion to make sure memory is freed

// After shader loading, we TRY to set default location names

// Get available shader uniforms
// NOTE: This information is useful for debug...

// Assume no variable names longer than 256

// Get the name of the uniforms

// Unload shader from GPU memory (VRAM)

// Begin custom shader mode

// End custom shader mode (returns to default shader)

// Get shader uniform location

// Get shader attribute location

// Set shader uniform value

// Set shader uniform value vector

//glUseProgram(0);      // Avoid reseting current shader program, in case other uniforms are set

// Set shader uniform value (matrix 4x4)

//glUseProgram(0);

// Set shader uniform value for texture

// Check if texture is already active

// Register a new active texture for the internal batch system
// NOTE: Default texture is always activated as GL_TEXTURE0

// Activate new texture unit
// Save texture id for binding on drawing

//glUseProgram(0);

// Set a custom projection matrix (replaces internal projection matrix)

// Return internal projection matrix

// Set a custom modelview matrix (replaces internal modelview matrix)

// Return internal modelview matrix

// Generate cubemap texture from HDR texture

// Disable backface culling to render inside the cube

// STEP 1: Setup framebuffer
//------------------------------------------------------------------------------------------

// Check if framebuffer is complete with attachments (valid)

//------------------------------------------------------------------------------------------

// STEP 2: Draw to framebuffer
//------------------------------------------------------------------------------------------
// NOTE: Shader is used to convert HDR equirectangular environment map to cubemap equivalent (6 faces)

// Define projection matrix and send it to shader

// Define view matrix for every side of the cubemap

// Set viewport to current fbo dimensions

// WARNING: It must be called after enabling current framebuffer if using internal batch system!

// Using internal batch system instead of raw OpenGL cube creating+drawing
// NOTE: DrawCubeV() is actually provided by models.c! -> GenTextureCubemap() should be moved to user code!

//------------------------------------------------------------------------------------------

// STEP 3: Unload framebuffer and reset state
//------------------------------------------------------------------------------------------
// Unbind shader
// Unbind texture
// Unbind framebuffer
// Unload framebuffer (and automatically attached depth texture/renderbuffer)

// Reset viewport dimensions to default

//rlEnableBackfaceCulling();
//------------------------------------------------------------------------------------------

// Generate irradiance texture using cubemap data

// Disable backface culling to render inside the cube

// STEP 1: Setup framebuffer
//------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------

// STEP 2: Draw to framebuffer
//------------------------------------------------------------------------------------------
// NOTE: Shader is used to solve diffuse integral by convolution to create an irradiance cubemap

// Define projection matrix and send it to shader

// Define view matrix for every side of the cubemap

// Set viewport to current fbo dimensions

//------------------------------------------------------------------------------------------

// STEP 3: Unload framebuffer and reset state
//------------------------------------------------------------------------------------------
// Unbind shader
// Unbind texture
// Unbind framebuffer
// Unload framebuffer (and automatically attached depth texture/renderbuffer)

// Reset viewport dimensions to default

//rlEnableBackfaceCulling();
//------------------------------------------------------------------------------------------

// Generate prefilter texture using cubemap data

// || defined(GRAPHICS_API_OPENGL_ES2)
// Disable backface culling to render inside the cube

// STEP 1: Setup framebuffer
//------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------

// Generate mipmaps for the prefiltered HDR texture

// STEP 2: Draw to framebuffer
//------------------------------------------------------------------------------------------
// NOTE: Shader is used to prefilter HDR and store data into mipmap levels

// Define projection matrix and send it to shader

// Define view matrix for every side of the cubemap

// TODO: Locations should be taken out of this function... too shader dependant...

// Max number of prefilter texture mipmaps

// Resize framebuffer according to mip-level size.

//rlFramebufferAttach(fbo, irradiance.id, RL_ATTACHMENT_COLOR_CHANNEL0, RL_ATTACHMENT_CUBEMAP_POSITIVE_X + i);  // TODO: Support mip levels?

//------------------------------------------------------------------------------------------

// STEP 3: Unload framebuffer and reset state
//------------------------------------------------------------------------------------------
// Unbind shader
// Unbind texture
// Unbind framebuffer
// Unload framebuffer (and automatically attached depth texture/renderbuffer)

// Reset viewport dimensions to default

//rlEnableBackfaceCulling();
//------------------------------------------------------------------------------------------

//prefilter.mipmaps = 1 + (int)floor(log(size)/log(2)); // MAX_MIPMAP_LEVELS
//prefilter.format = UNCOMPRESSED_R32G32B32;

// Generate BRDF texture using cubemap data
// TODO: Review implementation: https://github.com/HectorMF/BRDFGenerator

// STEP 1: Setup framebuffer
//------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------

// STEP 2: Draw to framebuffer
//------------------------------------------------------------------------------------------
// NOTE: Render BRDF LUT into a quad using FBO

//------------------------------------------------------------------------------------------

// STEP 3: Unload framebuffer and reset state
//------------------------------------------------------------------------------------------
// Unbind shader
// Unbind texture
// Unbind framebuffer
// Unload framebuffer (and automatically attached depth texture/renderbuffer)

// Reset viewport dimensions to default

//------------------------------------------------------------------------------------------

// Begin blending mode (alpha, additive, multiplied)
// NOTE: Only 3 blending modes supported, default blend mode is alpha

// End blending mode (reset to default: alpha blending)

// Init VR simulator for selected device parameters
// NOTE: It modifies the global variable: RLGL.Vr.stereoFboId

// Initialize framebuffer and textures for stereo rendering
// NOTE: Screen size should match HMD aspect ratio

// Load color/depth textures to attach to framebuffer

// Attach color texture and depth renderbuffer/texture to FBO

// Update VR tracking (position and orientation) and camera
// NOTE: Camera (position, target, up) gets update with head tracking information

// TODO: Simulate 1st person camera system

// Close VR simulator for current device

// Unload color texture
// Unload stereo framebuffer and depth texture/renderbuffer

// Set stereo rendering configuration parameters

// Reset RLGL.Vr.config for a new values assignment

// Assign distortion shader

// Compute aspect ratio

// Compute lens parameters

// Compute distortion scale parameters
// NOTE: To get lens max radius, lensShift must be normalized to [-1..1]

// Fovy is normally computed with: 2*atan2f(hmd.vScreenSize, 2*hmd.eyeToScreenDistance)
// ...but with lens distortion it is increased (see Oculus SDK Documentation)
//float fovy = 2.0f*atan2f(hmd.vScreenSize*0.5f*distortionScale, hmd.eyeToScreenDistance);     // Really need distortionScale?

// Compute camera projection matrices
// Scaled to projection space coordinates [-1..1]

// Compute camera transformation matrices
// NOTE: Camera movement might seem more natural if we model the head.
// Our axis of rotation is the base of our head, so we might want to add
// some y (base of head to eye level) and -z (center of head to eye protrusion) to the camera positions.

// Compute eyes Viewports

// Update distortion shader with lens and distortion-scale parameters

// Detect if VR simulator is running

// Enable/Disable VR experience (device or simulator)

// Reset viewport and default projection-modelview matrices

// Begin VR drawing configuration

// Setup framebuffer for stereo rendering
//glEnable(GL_FRAMEBUFFER_SRGB);          // Enable SRGB framebuffer (only if required)

//rlViewport(0, 0, buffer.width, buffer.height); // Useful if rendering to separate framebuffers (every eye)
// Clear current framebuffer

// End VR drawing process (and desktop mirror)

// Disable stereo render

// Unbind current framebuffer

// Clear current framebuffer

// Set viewport to default framebuffer size (screen size)

// Let rlgl reconfigure internal matrices
// Enable internal projection matrix
// Reset internal projection matrix
// Recalculate internal RLGL.State.projection matrix
// Enable internal modelview matrix
// Reset internal modelview matrix

// Draw stereo framebuffer texture using distortion shader if available

// Bottom-left corner for texture and quad

// Bottom-right corner for texture and quad

// Top-right corner for texture and quad

// Top-left corner for texture and quad

// Update and draw render texture fbo with distortion to backbuffer

// Restore RLGL.State.defaultShader

// Reset viewport and default projection-modelview matrices

// SUPPORT_VR_SIMULATOR

//----------------------------------------------------------------------------------
// Module specific Functions Definition
//----------------------------------------------------------------------------------

// Compile custom shader and return shader id

// Load custom shader strings and return program id

// NOTE: Default attribute shader locations must be binded before linking

// NOTE: If some attrib name is no found on the shader, it locations becomes -1

// NOTE: All uniform variables are intitialised to 0 when a program links

// Load default shader (just vertex positioning and texture coloring)
// NOTE: This shader program is used for internal buffers

// NOTE: All locations must be reseted to -1 (no location)

// Vertex shader directly defined, no external file required

// Fragment shader directly defined, no external file required

// precision required for OpenGL ES2 (WebGL)

// NOTE: texture2D() is deprecated on OpenGL 3.3 and ES 3.0

// NOTE: Compiled vertex/fragment shaders are kept for re-use
// Compile default vertex shader
// Compile default fragment shader

// Set default shader locations: attributes locations

// Set default shader locations: uniform locations

// NOTE: We could also use below function but in case DEFAULT_ATTRIB_* points are
// changed for external custom shaders, we just use direct bindings above
//SetShaderDefaultLocations(&shader);

// Get location handlers to for shader attributes and uniforms
// NOTE: If any location is not found, loc point becomes -1

// NOTE: Default shader attrib locations have been fixed before linking:
//          vertex position location    = 0
//          vertex texcoord location    = 1
//          vertex normal location      = 2
//          vertex color location       = 3
//          vertex tangent location     = 4
//          vertex texcoord2 location   = 5

// Get handles to GLSL input attibute locations

// Get handles to GLSL uniform locations (vertex shader)

// Get handles to GLSL uniform locations (fragment shader)

// Unload default shader

// Load render batch

// Initialize CPU (RAM) vertex buffers (position, texcoord, color data and indexes)
//--------------------------------------------------------------------------------------------

// 3 float by vertex, 4 vertex by quad
// 2 float by texcoord, 4 texcoord by quad
// 4 float by color, 4 colors by quad

// 6 int by quad (indices)

// 6 int by quad (indices)

// Indices can be initialized right now

//--------------------------------------------------------------------------------------------

// Upload to GPU (VRAM) vertex data and initialize VAOs/VBOs
//--------------------------------------------------------------------------------------------

// Initialize Quads VAO

// Quads - Vertex buffers binding and attributes enable
// Vertex position buffer (shader-location = 0)

// Vertex texcoord buffer (shader-location = 1)

// Vertex color buffer (shader-location = 3)

// Fill index buffer

// Unbind the current VAO

//--------------------------------------------------------------------------------------------

// Init draw calls tracking system
//--------------------------------------------------------------------------------------------

//batch.draws[i].vaoId = 0;
//batch.draws[i].shaderId = 0;

//batch.draws[i].RLGL.State.projection = MatrixIdentity();
//batch.draws[i].RLGL.State.modelview = MatrixIdentity();

// Record buffer count
// Reset draws counter
// Reset depth value
//--------------------------------------------------------------------------------------------

// Draw render batch
// NOTE: We require a pointer to reset batch and increase current buffer (multi-buffer)

// Update batch vertex buffers
//------------------------------------------------------------------------------------------------------------
// NOTE: If there is not vertex data, buffers doesn't need to be updated (vertexCount > 0)
// TODO: If no data changed on the CPU arrays --> No need to re-update GPU arrays (change flag required)

// Activate elements VAO

// Vertex positions buffer

//glBufferData(GL_ARRAY_BUFFER, sizeof(float)*3*4*batch->vertexBuffer[batch->currentBuffer].elementsCount, batch->vertexBuffer[batch->currentBuffer].vertices, GL_DYNAMIC_DRAW);  // Update all buffer

// Texture coordinates buffer

//glBufferData(GL_ARRAY_BUFFER, sizeof(float)*2*4*batch->vertexBuffer[batch->currentBuffer].elementsCount, batch->vertexBuffer[batch->currentBuffer].texcoords, GL_DYNAMIC_DRAW); // Update all buffer

// Colors buffer

//glBufferData(GL_ARRAY_BUFFER, sizeof(float)*4*4*batch->vertexBuffer[batch->currentBuffer].elementsCount, batch->vertexBuffer[batch->currentBuffer].colors, GL_DYNAMIC_DRAW);    // Update all buffer

// NOTE: glMapBuffer() causes sync issue.
// If GPU is working with this buffer, glMapBuffer() will wait(stall) until GPU to finish its job.
// To avoid waiting (idle), you can call first glBufferData() with NULL pointer before glMapBuffer().
// If you do that, the previous data in PBO will be discarded and glMapBuffer() returns a new
// allocated pointer immediately even if GPU is still working with the previous data.

// Another option: map the buffer object into client's memory
// Probably this code could be moved somewhere else...
// batch->vertexBuffer[batch->currentBuffer].vertices = (float *)glMapBuffer(GL_ARRAY_BUFFER, GL_READ_WRITE);
// if (batch->vertexBuffer[batch->currentBuffer].vertices)
// {
// Update vertex data
// }
// glUnmapBuffer(GL_ARRAY_BUFFER);

// Unbind the current VAO

//------------------------------------------------------------------------------------------------------------

// Draw batch vertex buffers (considering VR stereo if required)
//------------------------------------------------------------------------------------------------------------

// Draw buffers

// Set current shader and upload current MVP matrix

// Create modelview-projection matrix and upload to shader

// Bind vertex attrib: position (shader-location = 0)

// Bind vertex attrib: texcoord (shader-location = 1)

// Bind vertex attrib: color (shader-location = 3)

// Setup some default shader values

// Active default sampler2D: texture0

// Activate additional sampler textures
// Those additional textures will be common for all draw calls of the batch

// Activate default sampler2D texture0 (one texture is always active for default batch shader)
// NOTE: Batch system accumulates calls by texture0 changes, additional textures are enabled for all the draw calls

// Bind current draw call texture, activated as GL_TEXTURE0 and binded to sampler2D texture0 by default

// We need to define the number of indices to be processed: quadsCount*6
// NOTE: The final parameter tells the GPU the offset in bytes from the
// start of the index buffer to the location of the first index to process

// Unbind textures

// Unbind VAO

// Unbind shader program

//------------------------------------------------------------------------------------------------------------

// Reset batch buffers
//------------------------------------------------------------------------------------------------------------
// Reset vertex counters for next frame

// Reset depth for next draw

// Restore projection/modelview matrices

// Reset RLGL.currentBatch->draws array

// Reset active texture units for next batch

// Reset draws counter to one draw for the batch

//------------------------------------------------------------------------------------------------------------

// Change to next buffer in the list (in case of multi-buffering)

// Unload default internal buffers vertex data from CPU and GPU

// Unbind everything

// Unload all vertex buffers data

// Delete VBOs from GPU (VRAM)

// Delete VAOs from GPU (VRAM)

// Free vertex arrays memory from CPU (RAM)

// Unload arrays

// Set the active render batch for rlgl

// Set default render batch for rlgl

// Renders a 1x1 XY quad in NDC

// Positions         Texcoords

// Gen VAO to contain VBO

// Gen and fill vertex buffer (VBO)

// Bind vertex attributes (position, texcoords)

// Positions

// Texcoords

// Draw quad

// Delete buffers (VBO and VAO)

// Renders a 1x1 3D cube in NDC

// Positions          Normals               Texcoords

// Gen VAO to contain VBO

// Gen and fill vertex buffer (VBO)

// Bind vertex attributes (position, normals, texcoords)

// Positions

// Normals

// Texcoords

// Draw cube

// Delete VBO and VAO

// Set internal projection and modelview matrix depending on eyes tracking data

// Setup viewport and projection/modelview matrices using tracking data

// Apply view offset to modelview matrix

// Set current eye projection matrix

// SUPPORT_VR_SIMULATOR

// GRAPHICS_API_OPENGL_33 || GRAPHICS_API_OPENGL_ES2

// Mipmaps data is generated after image data
// NOTE: Only works with RGBA (4 bytes) data!

// Required mipmap levels count (including base level)

// Size in bytes (will include mipmaps...), RGBA only

// Count mipmap levels required

// Add mipmap size (in bytes)

// Generate mipmaps
// NOTE: Every mipmap data is stored after data

// Size of last mipmap

// Mipmap size to store after offset

// Add mipmap to data

// free mipmap data

// Manual mipmap generation (basic scaling algorithm)

// Scaling algorithm works perfectly (box-filter)

// Load text data from file, returns a '\0' terminated string
// NOTE: text chars array should be freed manually

// WARNING: When reading a file as 'text' file,
// text mode causes carriage return-linefeed translation...
// ...but using fseek() should return correct byte-offset

// WARNING: \r\n is converted to \n on reading, so,
// read bytes count gets reduced by the number of lines

// Zero-terminate the string

// Get pixel data size in bytes (image or texture)
// NOTE: Size depends on pixel format

// Size in bytes
// Bits per pixel

// Total data size in bytes

// Most compressed formats works on 4x4 blocks,
// if texture is smaller, minimum dataSize is 8 or 16

// RLGL_STANDALONE

// RLGL_IMPLEMENTATION
