module window;

import std.string;
import std.experimental.logger;

import derelict.glfw3;
import derelict.opengl3.gl3;

import scene.scene;
import scene.gameObject;

class Window
{
	int width()
	{
		return _width;
	}

	int height()
	{
		return _height;
	}


	this (int width, int height, string title, Window parent)
	{
		_height = height;
		_width = width;
	    

	    glfwWindowHint(GLFW_SAMPLES, 4); // 4x antialiasing
		glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3); // We want OpenGL 3.3
		glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
		glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GLFW_TRUE); // To make MacOS happy; should not be needed
		glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE); //We don't want the old OpenGL 

	    /* Create a windowed mode window and its OpenGL context */
	    window = glfwCreateWindow(width, height, title.toStringz, null, null);
	    if (!window)
	    {
	        throw new Exception("Failed to create window");
	    }

	    glfwSetWindowSizeCallback(window, &onResize);

	    /* Make the window's context current */
	    glfwMakeContextCurrent(window);

	    registry[window] = this;
	}

	~this()
	{
		registry.remove(window);
	}

	void SetActiveScene(Scene scene)
	{
		_scene = scene;
	}

	void RenderFrame()
	in
	{
		assert(!Closed);
		assert(_scene);
	}
	body
	{
	    glfwMakeContextCurrent(window);

		_scene.render();

		glfwSwapBuffers(window);

		glfwPollEvents();

		if (glfwGetKey(window, GLFW_KEY_ESCAPE ) == GLFW_PRESS)
		{
			glfwSetWindowShouldClose(window, 1);	    
		}

		if(Closed)
		{
			glfwDestroyWindow(window);
			window = null;
		}

    }

    bool Closed()
    {
	    return window == null || glfwWindowShouldClose(window) == GLFW_TRUE;
    }


private:
	public GLFWwindow* window;

	Scene _scene;

	int _width;
	int _height;


	void resize(int height, int width) nothrow
	{
		_width = width;
		_height = height;
		glViewport(0,0, width, height);
	}
}


private:
	Window[GLFWwindow*] registry;

	extern (C) void onResize(GLFWwindow* window, int width, int height) nothrow
	{
		try
		{
			auto win = registry[window];
			win.resize(width, height);
		}
		catch(Throwable){}
	}