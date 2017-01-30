module components.camera;

import std.experimental.logger;
import std.range;

import gl3n.linalg;
import gl3n.math;
import derelict.opengl3.gl3;

import scene.scene;
import scene.gameObject;
import components.component;
import components.registry;
import components.transform;
import components.meshRenderer;

class Camera : Component
{
	this(Scene scene, objectID objID)
	{
		super(scene, objID);
		_transform = registry.getComponent!Transform(objID);
	}

	int depth = 0;
	float fov = 70f;
	float nearClip = 0.1f;
	float farClip = 100f;

	@property Transform transform()
	{
		return _transform;
	}

	mat4 viewMatrix()
	{
		return mat4.look_at(_transform.position, _transform.position + _transform.forward, _transform.up);
	}

	void render()
	{
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		mat4 Projection = mat4.perspective(scene.window.width, scene.window.height,  fov, nearClip, farClip);

		mat4 View = viewMatrix;

		mat4 vp = Projection * View;

		auto renderers = registry.getComponentsOfType!(MeshRenderer);

		foreach(renderer; renderers)
		{
			auto transform = registry.getComponent!Transform(renderer.ObjectID);
			//// Model matrix : an identity matrix (model will be at the origin)
			mat4 Model = mat4.identity
			.scale(transform.scale.x, transform.scale.y, transform.scale.z)
			.rotate(transform.rotation.w, vec3(transform.rotation.x, transform.rotation.y, transform.rotation.z))
			.translate(transform.position)
			;

			Model = Model.scale(200,200,200);

			//// Our ModelViewProjection : multiplication of our 3 matrices
			mat4 mvp = vp * Model;
			mvp.transpose;

			foreach(mesh, colors, shader, faceCount; zip(renderer.meshIDs, renderer.meshColors, renderer.shaderIDs.chain(renderer.shaderIDs.back.repeat), renderer.triangleCounts))
			{

				glUseProgram(shader);
				GLuint MatrixID = glGetUniformLocation(shader, "MVP");
			  
				// Send our transformation to the currently bound shader, in the "MVP" uniform
				// This is done in the main loop since each model will have a different MVP matrix (At least for the M part)

				glUniformMatrix4fv(MatrixID, 1, GL_FALSE, mvp.value_ptr);

				glEnableVertexAttribArray(0);
				glCullFace(GL_BACK);
				glEnable(GL_CULL_FACE);
				glBindBuffer(GL_ARRAY_BUFFER, mesh);

				glVertexAttribPointer(
				   0,                  // attribute 0. No particular reason for 0, but must match the layout in the shader.
				   3,                  // size
				   GL_FLOAT,           // type
				   GL_FALSE,           // normalized?
				   0,                  // stride
				   cast(void*)0        // array buffer offset
				);
				glEnableVertexAttribArray(1);
				glBindBuffer(GL_ARRAY_BUFFER, colors);
				glVertexAttribPointer(
				    1,                                // attribute. No particular reason for 1, but must match the layout in the shader.
				    3,                                // size
				    GL_FLOAT,                         // type
				    GL_FALSE,                         // normalized?
				    0,                                // stride
				    cast(void*)0                          // array buffer offset
				);

				// Draw the triangle !
				glDrawArrays(GL_TRIANGLES, 0, faceCount); // Starting from vertex 0; 3 vertices total -> 1 triangle
				glDisableVertexAttribArray(0);
			}
		}
	}

	//override int opCmp(object other)
	//{
	//	if(other is Camera)
	//	{
	//		return opCmp(cast(Camera)other);
	//	}
	//	else
	//		return 0;
	//}

	//int opCmp(Camera other)
	//{
	//	return depth - other.depth;
	//}

private:
	private Transform _transform;
}