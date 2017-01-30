module components.transform;

import gl3n.linalg;

import scene.scene;
import scene.gameObject;
import components.component;
import components.registry;

class Transform : Component
{
	this(Scene scene, objectID objID)
	{
		super(scene, objID);
	}

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

	@property vec3 scale()
	{
		return _scale;
	}
	@property void scale(vec3 newScale)
	in
	{
		assert(newScale.isFinite);
	}
	body
	{
		_scale = newScale;
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
	vec3 _scale = vec3(1,1,1);


//TBD
	//Transform _parent;
	//Transform[] children;
}