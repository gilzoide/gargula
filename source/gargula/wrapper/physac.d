/**********************************************************************************************
*
*   Physac v1.1 - 2D Physics library for videogames
*
*   DESCRIPTION:
*
*   Physac is a small 2D physics engine written in pure C. The engine uses a fixed time-step thread loop
*   to simluate physics. A physics step contains the following phases: get collision information,
*   apply dynamics, collision solving and position correction. It uses a very simple struct for physic
*   bodies with a position vector to be used in any 3D rendering API.
*
*   CONFIGURATION:
*
*   #define PHYSAC_IMPLEMENTATION
*       Generates the implementation of the library into the included file.
*       If not defined, the library is in header only mode and can be included in other headers
*       or source files without problems. But only ONE file should hold the implementation.
*
*   #define PHYSAC_STATIC (defined by default)
*       The generated implementation will stay private inside implementation file and all
*       internal symbols and functions will only be visible inside that file.
*
*   #define PHYSAC_DEBUG
*       Show debug traces log messages about physic bodies creation/destruction, physic system errors,
*       some calculations results and NULL reference exceptions
*
*   #define PHYSAC_DEFINE_VECTOR2_TYPE
*       Forces library to define struct Vector2 data type (float x; float y)
*
*   #define PHYSAC_AVOID_TIMMING_SYSTEM
*       Disables internal timming system, used by UpdatePhysics() to launch timmed physic steps,
*       it allows just running UpdatePhysics() automatically on a separate thread at a desired time step.
*       In case physics steps update needs to be controlled by user with a custom timming mechanism,
*       just define this flag and the internal timming mechanism will be avoided, in that case,
*       timming libraries are neither required by the module.
*
*   #define PHYSAC_MALLOC()
*   #define PHYSAC_CALLOC()
*   #define PHYSAC_FREE()
*       You can define your own malloc/free implementation replacing stdlib.h malloc()/free() functions.
*       Otherwise it will include stdlib.h and use the C standard library malloc()/free() function.
*
*   COMPILATION:
*
*   Use the following code to compile with GCC:
*       gcc -o $(NAME_PART).exe $(FILE_NAME) -s -static -lraylib -lopengl32 -lgdi32 -lwinmm -std=c99
*
*   VERSIONS HISTORY:
*       1.1 (20-Jan-2021) @raysan5: Library general revision
*               Removed threading system (up to the user)
*               Support MSVC C++ compilation using CLITERAL()
*               Review DEBUG mechanism for TRACELOG() and all TRACELOG() messages
*               Review internal variables/functions naming for consistency
*               Allow option to avoid internal timming system, to allow app manage the steps
*       1.0 (12-Jun-2017) First release of the library
*
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2016-2021 Victor Fisac (@victorfisac) and Ramon Santamaria (@raysan5)
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

module gargula.wrapper.physac;

import gargula.wrapper.raylib;
extern (C):
@nogc nothrow:

// Functions just visible to module including this file

// Functions visible from other files (no name mangling of functions in C++) // Functions visible from other files

// Allow custom memory allocators

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------
enum PHYSAC_MAX_BODIES = 64; // Maximum number of physic bodies supported
enum PHYSAC_MAX_MANIFOLDS = 4096; // Maximum number of physic bodies interactions (64x64)
enum PHYSAC_MAX_VERTICES = 24; // Maximum number of vertex for polygons shapes
enum PHYSAC_DEFAULT_CIRCLE_VERTICES = 24; // Default number of vertices for circle shapes

enum PHYSAC_COLLISION_ITERATIONS = 100;
enum PHYSAC_PENETRATION_ALLOWANCE = 0.05f;
enum PHYSAC_PENETRATION_CORRECTION = 0.4f;

enum PHYSAC_PI = 3.14159265358979323846;
enum PHYSAC_DEG2RAD = PHYSAC_PI / 180.0f;

//----------------------------------------------------------------------------------
// Data Types Structure Definition
//----------------------------------------------------------------------------------

enum PhysicsShapeType
{
    PHYSICS_CIRCLE = 0,
    PHYSICS_POLYGON = 1
}

alias PHYSICS_CIRCLE = PhysicsShapeType.PHYSICS_CIRCLE;
alias PHYSICS_POLYGON = PhysicsShapeType.PHYSICS_POLYGON;

// Previously defined to be used in PhysicsShape struct as circular dependencies
alias PhysicsBody = PhysicsBodyData_*;

// Vector2 type

// Matrix2x2 type (used for polygon shape rotation matrix)
struct Matrix2x2
{
    float m00;
    float m01;
    float m10;
    float m11;
}

struct PhysicsVertexData
{
    uint vertexCount; // Vertex count (positions and normals)
    Vector2[PHYSAC_MAX_VERTICES] positions; // Vertex positions vectors
    Vector2[PHYSAC_MAX_VERTICES] normals; // Vertex normals vectors
}

struct PhysicsShape
{
    PhysicsShapeType type; // Shape type (circle or polygon)
    PhysicsBody body_; // Shape physics body data pointer
    PhysicsVertexData vertexData; // Shape vertices data (used for polygon shapes)
    float radius; // Shape radius (used for circle shapes)
    Matrix2x2 transform; // Vertices transform matrix 2x2
}

struct PhysicsBodyData_
{
    uint id; // Unique identifier
    bool enabled; // Enabled dynamics state (collisions are calculated anyway)
    Vector2 position; // Physics body shape pivot
    Vector2 velocity; // Current linear velocity applied to position
    Vector2 force; // Current linear force (reset to 0 every step)
    float angularVelocity; // Current angular velocity applied to orient
    float torque; // Current angular force (reset to 0 every step)
    float orient; // Rotation in radians
    float inertia; // Moment of inertia
    float inverseInertia; // Inverse value of inertia
    float mass; // Physics body mass
    float inverseMass; // Inverse value of mass
    float staticFriction; // Friction when the body has not movement (0 to 1)
    float dynamicFriction; // Friction when the body has movement (0 to 1)
    float restitution; // Restitution coefficient of the body (0 to 1)
    bool useGravity; // Apply gravity force to dynamics
    bool isGrounded; // Physics grounded on other body state
    bool freezeOrient; // Physics rotation constraint
    PhysicsShape shape; // Physics body shape information (type, radius, vertices, transform)
}

alias PhysicsBodyData = PhysicsBodyData_;

struct PhysicsManifoldData
{
    uint id; // Unique identifier
    PhysicsBody bodyA; // Manifold first physics body reference
    PhysicsBody bodyB; // Manifold second physics body reference
    float penetration; // Depth of penetration from collision
    Vector2 normal; // Normal direction vector from 'a' to 'b'
    Vector2[2] contacts; // Points of contact during collision
    uint contactsCount; // Current collision number of contacts
    float restitution; // Mixed restitution during collision
    float dynamicFriction; // Mixed dynamic friction during collision
    float staticFriction; // Mixed static friction during collision
}

alias PhysicsManifold = PhysicsManifoldData*;

// Prevents name mangling of functions

//----------------------------------------------------------------------------------
// Module Functions Declaration
//----------------------------------------------------------------------------------
// Physics system management
void InitPhysics (); // Initializes physics system
void UpdatePhysics (); // Update physics system
void ResetPhysics (); // Reset physics system (global variables)
void ClosePhysics (); // Close physics system and unload used memory
void SetPhysicsTimeStep (double delta); // Sets physics fixed time step in milliseconds. 1.666666 by default
void SetPhysicsGravity (float x, float y); // Sets physics global gravity force

// Physic body creation/destroy
PhysicsBody CreatePhysicsBodyCircle (Vector2 pos, float radius, float density); // Creates a new circle physics body with generic parameters
PhysicsBody CreatePhysicsBodyRectangle (Vector2 pos, float width, float height, float density); // Creates a new rectangle physics body with generic parameters
PhysicsBody CreatePhysicsBodyPolygon (Vector2 pos, float radius, int sides, float density); // Creates a new polygon physics body with generic parameters
void DestroyPhysicsBody (PhysicsBody body_); // Destroy a physics body

// Physic body forces
void PhysicsAddForce (PhysicsBody body_, Vector2 force); // Adds a force to a physics body
void PhysicsAddTorque (PhysicsBody body_, float amount); // Adds an angular force to a physics body
void PhysicsShatter (PhysicsBody body_, Vector2 position, float force); // Shatters a polygon shape physics body to little physics bodies with explosion force
void SetPhysicsBodyRotation (PhysicsBody body_, float radians); // Sets physics body shape transform based on radians parameter

// Query physics info
PhysicsBody GetPhysicsBody (int index); // Returns a physics body of the bodies pool at a specific index
int GetPhysicsBodiesCount (); // Returns the current amount of created physics bodies
int GetPhysicsShapeType (int index); // Returns the physics body shape type (PHYSICS_CIRCLE or PHYSICS_POLYGON)
int GetPhysicsShapeVerticesCount (int index); // Returns the amount of vertices of a physics body shape
Vector2 GetPhysicsShapeVertex (PhysicsBody body_, int vertex); // Returns transformed position of a body shape (body position + vertex transformed position)

// PHYSAC_H

/***********************************************************************************
*
*   PHYSAC IMPLEMENTATION
*
************************************************************************************/

// Support TRACELOG macros

// Required for: printf()

// Required for: malloc(), calloc(), free()
// Required for: cosf(), sinf(), fabs(), sqrtf()

// Time management functionality
// Required for: time(), clock_gettime()

// Functions required to query time on Windows

// Required for CLOCK_MONOTONIC if compiled with c99 without gnu ext.

// Required for: timespec
// macOS also defines __MACH__
// Required for: mach_absolute_time()

// NOTE: MSVC C++ compiler does not support compound literals (C99 feature)
// Plain structures in C++ (without constructors) can be initialized from { } initializers.

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------

//----------------------------------------------------------------------------------
// Global Variables Definition
//----------------------------------------------------------------------------------
// Delta time in milliseconds used for physics steps

// Time measure variables
// Offset clock ticks for MONOTONIC clock
// Hi-res clock frequency
// Start time in milliseconds
// Current time in milliseconds

// Physics system configuration
// Physics bodies pointers array
// Physics world current bodies counter
// Physics bodies pointers array
// Physics world current manifolds counter

// Physics world gravity force

// Utilities variables
// Total allocated dynamic memory

//----------------------------------------------------------------------------------
// Module Internal Functions Declaration
//----------------------------------------------------------------------------------

// Timming measure functions
// Initializes hi-resolution MONOTONIC timer
// Get hi-res MONOTONIC time measure in mseconds
// Get current time measure in milliseconds

// Update physics step (dynamics, collisions and position corrections)

// Finds a valid index for a new physics body initialization
// Finds a valid index for a new manifold initialization
// Creates a random polygon shape with max vertex distance from polygon pivot
// Creates a rectangle polygon shape based on a min and max positions

// Initializes physics manifolds to solve collisions
// Creates a new physics manifold to solve collision
// Unitializes and destroys a physics manifold

// Solves a created physics manifold between two physics bodies
// Solves collision between two circle shape physics bodies
// Solves collision between a circle to a polygon shape physics bodies
// Solves collision between a polygon to a circle shape physics bodies
// Solves collision between two polygons shape physics bodies
// Integrates physics forces into velocity
// Integrates physics velocity into position and forces
// Integrates physics collisions impulses to solve collisions
// Corrects physics bodies positions based on manifolds collision information
// Finds two polygon shapes incident face
// Finds polygon shapes axis least penetration

// Math required functions
// Returns the product of a vector and a value
// Returns the cross product of two vectors
// Returns the len square root of a vector
// Returns the dot product of two vectors
// Returns the square root of distance between two vectors
// Returns the normalized values of a vector
// Returns the sum of two given vectors
// Returns the subtract of two given vectors
// Returns a matrix 2x2 from a given radians value
// Returns the transpose of a given matrix 2x2
// Returns product between matrix 2x2 and vector
// Returns clipping value based on a normal and two faces
// Returns the barycenter of a triangle given by 3 points

//----------------------------------------------------------------------------------
// Module Functions Definition
//----------------------------------------------------------------------------------

// Initializes physics values, pointers and creates physics loop thread

// Initialize high resolution timer

// Sets physics global gravity force

// Creates a new circle physics body with generic parameters

// Creates a new rectangle physics body with generic parameters

// NOTE: Make sure body data is initialized to 0

// Initialize new body with generic values

// Calculate centroid and moment of inertia

// Triangle vertices, third vertex implied as (0, 0)

// Use area to weight the centroid average, not just vertex position

// Translate vertices to centroid (make the centroid (0, 0) for the polygon in model space)
// Note: this is not really necessary

// Add new body to bodies pointers array and update bodies count

// Creates a new polygon physics body with generic parameters

// Initialize new body with generic values

// Calculate centroid and moment of inertia

// Triangle vertices, third vertex implied as (0, 0)

// Use area to weight the centroid average, not just vertex position

// Translate vertices to centroid (make the centroid (0, 0) for the polygon in model space)
// Note: this is not really necessary

// Add new body to bodies pointers array and update bodies count

// Adds a force to a physics body

// Adds an angular force to a physics body

// Shatters a polygon shape physics body to little physics bodies with explosion force

// Check collision between each triangle

// Destroy shattered physics body

// Create polygon physics body with relevant values

// Separate vertices to avoid unnecessary physics collisions

// Calculate polygon faces normals

// Apply computed vertex data to new physics body shape

// Calculate centroid and moment of inertia

// Triangle vertices, third vertex implied as (0, 0)

// Use area to weight the centroid average, not just vertex position

// Calculate explosion force direction

// Apply force to new physics body

// Returns the current amount of created physics bodies

// Returns a physics body of the bodies pool at a specific index

// Returns the physics body shape type (PHYSICS_CIRCLE or PHYSICS_POLYGON)

// Returns the amount of vertices of a physics body shape

// Returns transformed position of a body shape (body position + vertex transformed position)

// Sets physics body shape transform based on radians parameter

// Unitializes and destroys a physics body

// Prevent access to index -1

// Free body allocated memory

// Reorder physics bodies pointers array and its catched index

// Update physics bodies count

// Destroys created physics bodies and manifolds and resets global values

// Unitialize physics bodies dynamic memory allocations

// Unitialize physics manifolds dynamic memory allocations

// Unitializes physics pointers and exits physics loop thread

// Unitialize physics manifolds dynamic memory allocations

// Unitialize physics bodies dynamic memory allocations

// Trace log info

//----------------------------------------------------------------------------------
// Module Internal Functions Definition
//----------------------------------------------------------------------------------
// Finds a valid index for a new physics body initialization

// Check if current id already exist in other physics body

// If it is not used, use it as new physics body id

// Creates a default polygon shape with max vertex distance from polygon pivot

// Calculate polygon vertices positions

// Calculate polygon faces normals

// Creates a rectangle polygon shape based on a min and max positions

// Calculate polygon vertices positions

// Calculate polygon faces normals

// Update physics step (dynamics, collisions and position corrections)

// Clear previous generated collisions information

// Reset physics bodies grounded state

// Generate new collision information

// Create a new manifold with same information as previously solved manifold and add it to the manifolds pool last slot

// Integrate forces to physics bodies

// Initialize physics manifolds to solve collisions

// Integrate physics collisions impulses to solve collisions

// Integrate velocity to physics bodies

// Correct physics bodies positions based on manifolds collision information

// Clear physics bodies forces

// Update physics system
// Physics steps are launched at a fixed time step if enabled

// Calculate current time (ms)

// Calculate current delta time (ms)

// Store the time elapsed since the last frame began

// Fixed time stepping loop

// Record the starting of this frame

// Finds a valid index for a new manifold initialization

// Check if current id already exist in other physics body

// If it is not used, use it as new physics body id

// Creates a new physics manifold to solve collision

// Initialize new manifold with generic values

// Add new body to bodies pointers array and update bodies count

// Unitializes and destroys a physics manifold

// Prevent access to index -1

// Free manifold allocated memory

// Reorder physics manifolds pointers array and its catched index

// Update physics manifolds count

// Solves a created physics manifold between two physics bodies

// Update physics body grounded state if normal direction is down and grounded state is not set yet in previous manifolds

// Solves collision between two circle shape physics bodies

// Calculate translational vector, which is normal

// Check if circles are not in contact

// Faster than using MathVector2Normalize() due to sqrt is already performed

// Update physics body grounded state if normal direction is down

// Solves collision between a circle to a polygon shape physics bodies

// Transform circle center to polygon transform space

// Find edge with minimum penetration
// It is the same concept as using support points in SolvePolygonToPolygon

// Grab face's vertices

// Check to see if center is within polygon

// Determine which voronoi region of the edge center of circle lies within

// Closest to v1

// Closest to v2

// Closest to face

// Solves collision between a polygon to a circle shape physics bodies

// Solves collision between two polygons shape physics bodies

// Check for separating axis with A shape's face planes

// Check for separating axis with B shape's face planes

// Always point from A shape to B shape

// Reference
// Incident

// Determine which shape contains reference face
// Checking bias range for penetration

// World space incident face

// Setup reference face vertices

// Transform vertices to world space

// Calculate reference face side normal in world space

// Orthogonalize

// MathVector2Clip incident face to reference face side planes (due to floating point error, possible to not have required points

// Flip normal if required

// Keep points behind reference face
// MathVector2Clipped points behind reference face

// Calculate total penetration average

// Integrates physics forces into velocity

// Initializes physics manifolds to solve collisions

// Calculate average restitution, static and dynamic friction

// Caculate radius from center of mass to contact

// Determine if we should perform a resting collision or not;
// The idea is if the only thing moving this object is gravity, then the collision should be performed without any restitution

// Integrates physics collisions impulses to solve collisions

// Early out and positional correct if both objects have infinite mass

// Calculate radius from center of mass to contact

// Calculate relative velocity

// Relative velocity along the normal

// Do not resolve if velocities are separating

// Calculate impulse scalar value

// Apply impulse to each physics body

// Apply friction impulse to each physics body

// Calculate impulse tangent magnitude

// Don't apply tiny friction impulses

// Apply coulumb's law

// Apply friction impulse

// Integrates physics velocity into position and forces

// Corrects physics bodies positions based on manifolds collision information

// Returns the extreme point along a direction within a polygon

// Finds polygon shapes axis least penetration

//PhysicsVertexData dataB = shapeB.vertexData;

// Retrieve a face normal from A shape

// Transform face normal into B shape's model space

// Retrieve support point from B shape along -n

// Retrieve vertex on face from A shape, transform into B shape's model space

// Compute penetration distance in B shape's model space

// Store greatest distance

// Finds two polygon shapes incident face

// Calculate normal in incident's frame of reference
// To world space
// To incident's model space

// Find most anti-normal face on polygon

// Assign face vertices for incident face

// Returns clipping value based on a normal and two faces

// Retrieve distances from each endpoint to the line

// If negative (behind plane)

// If the points are on different sides of the plane

// Push intersection point

// Assign the new converted values

// Returns the barycenter of a triangle given by 3 points

// Initializes hi-resolution MONOTONIC timer

// Get MONOTONIC clock time offset
// Get current time in milliseconds

// Get hi-res MONOTONIC time measure in clock ticks

// Get current time in milliseconds

// !PHYSAC_AVOID_TIMMING_SYSTEM

// Returns the cross product of a vector and a value

// Returns the cross product of two vectors

// Returns the len square root of a vector

// Returns the dot product of two vectors

// Returns the square root of distance between two vectors

// Returns the normalized values of a vector

// Returns the sum of two given vectors

// Returns the subtract of two given vectors

// Creates a matrix 2x2 from a given radians value

// Returns the transpose of a given matrix 2x2

// Multiplies a vector by a matrix 2x2

// PHYSAC_IMPLEMENTATION
