module components.component;

import scene.scene;
import scene.gameObject;
import components.registry;

abstract class Component
{
	protected this(Scene scene, objectID objID)
	{
		_objectID = objID;
		_scene = scene;
	}

	@property objectID ObjectID()
	{
		return _objectID;
	}

protected:
	@property Registry registry()
	{
		return _scene.registry;
	}

	@property Scene scene()
	{
		return _scene;
	}

private:
	objectID _objectID;
	Scene _scene;
}