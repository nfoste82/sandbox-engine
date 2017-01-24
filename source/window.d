module window;

import std.string;

import derelict.glfw3;

class Window
{
	alias RenderFunction = void function();
	private RenderFunction render; 
	private GLFWwindow* window;
	this (int width, int height, string title, RenderFunction render)
	{
		this.render = render;

	    DerelictGLFW3.load();

	    // initialize glfw
	    if (!glfwInit())
	        throw new Exception("Failed to Initialize GLFW!");

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

	    /* Make the window's context current */
	    glfwMakeContextCurrent(window);
	}

	~this()
	{
		glfwTerminate();
	}

	void RenderFrame()
	{
		render();

		/* Swap front and back buffers */
		glfwSwapBuffers(window);

		/* Poll for and process events */
		glfwPollEvents();
    }

    bool Closed()
    {
	    return glfwWindowShouldClose(window) == GLFW_TRUE;
    }
}