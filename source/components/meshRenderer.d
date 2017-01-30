module components.meshRenderer;

import std.experimental.logger;

import derelict.opengl3.gl3;

import scene.scene;
import scene.gameObject;
import components.component;
import shader;

class MeshRenderer : Component
{
	this(Scene scene, objectID objID)
	{
		super(scene, objID);
	}

	@property GLuint meshID()
	{
		return vertexbuffer;
	}
	@property GLuint shaderID()
	{
		return programID;
	}


	void loadMesh()
	{
		log("loading mesh");
		static immutable GLfloat[9] g_vertex_buffer_data = [
		   -1.0f, -1.0f, 0.0f,
		   1.0f, -1.0f, 0.0f,
		   0.0f,  1.0f, 0.0f,
		];

		log("gen and bind");
		GLuint VertexArrayID;
		glGenVertexArrays(1, &VertexArrayID);
		glBindVertexArray(VertexArrayID);

		// Generate 1 buffer, put the resulting identifier in vertexbuffer
		glGenBuffers(1, &vertexbuffer);

		// The following commands will talk about our 'vertexbuffer' buffer
		glBindBuffer(GL_ARRAY_BUFFER, vertexbuffer);
		glBufferData(GL_ARRAY_BUFFER, cast(long)(g_vertex_buffer_data.sizeof), cast(void*)g_vertex_buffer_data, GL_STATIC_DRAW);
	}

	void loadMaterial(string vertexPath, string fragmentPath)
	{
		programID = LoadShader( vertexPath, fragmentPath );
	}


private:
	GLuint vertexbuffer;
	GLuint programID;
}