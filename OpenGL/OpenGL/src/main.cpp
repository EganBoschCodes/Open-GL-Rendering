#include "headers/Constants.h"
#include "headers/Helpers.h"
#include "headers/Camera.h"

#include <Windows.h>
#include <sysinfoapi.h>






using namespace std;




int main(void)
{
	GLFWwindow* window;

	/* Initialize the library */
	if (!glfwInit())
		return -1;

	/* Create a windowed mode window and its OpenGL context */
	window = glfwCreateWindow(WIDTH, HEIGHT, "Ray Marching Tests", NULL, NULL);
	if (!window)
	{
		glfwTerminate();
		return -1;
	}

	/* Make the window's context current */
	glfwMakeContextCurrent(window);

	if (glewInit() != GLEW_OK) {
		cout << "uh oh" << endl;
	}

	cout << "Running on GL Version: " << glGetString(GL_VERSION) << endl;

	long frames = 0;

	Camera cam;
	cam.lookAt(0, 0, 200);

	float positions[8] = {
		-1.0f, -1.0f,
		-1.0f,  1.0f,
		 1.0f,  1.0f,
		 1.0f, -1.0f,
	};

	unsigned int buffer;
	glGenBuffers(1, &buffer);
	glBindBuffer(GL_ARRAY_BUFFER, buffer);
	glBufferData(GL_ARRAY_BUFFER, sizeof(positions), positions, GL_STATIC_DRAW);

	glEnableVertexAttribArray(0);
	glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 2, 0);

	unsigned int shader = CreateShader(loadFile("propervertexshader"), loadFile("screensaver"));
	glUseProgram(shader);
	

	DWORD timeStart = GetTickCount();

	/* Loop until the user closes the window */
	while (!glfwWindowShouldClose(window))
	{
		
		frames++;

		glClear(GL_COLOR_BUFFER_BIT);


		int timeLocation = glGetUniformLocation(shader, "time");
		glUniform1f(timeLocation, (float)GetTickCount());

		int framesLocation = glGetUniformLocation(shader, "frames");
		glUniform1f(framesLocation, frames);

		//UNCOMMENT FOR RAY MARCH
		int ARLocation = glGetUniformLocation(shader, "AspectRatio");
		glUniform1f(ARLocation, (float)(WIDTH)/HEIGHT);

		int zoomLocation = glGetUniformLocation(shader, "zoom");
		glUniform1f(zoomLocation, pow(0.5, ((double)(GetTickCount() - timeStart))/1000));

		double ticks = GetTickCount();

		cam.moveTo(500 * sin(ticks / 1000), 100, 500 * cos(ticks / 1000));

		//cam.moveTo(sin(((float)GetTickCount())/2000)*500, 400, cos(((float)GetTickCount()) / 2000) * 500 + 100);
		cam.lookAt(0, -40, 0);
		cam.updateGL(shader);

		glDrawArrays(GL_QUADS, 0, 4);

		glfwSwapBuffers(window);

		
		glfwPollEvents();


		//while (DO_FPS_CAP && frames / (double)(GetTickCount() - timeStart) * 1000 > FPS_CAP) {}

		if(frames % 1000 == 0)
			cout << frames/(double)(GetTickCount() - timeStart) * 1000 << endl;
	}

	glDeleteProgram(shader);

	glfwTerminate();
	return 0;
}