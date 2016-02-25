/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
 Vertex shader that passes attributes through to fragment shader. 
  
 */

attribute vec4 position;
attribute vec2 texCoord;
uniform float preferredRotation;

varying vec2 texCoordVarying;

void main()
{
	mat4 rotationMatrix = mat4( cos(preferredRotation), -sin(preferredRotation), 0.0, 0.0,
							    sin(preferredRotation),  cos(preferredRotation), 0.0, 0.0,
												   0.0,					    0.0, 1.0, 0.0,
												   0.0,					    0.0, 0.0, 1.0);
	gl_Position = position * rotationMatrix;
	texCoordVarying = texCoord;
}

