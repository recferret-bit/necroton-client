package game.scene.impl;

import game.scene.basic.BasicScene;
import game.event.EventManager;

class LoadingScene extends BasicScene {
	public function new() {
		super();
		trace("LoadingScene created");
	}

	public function start():Void {
		trace("LoadingScene started");
		EventManager.instance.notify(EventManager.EVENT_LOAD_GAME_SCENE, null);
	}

	public function destroy():Void {
		trace("LoadingScene destroyed");
	}

	public function customUpdate(dt:Float, fps:Float):Void {
		trace("LoadingScene updated");
	}
}