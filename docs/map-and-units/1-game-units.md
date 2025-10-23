### Assumptions and goal

You specified an 800 × 800 world‑unit map and a target full‑map traversal time of 60 seconds. I’ll give you the unit↔pixel conversions, the required movement speeds, and practical pixel scales for common viewport choices (full‑map, camera view, and art/sprite scale) so you can pick the one that fits your UI and asset pipeline.

---

### Required movement speeds (deterministic)

- Required world speed to cross 800 units in 60 seconds:
  - Speed = 800 units / 60 s = **13.3333 units / s**.
- At canonical tickRate = 15 Hz:
  - Units per tick = 13.3333 / 15 = **0.8889 units / tick**.

Use those values to tune player base MoveSpeed (or sprint multiplier) so full cross in ~60s.

---

### Pixel conversion basics and formula

- Pixels per unit (ppu) = viewportWidthPx / viewportWidthUnits.  
- World distance in pixels = worldUnits × ppu.  
- Screen movement speed in px/s = unitsPerSecond × ppu.

Apply those three formulas to any viewport or art scale choice.

---

### Practical scale options and examples

Below are recommended, practical options depending on how much of the map you want visible and what visual fidelity you target.

1. Full‑map fit to screen (rare for gameplay, useful for minimap or full‑map view)
   - Example device width = 1080 px.  
   - ppu = 1080 px / 800 units = **1.35 px / unit**.  
   - Crossing speed in px/s = 13.333 × 1.35 ≈ **18 px / s**.  
   - Note: very low ppu; sprites will appear tiny when whole map is visible.

2. Typical gameplay camera showing a local area (recommended)
   - Choose camera viewport in world units so local detail is readable while encouraging exploration. Common choices:
     - ViewportWidthUnits = 200 → ppu = 1080 / 200 = **5.4 px / unit**.  
       - Full map width in screen widths = 800 / 200 = 4 viewports across.  
       - Crossing speed in px/s = 13.333 × 5.4 ≈ **72 px / s**.
     - ViewportWidthUnits = 160 → ppu = 1080 / 160 = **6.75 px / unit**.  
       - Crossing speed in px/s ≈ **90 px / s**.
     - ViewportWidthUnits = 120 → ppu = 1080 / 120 = **9 px / unit**.  
       - Crossing speed in px/s ≈ **120 px / s**.
   - Pick viewportWidthUnits so ppu yields comfortable sprite sizes (see art guidance below).

3. Minimap or overview
   - Minimap widget 200 px wide: ppu = 200 / 800 = **0.25 px / unit**.  
   - Useful for tiny full‑map overview; non‑interactive for detailed actions.

---

### Art and sprite scale recommendations

For readable, comic‑styled, high‑contrast assets on mobile, choose sprite pixel footprints relative to ppu:

- Character sprite target on screen at typical camera:
  - Aim for character on‑screen size ≈ 64–96 px tall for clarity on mobile.  
  - Required spriteHeightUnits = desiredPx / ppu. Example: for ppu = 6.75 px/unit and 80 px desired → spriteHeightUnits ≈ 11.85 units.
- Recommended baseline ppu for good readability: **~5–10 px/unit** for mobile gameplay view.
  - Lower than 5 → sprites get small and details lost.  
  - Higher than 10 → fewer world units visible; more art tokens needed.

Choose one of the camera viewportWidthUnits from the examples so ppu falls inside 5–10 px/unit.

---

### Concrete example set (1080 px device width)

- Option A (balanced): viewportWidthUnits = 160 → ppu = **6.75 px/unit**  
  - Character ≈ 80 px → ~11.85 units tall.  
  - Map spans ≈ 5 viewports across; traversal 60s ≈ 90 px/s on screen.

- Option B (more world visible): viewportWidthUnits = 200 → ppu = **5.4 px/unit**  
  - Character ≈ 80 px → ~14.8 units tall.  
  - Map spans 4 viewports; traversal 60s ≈ 72 px/s on screen.

- Option C (high detail zoom): viewportWidthUnits = 120 → ppu = **9 px/unit**  
  - Character ≈ 80 px → ~8.9 units tall.  
  - Map spans ~6.7 viewports; traversal 60s ≈ 120 px/s on screen.

---

### How to choose the right mapping for your game

1. Decide desired on‑screen character size in pixels (comfortable target 64–96 px on mid devices).  
2. Pick viewportWidthUnits so ppu = desiredPx / desiredSpriteHeightUnits falls in 5–10 px/unit.  
3. Validate traversal feel: with chosen ppu and world speed (13.333 units/s), compute px/s and check perceived speed visually in prototype.  
4. Tune MoveSpeed or camera viewport (zoom) to match desired travel time and combat pacing.

---

### Implementation checklist

- Set base MoveSpeed to 13.333 units/s (or set sprint such that sustained travel equals that) to meet 60s cross time.  
- Choose camera viewportWidthUnits (recommend 160–200 units for mobile).  
- Compute ppu for each target device width and ensure ppu ∈ [5,10] px/unit for readability.  
- Export sprites and UI assets at scales matching chosen ppu and provide 2×/3× variants for high‑DPI devices.  
- Prototype in engine and verify travel latency, sprite readability at 1x zoom, and VFX clarity.

---

If you tell me the target device screen width(s) (e.g., 1080×2340, 750×1334), I’ll compute exact ppu and give per‑device sprite size numbers and an asset export table (1×/2×/3×) you can drop into the art pipeline.
