package game.entity.base;

import h2d.Object;
import h2d.Tile;
import h2d.Bitmap;
import h2d.Graphics;

class BaseEntityView extends Object {
	private var bitmap:Bitmap;
	private var graphics:Graphics;
	
	public function new() {
		super();
		var tile = Tile.fromColor(0xFF0000, Math.floor(100), Math.floor(100));
		var bitmap = new Bitmap(tile, this);
		setPosition(100, 100);
	}
	
}