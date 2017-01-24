import std.stdio;
import std.string;
import std.conv;

import core.time;

import derelict.opengl3.gl3;
import gl3n.linalg;
import gl3n.math;

import window;
import shader;

GLuint vertexbuffer;
GLuint programID;

MonoTime startTime;

int main()
{
    DerelictGL3.load();

    auto window = new Window(640, 480, "Hi!", &RenderFrame);

    DerelictGL3.reload();

    //glEnable(GL_DEBUG_OUTPUT);
    //glDebugMessageCallback(&loggingCallbackOpenGL, null);

    programID = LoadShader( "shaders/simple.vertex", "shaders/simple.fragment" );


    GLuint VertexArrayID;
    glGenVertexArrays(1, &VertexArrayID);
	glBindVertexArray(VertexArrayID);


	// Generate 1 buffer, put the resulting identifier in vertexbuffer
	glGenBuffers(1, &vertexbuffer);
	// The following commands will talk about our 'vertexbuffer' buffer
	glBindBuffer(GL_ARRAY_BUFFER, vertexbuffer);


	static immutable GLfloat[] g_vertex_buffer_data = [
	   -1.0f, -1.0f, 0.0f,
	   1.0f, -1.0f, 0.0f,
	   0.0f,  1.0f, 0.0f,
	];

	glBufferData(GL_ARRAY_BUFFER, cast(long)(g_vertex_buffer_data[0].sizeof * g_vertex_buffer_data.length), cast(void*)g_vertex_buffer_data, GL_STATIC_DRAW);

    glClearColor(0,0,1,1);


    startTime = MonoTime.currTime;
    while(!window.Closed)
    {
    	window.RenderFrame();
    }

    return 0;
}

//nothrow void loggingCallbackOpenGL( GLenum source, GLenum type, GLuint id, GLenum severity,
//                                	GLsizei length, const(GLchar)* message, GLvoid* userParam )
//{
//	try
//	{
//		writefln(message.fromStringz);
//	}
//	catch{}
//}

void RenderFrame()
{
	auto elapsed = MonoTime.currTime - startTime;
	auto elapsedSeconds = elapsed.total!("msecs") / 1000f;

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	mat4 Projection = mat4.perspective(640f, 480f,  70f, 1f, 100.0f);

	mat4 View = mat4.look_at(
	    vec3(0,0, 3), // Camera is at (4,3,3), in World Space
	    vec3(0,0,0), // and looks at the origin
	    vec3(0,1,0)  // Head is up (set to 0,-1,0 to look upside-down)
	    );
	  
	//// Model matrix : an identity matrix (model will be at the origin)
	mat4 Model = mat4.identity.translate(sin(elapsedSeconds) * 4,0,0);//.rotatey(elapsedSeconds * 0.2f);

	//// Our ModelViewProjection : multiplication of our 3 matrices
	mat4 mvp = Projection * View * Model;

	GLuint MatrixID = glGetUniformLocation(programID, "MVP");
  
	// Send our transformation to the currently bound shader, in the "MVP" uniform
	// This is done in the main loop since each model will have a different MVP matrix (At least for the M part)
	glUniformMatrix4fv(MatrixID, 1, GL_FALSE, mvp.value_ptr);

    glUseProgram(programID);
    glEnableVertexAttribArray(0);
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