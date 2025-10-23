import h2d.Bitmap;
import h2d.Object;
import hxd.Key;

class Player extends Object {
	private var speed:Float = 200.0;
	
	public var bitmap(get, null):Bitmap;
	private function get_bitmap():Bitmap return bitmap;
	
	public function new(parent:Object) {
		super(parent);
		
		// Load the Marius asset
		bitmap = new Bitmap(hxd.Res.marius.toTile(), this);
		
		// Center the bitmap
		bitmap.x = -bitmap.tile.width * 0.5;
		bitmap.y = -bitmap.tile.height * 0.5;
	}
	
	public function update(dt:Float) {
		var dx = 0.0;
		var dy = 0.0;
		
		// WASD input handling
		if (Key.isDown(Key.W) || Key.isDown(Key.UP)) {
			dy -= speed * dt;
		}
		if (Key.isDown(Key.S) || Key.isDown(Key.DOWN)) {
			dy += speed * dt;
		}
		if (Key.isDown(Key.A) || Key.isDown(Key.LEFT)) {
			dx -= speed * dt;
		}
		if (Key.isDown(Key.D) || Key.isDown(Key.RIGHT)) {
			dx += speed * dt;
		}
		
		// Update position
		x += dx;
		y += dy;
	}
}