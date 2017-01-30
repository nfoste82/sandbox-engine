module components.registry;

import std.container;
import std.algorithm;

import scene.scene;
import scene.gameObject;
import components.component;

class Registry
{
	this(Scene scene)
	{
		_scene = scene;
	}

	TComponent createComponent(TComponent:Component)(objectID objID)
	{
		auto component = new TComponent(_scene, objID);
		registry[typeid(TComponent)] ~= component;
		return component;
	}

	TComponent getComponent(TComponent:Component)(objectID objID)
	{
		return getComponentsOfType!TComponent.filter!(component=>component.ObjectID == objID).front;
	}

	auto getComponentsOfType(TComponent:Component)()
	{
		auto list = *(typeid(TComponent) in registry);
		return list.map!(component => cast(TComponent)component);
	}


private:
	Component[][TypeInfo] registry;
	Scene _scene;
}