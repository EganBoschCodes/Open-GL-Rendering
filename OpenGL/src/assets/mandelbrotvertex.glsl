#version 400 core

layout(location = 0) in vec4 position;

out vec2 pos;

uniform float time;

float FOV = 1.5;
uniform float zoom;


void main()
{
	gl_Position = position;
	pos = vec2((position.x * 1920 / 1000 - 0.5) * zoom + -1.2553147581206017 * (1 - zoom), (position.y * 1080 / 1000) * zoom + -0.38219839880487066 * (1 - zoom));
}