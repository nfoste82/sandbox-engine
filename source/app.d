import std.stdio;
import std.string;
import std.conv;

import std.experimental.logger;

import core.time;

import derelict.glfw3;

import derelict.opengl3.gl3;
import gl3n.linalg;
import gl3n.math;

import timeAccumulator;
import window;
import shader;
import components.camera;
import components.transform;

Camera cam;

GLuint vertexbuffer;
GLuint programID;

MonoTime startTime;

int main()
{
	DerelictGL3.load();
	
	DerelictGLFW3.load();

	// initialize glfw
	if (!glfwInit())
		throw new Exception("Failed to Initialize GLFW!");
    glfwSetErrorCallback(&error_callback);

	scope(exit)glfwTerminate();

	auto window = new Window(640, 480, "Hi!", &RenderFrame);

	DerelictGL3.reload();
	logf(LogLevel.info, "OpenGL Version: %s", glGetString(GL_VERSION).fromStringz);

    bool glLoggingEnabled = true;
    version(OSX)
    {
        glLoggingEnabled = false;
    }
    if(glLoggingEnabled)
    {
        glEnable(GL_DEBUG_OUTPUT);
        glDebugMessageCallback(&loggingCallbackOpenGL, null);
    }

	programID = LoadShader( "shaders/simple.vertex", "shaders/simple.fragment" );

	GLuint VertexArrayID;
	glGenVertexArrays(1, &VertexArrayID);
	glBindVertexArray(VertexArrayID);


	// Generate 1 buffer, put the resulting identifier in vertexbuffer
	glGenBuffers(1, &vertexbuffer);
	// The following commands will talk about our 'vertexbuffer' buffer
	glBindBuffer(GL_ARRAY_BUFFER, vertexbuffer);


	static immutable GLfloat[9] g_vertex_buffer_data = [
	   -1.0f, -1.0f, 0.0f,
	   1.0f, -1.0f, 0.0f,
	   0.0f,  1.0f, 0.0f,
	];

	glBufferData(GL_ARRAY_BUFFER, cast(long)(g_vertex_buffer_data.sizeof), cast(void*)g_vertex_buffer_data, GL_STATIC_DRAW);

	glClearColor(0.2,0.4,0.4,1);

	auto camTransform = new Transform();
	cam = new Camera(camTransform);
	camTransform.position = vec3(0,0,5);
	camTransform.rotation = quat.euler_rotation(0,PI,0);

	startTime = MonoTime.currTime;
	double lastTime = glfwGetTime();
	double speed = 2f;

	auto fps = TimeAccumulator();

	// Compute time difference between current and last frame
	while(!window.Closed)
	{
		double currentTime = glfwGetTime();
		float deltaTime = float(currentTime - lastTime);
		scope(exit)lastTime = currentTime;

		fps.addTime(deltaTime);
		if(fps.trackedWindow() > 1f)
		{
			writefln("fps: %s", fps.averageRate);
			fps.reset;
		}

		auto delta = deltaTime * speed;

		if (glfwGetKey(window.window, GLFW_KEY_W ) == GLFW_PRESS){
			camTransform.position = camTransform.position + camTransform.forward * delta;
		}
		// Move backward
		if (glfwGetKey(window.window, GLFW_KEY_S ) == GLFW_PRESS){
			camTransform.position = camTransform.position - camTransform.forward * delta;
		}
		// Strafe right
		if (glfwGetKey(window.window, GLFW_KEY_A ) == GLFW_PRESS){
			camTransform.position = camTransform.position + camTransform.right * delta;
		}
		// Strafe left
		if (glfwGetKey(window.window, GLFW_KEY_D ) == GLFW_PRESS){
			camTransform.position = camTransform.position - camTransform.right * delta;
		}

		// Move up
		if (glfwGetKey(window.window, GLFW_KEY_E ) == GLFW_PRESS){
			camTransform.position = camTransform.position + camTransform.up * delta;
		}
		// Move down
		if (glfwGetKey(window.window, GLFW_KEY_Q ) == GLFW_PRESS){
			camTransform.position = camTransform.position - camTransform.up * delta;
		}


		// Rotate right
		if (glfwGetKey(window.window, GLFW_KEY_Z ) == GLFW_PRESS){
			camTransform.rotation = camTransform.rotation.rotatey(delta);
		}
		// Rotate left
		if (glfwGetKey(window.window, GLFW_KEY_C ) == GLFW_PRESS){
			
			camTransform.rotation = camTransform.rotation.rotatey(-delta);
		}


		// increase FOV
		if (glfwGetKey(window.window, GLFW_KEY_KP_ADD ) == GLFW_PRESS){
			cam.fov += delta * 5f;
		}
		// Decrease FOV
		if (glfwGetKey(window.window, GLFW_KEY_KP_SUBTRACT ) == GLFW_PRESS){
			
			cam.fov -= delta * 5f;
		}

		window.RenderFrame();
	}

	return 0;
}

void RenderFrame(Window window)
{
	auto elapsed = MonoTime.currTime - startTime;
	auto elapsedSeconds = elapsed.total!("msecs") / 1000f;

	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	mat4 Projection = mat4.perspective(window.width, window.height,  70f, 1f, 100.0f);

	mat4 View = cam.viewMatrix;
	  
	//// Model matrix : an identity matrix (model will be at the origin)
	mat4 Model = mat4.identity;

	//// Our ModelViewProjection : multiplication of our 3 matrices
	mat4 mvp = Projection * View * Model;
	mvp.transpose;

	GLuint MatrixID = glGetUniformLocation(programID, "MVP");
  
	// Send our transformation to the currently bound shader, in the "MVP" uniform
	// This is done in the main loop since each model will have a different MVP matrix (At least for the M part)
	glUniformMatrix4fv(MatrixID, 1, GL_FALSE, mvp.value_ptr);

	glUseProgram(programID);
	glEnableVertexAttribArray(0);
	glCullFace(GL_BACK);
	glEnable(GL_CULL_FACE);
	glBindBuffer(GL_ARRAY_BUFFER, vertexbuffer);
	glVertexAttribPointer(
	   0,                  // attribute 0. No particular reason for 0, but must match the layout in the shader.
	   3,                  // size
	   GL_FLOAT,           // type
	   GL_FALSE,           // normalized?
	   0,                  // stride
	   cast(void*)0        // array buffer offset
	);

	// Draw the triangle !
	glDrawArrays(GL_TRIANGLES, 0, 3); // Starting from vertex 0; 3 vertices total -> 1 triangle
	glDisableVertexAttribArray(0);
}


void logError()
{
	auto errorCode = glGetError();
	//if(errorCode != GL_NO_ERROR)
		writefln("%s", glGetError());
}

extern(C) void error_callback(int error, const (char)* description) nothrow
{
	try{
    	errorf("GLFW Error:\n%s", description.fromStringz);
	}
	catch(Throwable){}
}

extern (C) nothrow void loggingCallbackOpenGL( GLenum source, GLenum type, GLuint id, GLenum severity,
                                               GLsizei length, const(GLchar)* message, GLvoid* userParam )
{
    try
    {
        writefln(message.fromStringz);
    }
    catch(Throwable){}
}