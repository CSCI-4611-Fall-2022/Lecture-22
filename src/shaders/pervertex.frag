#version 300 es

precision mediump float;

/* Lecture 21
 * CSCI 4611, Fall 2022, University of Minnesota
 * Instructor: Evan Suma Rosenberg <suma@umn.edu>
 * License: Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
 */ 

// The shader will be identical to the Gouraud shader in GopherGfx.

// The uniforms are variables passed in to the shader each frame by the CPU program.
// If the material does not include a texture, then useTexture will be set to 0.
// Otherwise, it will be set to 1, and the image will be passed to the shader.
uniform int useTexture;
uniform sampler2D textureImage;

// The inputs to the fragment shader must match the outputs from the vertex shader.
// Because each pixel lies inside a triangle defined by three vertices, each of these
// outputs has already been interpolated into a single blended value.
in vec4 vertColor;
in vec2 uv;

// A fragment shader can only have one output, which is the color of the pixel.
out vec4 fragColor;

void main()
{
    // We set the fragment color using the interpolated color from the vertices
    fragColor = vertColor;

    // If the material includes a texture image, we use the texture() function to 
    // look up the pixel color at a specified texture coordinate. This color is then 
    // multiplied into the output fragment color.
    if(useTexture != 0)
    {
        
        fragColor *= texture(textureImage, uv);
    }
}