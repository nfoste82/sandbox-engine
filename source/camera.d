module camera;

import gl3n.linalg;
import gl3n.math;

class Camera
{
	vec3 position = vec3(0f, 0f,   0f);
	vec3 rotation = vec3(0f, 180f, 0f);

	float fov = 70f;


	vec3 forward()
	{
		return rotationMatrix * vec3(0,0,1);
	}

	vec3 right()
	{
		return rotationMatrix * vec3(1,0,0);
	}

	vec3 up()
	{
		return rotationMatrix * vec3(0,1,0);
	}

	mat3 rotationMatrix()
	{
		return mat3.identity
				   .rotatex(radians(rotation.x))
				   .rotatey(radians(rotation.y))
				   .rotatez(radians(rotation.z));
	}

	mat4 viewMatrix()
	{
		return mat4.look_at(position, position + forward, up);
	}
}