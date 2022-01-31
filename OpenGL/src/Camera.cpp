#include "headers/Camera.h"

#include <GL/glew.h>
#include <GLFW/glfw3.h>
#include <cmath>

using namespace std;

void Camera::updateGL(unsigned int shader) {
	int pos_loc = glGetUniformLocation(shader, "camera_position");
	glUniform3f(pos_loc, position[0], position[1], position[2]);

	int head_loc_x = glGetUniformLocation(shader, "camera_heading_x");
	glUniform3f(head_loc_x, cos(heading[0]), 0, -sin(heading[0]));

	int head_loc_y = glGetUniformLocation(shader, "camera_heading_y");
	glUniform3f(head_loc_y, -sin(heading[1]) * sin(heading[0]), cos(heading[1]), -sin(heading[1]) * cos(heading[0]));

	int head_loc_z = glGetUniformLocation(shader, "camera_heading_z");
	glUniform3f(head_loc_z, sin(heading[0]), sin(heading[1]), cos(heading[0]) * cos(heading[1]));
}