package game.scene.ui;

class GameUiScene extends h2d.Scene {

    public function new() {
        super();

        var font: h2d.Font = hxd.res.DefaultFont.get();
        var tf = new h2d.Text(font);
        tf.text = "Hello World\nHeaps is great!";
        tf.textAlign = Center;
        tf.color = new h3d.Vector4(1, 0, 0, 1);

        // add to any parent, in this case we append to root
        addChild(tf);
        tf.setPosition(100, 200);

        trace("GameUiScene created");
    }

}