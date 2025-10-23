package;

import game.scene.basic.BasicScene;
import hxd.App;
import game.scene.SceneManager;

class Main extends App {
	// private var player:Player;
	// private var cameraFollowSpeed:Float = 1.0; // Speed of camera following (higher = faster)
	
	private var sceneManager:SceneManager;

	override function init() {
		// Set up mobile-friendly engine settings
		engine.backgroundColor = 0xFFFFFF;

		// Enable high DPI for mobile devices
		#if js
		// js.Browser.window.addEventListener("resize", onResize);
		// onResize();
		#end
		
		// s2d.scaleMode = ScaleMode.Stretch(1280, 720);

		// Create the player
		// player = new Player(s2d);
		// player.x = 0;
		// player.y = 0;

		// Initial viewport setup
		// updateViewport();

		sceneManager = new SceneManager(function(scene:BasicScene) {
			setScene2D(scene);
		});
	}

	override function onResize() {
		#if js
		updateViewport();
		#end
	}
	
	private function updateViewport() {
		// // Update camera viewport to center horizontally and position character closer to bottom
		// s2d.camera.viewportX = s2d.width * 0.5;
		// s2d.camera.viewportY = s2d.height * 0.5;
		
		// // Scale viewport so player takes 1/5 of screen height
		// if (player != null && player.bitmap != null) {
		// 	trace("player available");
		// 	var playerHeight = player.bitmap.tile.height;
		// 	var targetPlayerScreenHeight = s2d.height / 5.0; // 1/5 of screen height
		// 	var scale = targetPlayerScreenHeight / playerHeight;
			
		// 	s2d.camera.setScale(scale, scale);
		// } else {
		// 	trace("player not available");
		// 	// Fallback scaling if player not available
		// 	var targetWidth = 1280;
		// 	var targetHeight = 720;
		// 	var scaleX = s2d.width / targetWidth;
		// 	var scaleY = s2d.height / targetHeight;
		// 	var scale = Math.min(scaleX, scaleY);
			
		// 	s2d.camera.setScale(scale, scale);
		// }
	}

	override function update(dt:Float) {
		super.update(dt);
		
		if (sceneManager != null) {
			sceneManager.getCurrentScene().customUpdate(dt, engine.fps);
		}

		// Update player movement
		// if (player != null) {
		// 	player.update(dt);
			
		// 	// Smooth camera following - keep player centered
		// 	var targetX = player.x;
		// 	var targetY = player.y;
			
		// 	// Lerp camera position towards player position
		// 	s2d.camera.x += ((targetX - s2d.camera.x) * cameraFollowSpeed * dt);
		// 	s2d.camera.y += ((targetY - s2d.camera.y) * cameraFollowSpeed * dt);
		// }
	}

	static function main() {
		hxd.Res.initEmbed();
		new Main();
	}
}
