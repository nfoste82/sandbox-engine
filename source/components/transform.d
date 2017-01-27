module components.transform;

import gl3n.linalg;

class Transform
{
	@property vec3 position()
	{
		return _position;
	}
	@property void position(vec3 newPosition)
	in
	{
		assert(newPosition.isFinite);
	}
	body
	{
		_position = newPosition;
	}

	@property quat rotation()
	{
		return _rotation;
	}
	@property void rotation(quat newRotation)
	in
	{
		assert(newRotation.isFinite);
	}
	body
	{
		_rotation = newRotation;
	}

	vec3 forward()
	{
		return _rotation * vec3(0,0,1);
	}

	vec3 right()
	{
		return _rotation * vec3(1,0,0);
	}

	vec3 up()
	{
		return _rotation * vec3(0,1,0);
	}
private:
	vec3 _position = vec3(0,0,0);
	quat _rotation = quat.identity;


//TBD
	//Transform _parent;
	//Transform[] children;
}