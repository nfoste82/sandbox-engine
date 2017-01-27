module components.camera;

import gl3n.linalg;
import gl3n.math;


import components.transform;

class Camera
{
	this(Transform transform)
	{
		_transform = transform;
	}

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

private:
	private Transform _transform;
}