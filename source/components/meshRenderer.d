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

	@property GLuint[] meshs()
	{
		return vertexbuffers;
	}
	@property GLuint[] UVs()
	{
		return uvbuffers;
	}
	@property GLuint[] normals()
	{
		return normalbuffers;
	}
	@property GLuint[] meshColors()
	{
		return colorbuffers;
	}
	@property GLuint[] shaders()
	{
		return programIDs;
	}

	@property uint[] triangleCounts()
	{
		return _triangleCounts;
	}

	void loadMesh()
	{
		//const(aiScene*) scene = aiImportFile( "assets/dragon_recon/dragon_vrip_res4.ply", aiProcess_GenSmoothNormals | aiProcess_GenUVCoords);
		const(aiScene*) scene = aiImportFile( "assets/dragon_recon/dragon_vrip.ply", aiProcess_GenSmoothNormals | aiProcess_GenUVCoords);
		//const(aiScene*) scene = aiImportFile( "assets/crytek-sponza/sponza.obj", 0);
		
		GLuint[] VertexArrayIDs;
		
		int numMeshes = scene.mNumMeshes;
		VertexArrayIDs.length = numMeshes;
		_triangleCounts.length = numMeshes;
		vertexbuffers.length = numMeshes;
 		colorbuffers.length = numMeshes;
		normalbuffers.length = numMeshes;
		uvbuffers.length = numMeshes;
		
		glGenVertexArrays(numMeshes, &VertexArrayIDs[0]);

		// Generate 1 buffer, put the resulting identifier in vertexbuffer
		glGenBuffers(numMeshes, &vertexbuffers[0]);
		glGenBuffers(numMeshes, &colorbuffers[0]);
 		glGenBuffers(numMeshes, &normalbuffers[0]);
 		glGenBuffers(numMeshes, &uvbuffers[0]);

		for(int i = 0; i < vertexbuffers.length; ++i)
		{
			glBindVertexArray(VertexArrayIDs[i]);
			auto mesh = scene.mMeshes[i];

			glBindBuffer(GL_ARRAY_BUFFER, vertexbuffers[i]);
			glBufferData(GL_ARRAY_BUFFER, mesh.mNumVertices * aiVector3D.sizeof, cast(void*)mesh.mVertices, GL_STATIC_DRAW);

			glBindBuffer(GL_ARRAY_BUFFER, uvbuffers[i]);
			glBufferData(GL_ARRAY_BUFFER, mesh.mNumVertices * aiVector3D.sizeof, cast(void*)mesh.mTextureCoords[0], GL_STATIC_DRAW);

			glBindBuffer(GL_ARRAY_BUFFER, normalbuffers[i]);
			glBufferData(GL_ARRAY_BUFFER, mesh.mNumVertices * aiVector3D.sizeof, cast(void*)mesh.mNormals, GL_STATIC_DRAW);

			glBindBuffer(GL_ARRAY_BUFFER, colorbuffers[i]);
			if(mesh.mColors[0] != null)
			{
				glBufferData(GL_ARRAY_BUFFER, mesh.mNumVertices * aiColor4D.sizeof, cast(void*)mesh.mColors[0], GL_STATIC_DRAW);
			}
			else
			{
				float[] white = array(repeat(1f).take(mesh.mNumVertices * 4));
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
	GLuint[] normalbuffers;
	GLuint[] uvbuffers;

	uint[] _triangleCounts;
}