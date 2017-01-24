module shader;

import std.stdio;
import std.file;
import std.string;

import std.experimental.logger;

import derelict.opengl3.gl3;

GLuint LoadShader(string vertexFilePath, string fragmentFilePath)
{
	string vertexShaderCode = readText(vertexFilePath);
	string fragmentShaderCode = readText(fragmentFilePath);

	// Create the shaders
	GLuint vertexShaderID = CompileProgram!(GL_VERTEX_SHADER)(vertexFilePath, vertexShaderCode);
	GLuint fragmentShaderID = CompileProgram!(GL_FRAGMENT_SHADER)(fragmentFilePath, fragmentShaderCode);

	return LinkProgram(vertexShaderID, fragmentShaderID);
}

GLuint CompileProgram(alias GLenum ShaderType)(lazy string programName, string program)
if(validShaderType(ShaderType))
{
	GLuint ShaderID = glCreateShader(ShaderType);
	GLint Result = GL_FALSE;
	int InfoLogLength;

	// Compile Shader
	auto SourcePointer = program.toStringz();
	glShaderSource(ShaderID, 1, &SourcePointer , null);
	glCompileShader(ShaderID);

	// Check Shader
	glGetShaderiv(ShaderID, GL_COMPILE_STATUS, &Result);
	glGetShaderiv(ShaderID, GL_INFO_LOG_LENGTH, &InfoLogLength);
	if ( InfoLogLength > 0 ){
		GLchar[] ShaderErrorMessage;
		ShaderErrorMessage.length = InfoLogLength;
		glGetShaderInfoLog(ShaderID, InfoLogLength, null, &ShaderErrorMessage[0]);
		errorf("Error in shader '%s':\n%s", programName(), ShaderErrorMessage);
	}
	return ShaderID;
}


GLuint LinkProgram(GLuint vertex, GLuint fragment)
{
	GLint Result = GL_FALSE;
	int InfoLogLength;
	// Link the program
	GLuint ProgramID = glCreateProgram();
	glAttachShader(ProgramID, vertex);
	glAttachShader(ProgramID, fragment);
	glLinkProgram(ProgramID);

	// Check the program
	glGetProgramiv(ProgramID, GL_LINK_STATUS, &Result);
	glGetProgramiv(ProgramID, GL_INFO_LOG_LENGTH, &InfoLogLength);
	if ( InfoLogLength > 0 ){
		GLchar[] ProgramErrorMessage;
		ProgramErrorMessage.length = InfoLogLength;
		glGetProgramInfoLog(ProgramID, InfoLogLength, null, &ProgramErrorMessage[0]);
		errorf("Error Linking Shader:\n%s", ProgramErrorMessage);
	}

	
	glDetachShader(ProgramID, vertex);
	glDetachShader(ProgramID, fragment);
	
	glDeleteShader(vertex);
	glDeleteShader(fragment);

	return ProgramID;
}

bool validShaderType(GLenum type)
{
	switch(type)
	{
		case GL_FRAGMENT_SHADER:
		case GL_VERTEX_SHADER:
			return true;
		default:
			return false;
	}
}