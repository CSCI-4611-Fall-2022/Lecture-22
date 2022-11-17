#version 300 es

precision mediump float;

/* Lecture 21
 * CSCI 4611, Fall 2022, University of Minnesota
 * Instructor: Evan Suma Rosenberg <suma@umn.edu>
 * License: Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
 */ 

// The shader will be identical to the Gouraud shader in GopherGfx.

// The uniforms are variables passed in to the shader each frame by the CPU program.
// These are the material reflection co-efficients (the Ks in the lighting equation)
uniform vec3 kAmbient;
uniform vec3 kDiffuse;
uniform vec3 kSpecular;

uniform float shininess;
uniform vec3 eyePosition;

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

// If the material does not include a texture, then useTexture will be set to 0.
// Otherwise, it will be set to 1, and the image will be passed to the shader.
uniform int useTexture;
uniform sampler2D textureImage;

// The inputs to the fragment shader must match the outputs from the vertex shader.
// Because each pixel lies inside a triangle defined by three vertices, each of these
// outputs has already been interpolated into a single blended value.
in vec3 worldPosition;
in vec3 worldNormal;
in vec4 vertColor;
in vec2 uv;

// A fragment shader can only have one output, which is the color of the pixel.
out vec4 fragColor;

void main()
{
    vec3 n = normalize(worldNormal);

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
        float ndotl = max(dot(n, l), 0.0);

        // Compute the diffuse component: Kd * Id * (N dot L)
        illumination += ndotl * kDiffuse * diffuseIntensities[i];

        vec3 e = normalize(eyePosition - worldPosition);

        vec3 r = reflect(l, n);

        float edotr = max(dot(e, -r), 0.0);

        illumination += pow(edotr, shininess) * kSpecular * specularIntensities[i];
    }

    // We set the fragment color using the interpolated color from the vertices
    fragColor = vertColor;

    fragColor.rgb *= illumination;

    // If the material includes a texture image, we use the texture() function to 
    // look up the pixel color at a specified texture coordinate. This color is then 
    // multiplied into the output fragment color.
    if(useTexture != 0)
    {
        
        fragColor *= texture(textureImage, uv);
    }
}