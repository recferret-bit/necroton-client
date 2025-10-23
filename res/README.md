# Game Assets

This folder contains game assets such as:

- Images (PNG, JPG)
- Sounds (OGG, MP3)
- Fonts (TTF, OTF) 
- 3D Models (FBX, etc.)
- Other resources

## Heaps.io Resource System

In your Haxe code, access assets using the heaps resource system:

```haxe
// Load an image
var texture = hxd.Res.myImage.toTexture();
var bitmap = new h2d.Bitmap(texture, s2d);

// Load a sound
var sound = hxd.Res.mySound;
sound.play();

// Load a font
var font = hxd.Res.myFont.toFont();
var text = new h2d.Text(font, s2d);
```

## Mobile Optimization Tips

- Keep texture sizes power-of-2 when possible (512x512, 1024x1024, etc.)
- Use compressed formats appropriate for your target platforms
- Consider different DPI variants for high-resolution displays
- Optimize audio files for mobile bandwidth and storage
- Use atlases to reduce draw calls for 2D graphics