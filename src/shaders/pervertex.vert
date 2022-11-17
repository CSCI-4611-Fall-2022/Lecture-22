#version 300 es

precision mediump float;

/* Lecture 21
 * CSCI 4611, Fall 2022, University of Minnesota
 * Instructor: Evan Suma Rosenberg <suma@umn.edu>
 * License: Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
 */ 

// The shader will be identical to the Gouraud shader in GopherGfx.

// The uniforms are variables passed in to the shader each frame by the CPU program.
// These are the four matrices needed to convert between coordinate spaces.
uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 normalMatrix;

// These are the material reflection co-efficients (the Ks in the lighting equation)
uniform vec3 kAmbient;
uniform vec3 kDiffuse;
uniform vec3 kSpecular;

// Information about the lights in the scene are passed to the shader in an array.
// The light intensities are the Is in the lighting equation.
const int MAX_LIGHTS = 8;
uniform int numLights;
uniform vec3 ambientIntensities[MAX_LIGHTS];
uniform vec3 diffuseIntensities[MAX_LIGHTS];
uniform vec3 specularIntensities[MAX_LIGHTS];

// The light positions are defined in world space.
uniform vec3 lightPositions[MAX_LIGHTS];

// This shader supports point and directional lights.  The only difference between
// them is the computation of the L vector in the lighting equation.
#define POINT_LIGHT 0
#define DIRECTIONAL_LIGHT 1
uniform int lightTypes[MAX_LIGHTS];

// The inputs are the data for this vertex in a GPU memory buffer.
in vec3 position;
in vec3 normal;
in vec4 color;
in vec2 texCoord;

// The outputs are the data that will be interpolated by the rasterizer and then
// passed as inputs to the fragment shader.
out vec4 vertColor;
out vec2 uv;

void main()
{
    // This line of code computes the vertex position in world coordinates.
    // We will need it to compute the L vector in the lighting equation.
    // Because position is a vec3, we have to convert to a vec4 before it
    // can be multipled by the model matrix. Recall that points in homogenous
    // coordinates are represented as (X,Y,Z,1). We then use "swizzling" to 
    // extract just the XYZ components of the final vector.
    vec3 worldPosition = (modelMatrix * vec4(position, 1)).xyz;

    // This line of code computes the vertex normal in world coordinates.
    // This vector is the N in the lighting equation. We also need to
    // convert to a vec4 before it can be multipled by the normal matrix. 
    // However, note that vectors are represented differently in homogenous 
    // coordinates as (X,Y,Z,0). We then use "swizzling" to extract just
    // the XYZ components of the final vector.
    vec3 worldNormal = (normalMatrix * vec4(normal, 0)).xyz;

    // Make sure to normalize any normals before using them in the lighting
    // equation.  Otherwise, the illumination may have an incorrect scale factor.
    worldNormal = normalize(worldNormal);

    // This variable will be an accumulator for all the light components computed
    // in the lighting equation for all of the lights in the scene.  We start
    // by initializing it to a vec3 of zeros.
    vec3 illumination = vec3(0, 0, 0);

    // We need to loop through every light in the scene and compute the contribution
    // of each one according to the lighting equation.
    for (int i=0; i < numLights; i++)
    {
        // Compute the ambient component: Ka * Ia
        illumination += kAmbient * ambientIntensities[i];

        // Compute the L vector in the lighting equation
        vec3 l;
        if(lightTypes[i] == DIRECTIONAL_LIGHT)
        {
            l = normalize(lightPositions[i]);
        } 
        else
        {
            l = normalize(lightPositions[i] - worldPosition);
        }

        // Compute the value of N dot L.  The max function clamps the value above zero.
        // This is necessary because any lights with a dot product of zero will be behind
        // the surface, and will therefore not contribute any light.  Note that this function
        // expects a floating point value, and it causes an error if you don't use the decimal
        // place because GLSL can't implicitly typecast the integer 0 to a float.
        float ndotl = max(dot(worldNormal, l), 0.0);

        // Compute the diffuse component: Kd * Id * (N dot L)
        illumination += ndotl * kDiffuse * diffuseIntensities[i];
    }

    // Because the vertex color and texture coordinates are computed for each pixel,
    // we need to pass them along to the fragment shader.
    uv = texCoord;
    vertColor = color;

    // Multiply the color computed from the lighting equation into the vertex color.
    // Because illumunation is a vec3, we use "swizzling" to assign just the first
    // three components of the rgba vector.
    vertColor.rgb *= illumination;

    // The vertex shader must always output the 2D position of the vertex in screen
    // coordinates using a special variable called gl_Position. We have already 
    // computed the vertex in world space, so this line of code needs to transform
    // it to eye space and then screen space. Because worldPosition is a vec3, we have 
    // to convert to a vec4 in homogeneous coordinates before matrix multiplication.
    gl_Position = projectionMatrix * viewMatrix * vec4(worldPosition, 1);
}