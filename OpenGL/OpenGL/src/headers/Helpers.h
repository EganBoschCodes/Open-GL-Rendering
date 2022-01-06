#ifndef HELPERS
#define HELPERS

#include <GL/glew.h>
#include <GLFW/glfw3.h>
#include <iostream>
#include <string>
#include "Constants.h"

using namespace std;



string loadFile(string address);

unsigned int CompileShader(unsigned int type, const string& source);

unsigned int CreateShader(const string& vertexShader, const string fragmentShader);

#endif