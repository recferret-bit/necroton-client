package game.scene.basic;

abstract class BasicScene extends h2d.Scene {
    public var debugGraphics:h2d.Graphics;

    public function new() {
        super();
        debugGraphics = new h2d.Graphics(this);
    }

    public abstract function start():Void;
    public abstract function destroy():Void;
	public abstract function customUpdate(dt:Float, fps:Float):Void;

    public override function render(e:h3d.Engine) {
        debugGraphics.clear();
        super.render(e);
    }
    
    public function onResize():Void {
        trace("BasicScene onResize");
    }
}