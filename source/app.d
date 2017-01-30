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
import scene.scene;
import components.transform;
import components.cameraControl;
import components.camera;
import components.meshRenderer;

int main()
{
	DerelictGL3.load();
	
	DerelictGLFW3.load();

	// initialize glfw
	if (!glfwInit())
		throw new Exception("Failed to Initialize GLFW!");
    glfwSetErrorCallback(&error_callback);

	scope(exit)glfwTerminate();


	auto window = new Window(640, 480, "Hi!", null);


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


	Scene scene = new Scene(window);
	auto camera = scene.createObject!(Transform, Camera, CameraControl);
	auto triangle = scene.createObject!(Transform, MeshRenderer);

	window.SetActiveScene(scene);

	scene.getComponent!(CameraControl)(camera).window = window.window;

	auto triangleMesh = scene.getComponent!(MeshRenderer)(triangle);
	triangleMesh.loadMesh();
	triangleMesh.loadMaterial("shaders/simple.vshader", "shaders/UnlitVertexColored.fshader");

	glClearColor(0.2,0.4,0.4,1);

	auto camTransform = scene.getComponent!Transform(camera);
	camTransform.position = vec3(0,0,5);
	camTransform.rotation = quat.euler_rotation(0,PI,0);

	double lastTime = glfwGetTime();
	double speed = 2f;

	auto fps = TimeAccumulator();

	// Compute time difference between current and last frame
	while(!window.Closed)
	{
		double currentTime = glfwGetTime();
		double deltaTime = double(currentTime - lastTime);
		scope(exit)lastTime = currentTime;

		fps.addTime(deltaTime);
		if(fps.trackedWindow() > 1f)
		{
			writefln("fps: %s", fps.averageRate);
			fps.reset;
		}

		window.RenderFrame();
	}

	return 0;
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
    	switch(type)
    	{
	    case GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR:
    	case GL_DEBUG_TYPE_ERROR:
    		errorf("GL Error %s", message.fromStringz);
    		break;
	    case GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR:
	    case GL_DEBUG_TYPE_PORTABILITY:
	    case GL_DEBUG_TYPE_PERFORMANCE:
    		warningf("GL Warning %s", message.fromStringz);
    		break;
	    case GL_DEBUG_TYPE_MARKER:
	    case GL_DEBUG_TYPE_PUSH_GROUP:
	    case GL_DEBUG_TYPE_POP_GROUP:
	    case GL_DEBUG_TYPE_OTHER:
    	default:
        	logf("GL Info: %s", message.fromStringz);
    	}


    }
    catch(Throwable){}
}

void logError()
{
	auto errorCode = glGetError();
	//if(errorCode != GL_NO_ERROR)
		writefln("%s", glGetError());
}