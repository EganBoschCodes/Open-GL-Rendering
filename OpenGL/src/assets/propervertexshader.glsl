#version 330 core

layout(location = 0) in vec4 position;

out vec4 pos;

uniform float time;

float FOV = 1.5;
uniform float AspectRatio;

void main()
{
	gl_Position = position;
	pos = vec4(position.xy, FOV, AspectRatio);
}