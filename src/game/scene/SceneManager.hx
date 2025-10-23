package game.scene;

import game.scene.impl.GameScene;
import game.scene.impl.LoadingScene;
import game.scene.impl.HomeScene;
import game.scene.basic.BasicScene;
import game.event.EventManager;

class SceneManager implements EventListener {
	private var sceneChangedCallback:BasicScene->Void;
	private var currentScene:BasicScene;
	
	public function new(sceneChangedCallback:BasicScene->Void) {
		this.sceneChangedCallback = sceneChangedCallback;

		EventManager.instance.subscribe(EventManager.EVENT_LOAD_HOME_SCENE, this);
		EventManager.instance.subscribe(EventManager.EVENT_LOAD_GAME_SCENE, this);

		currentScene = new LoadingScene();
		currentScene.start();

		changeSceneCallback();
	}

	// --------------------------------------
	// Impl
	// --------------------------------------

	public function notify(event:String, message:Dynamic) {
		switch (event) {
			case EventManager.EVENT_LOAD_HOME_SCENE: {
				if (currentScene != null) {
					currentScene.destroy();
				}
				currentScene = new HomeScene();
				currentScene.start();
			}
			case EventManager.EVENT_LOAD_GAME_SCENE: {
				if (currentScene != null) {
					currentScene.destroy();
				}
				currentScene = new GameScene();
				currentScene.start();
			}
		}
		changeSceneCallback();
	}

	// --------------------------------------
	// Common
	// --------------------------------------

	public function getCurrentScene() {
		return currentScene;
	}

	public function onResize() {
		currentScene.onResize();
	}

	private function changeSceneCallback() {
		if (sceneChangedCallback != null) {
			sceneChangedCallback(currentScene);
		}
	}
}
