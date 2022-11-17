#version 300 es

precision mediump float;

/* Lecture 21
 * CSCI 4611, Fall 2022, University of Minnesota
 * Instructor: Evan Suma Rosenberg <suma@umn.edu>
 * License: Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
 */ 

// The shader will be identical to the unlit shader in GopherGfx.

// The uniforms are variables passed in to the shader each frame by the CPU program.
// These are the four matrices needed to convert between coordinate spaces.
// The modelView matrix is a pre-computed combination of the model and view matrices.
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

// The inputs are the data for this vertex in a GPU memory buffer.
in vec3 position;
in vec4 color;
in vec2 texCoord;

// The outputs are the data that will be interpolated by the rasterizer and then
// passed as inputs to the fragment shader.
out vec4 vertColor;
out vec2 uv;

void main()
{
    // Because the vertex color and texture coordinates are computed for each pixel,
    // we don't do anything here.  We just pass them along to the fragment shader.
    vertColor = color;
    uv = texCoord;

    // The vertex shader must always output the 2D position of the vertex in screen
    // coordinates using a special variable called gl_Position. This line of code
    // transforms the vertex position (in object space) to eye space and then
    // screen space. Because position is a vec3, we have to convert to a vec4 in 
    // homogeneous coordinates before matrix multiplication.
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1);
}