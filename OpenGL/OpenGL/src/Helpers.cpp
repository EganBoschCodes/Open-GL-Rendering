#include "headers/Constants.h"
#include "headers/Helpers.h"
#include <fstream>

using namespace std;

unsigned int CompileShader(unsigned int type, const string& source)
{
	unsigned int id = glCreateShader(type);
	const char* src = source.c_str();
	glShaderSource(id, 1, &src, nullptr);
	glCompileShader(id);

	int result;
	glGetShaderiv(id, GL_COMPILE_STATUS, &result);
	if (result == GL_FALSE) {
		int length;
		glGetShaderiv(id, GL_INFO_LOG_LENGTH, &length);
		char* message = (char*)alloca(length * sizeof(char));
		glGetShaderInfoLog(id, length, &length, message);
		cout << "Failed on compilation of " << (type == GL_VERTEX_SHADER ? "Vertex" : "Fragment") << " shader!" << endl << message << endl;
		glDeleteShader(id);
		return 0;
	}

	return id;
}

unsigned int CreateShader(const string& vertexShader, const string fragmentShader)
{
	unsigned int program = glCreateProgram();
	unsigned int vs = CompileShader(GL_VERTEX_SHADER, vertexShader);
	unsigned int fs = CompileShader(GL_FRAGMENT_SHADER, fragmentShader);

	glAttachShader(program, vs);
	glAttachShader(program, fs);
	glLinkProgram(program);
	glValidateProgram(program);

	glDeleteShader(vs);
	glDeleteShader(fs);

	return program;
}

string loadFile(string address) {

	string result = "";

	ifstream inFile;
	inFile.open("src\\assets\\" + address + ".glsl");

	if (!inFile) {
		cerr << "Unable to open file " << address << ".glsl";
		exit(1);   // call system to stop
	}
	string line;
	while (getline(inFile, line)) {
		result = result + line + "\n";
	}
	return result;
}



