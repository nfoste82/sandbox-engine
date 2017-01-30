module components.cameraControl;

import scene.scene;
import scene.gameObject;
import components.component;
import components.transform;
import components.registry;
import components.camera;
import components.updatingComponent;
import derelict.glfw3;

import gl3n.math;

class CameraControl : UpdatingComponent
{
	this(Scene scene, objectID objID)
	{
		super(scene, objID);
		_transform = registry.getComponent!Transform(objID);
		_camera = registry.getComponent!Camera(objID);
	}

	double speed = .1f;

	override void update(double deltaTime)
	{

		auto delta = deltaTime * speed;

		if (glfwGetKey(window, GLFW_KEY_W ) == GLFW_PRESS){
			_transform.position = _transform.position + _transform.forward * delta;
		}
		// Move backward
		if (glfwGetKey(window, GLFW_KEY_S ) == GLFW_PRESS){
			_transform.position = _transform.position - _transform.forward * delta;
		}
		// Strafe right
		if (glfwGetKey(window, GLFW_KEY_A ) == GLFW_PRESS){
			_transform.position = _transform.position + _transform.right * delta;
		}
		// Strafe left
		if (glfwGetKey(window, GLFW_KEY_D ) == GLFW_PRESS){
			_transform.position = _transform.position - _transform.right * delta;
		}

		// Move up
		if (glfwGetKey(window, GLFW_KEY_E ) == GLFW_PRESS){
			_transform.position = _transform.position + _transform.up * delta;
		}
		// Move down
		if (glfwGetKey(window, GLFW_KEY_Q ) == GLFW_PRESS){
			_transform.position = _transform.position - _transform.up * delta;
		}


		// Rotate right
		if (glfwGetKey(window, GLFW_KEY_Z ) == GLFW_PRESS){
			_transform.rotation = _transform.rotation.rotatey(radians(delta));
		}
		// Rotate left
		if (glfwGetKey(window, GLFW_KEY_C ) == GLFW_PRESS){
			
			_transform.rotation = _transform.rotation.rotatey(-radians(delta));
		}


		// increase FOV
		if (glfwGetKey(window, GLFW_KEY_KP_ADD ) == GLFW_PRESS){
			_camera.fov += delta * 5f;
		}
		// Decrease FOV
		if (glfwGetKey(window, GLFW_KEY_KP_SUBTRACT ) == GLFW_PRESS){
			
			_camera.fov -= delta * 5f;
		}
	}

	GLFWwindow* window;

private:
	private Transform _transform;
	private Camera _camera;
}