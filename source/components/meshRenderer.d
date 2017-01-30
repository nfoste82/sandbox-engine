module components.meshRenderer;

import std.range;
import std.array;
import std.experimental.logger;

import derelict.opengl3.gl3;
import derelict.assimp3.assimp;

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

	@property GLuint[] meshIDs()
	{
		return vertexbuffers;
	}
	@property GLuint[] meshColors()
	{
		return colorbuffers;
	}
	@property GLuint[] shaderIDs()
	{
		return programIDs;
	}

	@property uint[] triangleCounts()
	{
		return _triangleCounts;
	}

	void loadMesh()
	{
		//const(aiScene*) scene = aiImportFile( "assets/dragon_recon/dragon_vrip_res4.ply", 0);
		const(aiScene*) scene = aiImportFile( "assets/dragon_recon/dragon_vrip.ply", 0);

		GLuint[] VertexArrayIDs;
		
		int numMeshes = scene.mNumMeshes;
		VertexArrayIDs.length = numMeshes;
		_triangleCounts.length = numMeshes;
		vertexbuffers.length = numMeshes;
 		colorbuffers.length = numMeshes;
		
		glGenVertexArrays(numMeshes, &VertexArrayIDs[0]);

		// Generate 1 buffer, put the resulting identifier in vertexbuffer
		glGenBuffers(numMeshes, &vertexbuffers[0]);
		glGenBuffers(numMeshes, &colorbuffers[0]);

		for(int i = 0; i < vertexbuffers.length; ++i)
		{
			glBindVertexArray(VertexArrayIDs[i]);
			auto mesh = scene.mMeshes[i];

			glBindBuffer(GL_ARRAY_BUFFER, vertexbuffers[i]);
			glBufferData(GL_ARRAY_BUFFER, cast(long)(mesh.mNumVertices * aiVector3D.sizeof), cast(void*)mesh.mVertices, GL_STATIC_DRAW);

			glBindBuffer(GL_ARRAY_BUFFER, colorbuffers[i]);
			if(mesh.mColors[i] != null)
			{
				glBufferData(GL_ARRAY_BUFFER, mesh.mNumVertices * aiColor4D.sizeof, cast(void*)mesh.mColors[i], GL_STATIC_DRAW);
			}
			else
			{
				float[] white = array(repeat(1f).take(mesh.mNumVertices * 3));
				glBufferData(GL_ARRAY_BUFFER, white.length * float.sizeof, cast(void*)white, GL_STATIC_DRAW);
			}

			_triangleCounts[i] = mesh.mNumFaces * 3;
		}
	}

	void loadMaterial(string vertexPath, string fragmentPath)
	{
		programIDs = [LoadShader( vertexPath, fragmentPath )];
	}


private:
	GLuint[] vertexbuffers;
	GLuint[] colorbuffers;
	GLuint[] programIDs;

	uint[] _triangleCounts;
}