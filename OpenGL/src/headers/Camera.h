#ifndef CAMERA
#define CAMERA

#include <cmath>

class Camera {
public:
	Camera() {
		position[0] = 0;
		position[1] = 0;
		position[2] = 0;
		heading[0] = 0;
		heading[1] = 0;
	}
	Camera(float x, float y, float z) {
		position[0] = x;
		position[1] = y;
		position[2] = z;
		heading[0] = 0;
		heading[1] = 0;
	}
	Camera(float x, float y, float z, float theta, float phi) {
		position[0] = x;
		position[1] = y;
		position[2] = z;
		heading[0] = theta;
		heading[1] = phi;
	}
	void move(float x, float y, float z) {
		position[0] += x;
		position[1] += y;
		position[2] += z;
	}
	void moveTo(float x, float y, float z) {
		position[0] = x;
		position[1] = y;
		position[2] = z;
	}
	void lookAt(float x, float y, float z) {
		heading[0] = atan2(x - position[0], z - position[2]);
		heading[1] = atan((y - position[1]) / sqrt((x - position[0]) * (x - position[0]) + (z - position[2]) * (z - position[2])));
	}
	void turn(float x, float y) {
		heading[0] += x;
		heading[1] += y;
	}

	void updateGL(unsigned int shader);

private:
	float position[3];
	float heading[2];

};

#endif
