package game.scene.impl;

import h3d.Engine;

import game.scene.basic.BasicScene;
import game.scene.ui.GameUiScene;
import game.mvp.presenter.GamePresenter;

class GameScene extends BasicScene {
	private var gameUiScene:GameUiScene;
	private var gamePresenter:GamePresenter;
	
	public function new() {
		super();
		gameUiScene = new GameUiScene();
		
		// Create game presenter with MVP components
		gamePresenter = new GamePresenter(this);
		
		trace("GameScene created with MVP integration");
	}

	public function start():Void {
		trace("GameScene started");
		
		// Start the game presenter
		gamePresenter.start();

		// Must manually spawn entities

		// final engine = NecrotonEngine.create(config.engineConfig);
		// final entityId = engine.spawnEntity(EntitySpecs.getPlayerCharacterSpec());
		// trace("Spawned player character with ID: " + entityId);

		// // This is manual entity creation
		// final view = new CharacterEntityView(this);
		// final model = new CharacterModel();
		// model.initialize(engine.getCharacterById(entityId));
		// view.initialize(model);
		// addChild(view);

		// Enable debug info
		// gamePresenter.setDebugInfoVisible(true);
		
		trace("GameScene MVP integration complete");
	}

	public function destroy():Void {
		trace("GameScene destroyed");
		
		// Stop and destroy game presenter
		if (gamePresenter != null) {
			gamePresenter.destroy();
			gamePresenter = null;
		}
	}

	public function customUpdate(dt:Float, fps:Float) {
		// Update game presenter (handles engine, models, views)
		if (gamePresenter != null && gamePresenter.isGameRunning()) {
			gamePresenter.update(dt);
		}
	}

	public override function render(e:Engine) {
		super.render(e);
		if (gameUiScene != null) {
			gameUiScene.render(e);
		}
	}

}