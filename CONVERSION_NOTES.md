# Conversion Notes — Spectrum Explorer

## Behavior model (one paragraph)

Spectrum Explorer draws a single 500×50 "spectrum band" and lets the user choose one of
three spectrum **modes** via a radio group: **Continuous** (a smooth rainbow gradient from
400–700 nm), **Emission** (bright colored spectral lines on a black background), or
**Absorption** (dark spectral lines superimposed on the rainbow gradient). In Emission and
Absorption the user selects any of six line **sources** with checkboxes — Ionized Helium,
Helium, Hydrogen, Ionized Metals, Metals, Molecules — each of which contributes a fixed set
of wavelengths. Emission lines are always drawn at full intensity in a color derived from
their wavelength. Absorption lines are drawn black, and their intensity depends on the
star's **spectral type** (an O0…M9 slider, 0–70) through per-element line-strength curves;
only lines with strength > 10 are drawn. Absorption mode also exposes a **luminosity class**
radio (I / III / V) that sets the line thickness (I = 1, III = 2, V = 3 px) and, together
with the spectral type, determines the displayed **effective temperature** by linear
interpolation over per-class temperature tables.

## Source of truth

Decompiled with JPEXS/FFDec from `spectrum010.swf` (**SWF version 6** → ActionScript 1,
**case-insensitive identifiers** — see the `lumclass` note below). Key scripts:

- `scripts/frame_1/DoAction.as` — the controller: modes (`makeSpectrum`), element wavelength
  lists, line-strength arrays (`createLineArrays`), temperature tables + interpolation
  (`getTempFromSpectralType`), control enable/visibility.
- `scripts/spectra.as` — the drawing class: gradient (`drawContinuous`), black background
  (`drawEmission`), spectral lines (`drawColorLineAt` / `drawColorSet`), color/geometry math.
- `scripts/SliderV3SpectralType.as` — spectral-type slider (min 0, max 70, precision 0,
  initValue 42), value → "O0".."M9" label mapping.
- Component `on(initialize)` blocks — control labels, defaults, change handlers.

All constants, wavelength lists, line-strength formulas, and temperature tables are copied
**verbatim** into `simulation.js`.

## Geometry / drawing mapping

The AS `spectra` class draws the band with `beginGradientFill` and vertical lines at
`xPos(w) = spectPos(w) * (500/255)`, where `spectPos(w) = 255 - (w-395)*0.8225806`. In the
**un-mirrored** internal coordinates red (700 nm) is at the left and violet (400 nm) at the
right; on the Flash stage the clip is displayed mirrored, so the user sees violet on the
**left** and red on the **right** (as in the reference screenshot `spectrum010.jpg`). The
port draws directly in the user-visible orientation, which simplifies the equivalent mapping
to:

```
x(w) = (w - 395) / 310 * 500        // 395 nm → x=0, 705 nm → x=500  (band 500 px wide)
```

This is algebraically identical to the AS `xPos()` after the on-stage horizontal flip.
The continuous-gradient color stops use the same colors and the same fractional positions
`(w-395)/310` that the AS `ratios` array encodes (`spectPos` normalized to the 500 px box).

- Gradient colors (verbatim AS ints): red `0xFF0000`, orange `0xFFA500`, yellow `0xFFFF00`,
  green `0x00FF00`, cyan `0x00FFFF`, blue `0x0000FF`, purple `0x800080`.
- Emission-line color by wavelength (`colorFromLength`): `<430` `0xA000A0`, `<460` blue,
  `<495` cyan, `<540` green, `<580` yellow, `<620` orange, else red.

Canvas keeps the original 500×50 internal coordinates and is scaled by CSS
(`aspect-ratio: 500/50; width:100%`), so the drawing/physics math never depends on the
on-screen size.

## The `lumclass` case-insensitivity detail (important)

In `createArrays()` the source builds the spectral-type string with
`spectralType = type + String(excess) + String(lumclass)`. The variable is spelled
`lumclass` (all lowercase) while it is assigned as `lumClass`. Because the SWF targets
**Flash Player 6**, ActionScript identifiers are **case-insensitive**, so `lumclass` and
`lumClass` are the same variable. The string therefore correctly becomes e.g. `"G2V"`, and
the luminosity class **does** feed the temperature calculation. The port reproduces this
intended behavior (luminosity class affects both line thickness and temperature). Verified
numerically: G2 V = 5830 K, G2 III = 5550 K, G2 I = 5156 K.

## Element wavelengths (verbatim, nm)

| Element | Wavelengths |
|---|---|
| Ionized Helium | 433.9, 454.2, 468.6 |
| Helium | 402.6, 438.8, 447.1, 706.5 |
| Hydrogen | 397, 410.1, 434, 486.1, 656.3 |
| Ionized Metals | 393.3, 396.8, 407.7, 417.5, 421.5, 423.3, 424.6, 426.7, 430, 444.4, 448.1 |
| Metals | 403.2, 404.5, 432.5, 422.6, 589 |
| Molecules | 421.5, 430, 458.4, 462.5, 467, 469.7, 467, 478 |

(The Molecules list contains 467 twice — reproduced exactly as in the source.)

## AS1 idiom translations

- `Object.registerClass("spectra", …)` + prototype methods → plain drawing functions on the
  canvas 2D context (`drawContinuousBackground`, `drawEmissionBackground`, `drawSpectralLine`,
  `drawColorSet`). AS color ints are decimal RGB; fill/line alpha 0–100 → `/100`.
- `beginGradientFill("linear", colors, alphas, ratios, boxMatrix)` → `createLinearGradient`
  with color stops at the same fractional positions.
- `createEmptyMovieClip` / `lineStyle` / `moveTo`/`lineTo` for the lines → `ctx` strokes.
- FUIComponent framework (`FRadioButtonSymbol`, `FCheckBoxSymbol`, `SliderV3…`) is **not**
  ported; only its observable behavior is reproduced with native accessible controls
  (`<input type="radio|checkbox|range">`). `radioGroup.getValue()` (returns the selected
  radio's `data`) → reading the checked radio's `value`.
- `getValue`/`getState`/`setEnabled`/`_visible` → state reads + `disabled`/`hidden`.
- `changeTemp(tempSlider.value)` in `createArrays()` is **dead code** in the source
  (`changeTemp` and `tempSlider` are undefined everywhere else); it is a no-op and is omitted.

## Behavior deviations / edge cases

- **Slider value 70 (M9):** in the source, `createArrays()` computes `base = floor(70/10) = 7`
  and hits the `switch(base){ … default: return null }`, aborting before it draws any element
  lines or updates the temperature. The port reproduces this exactly: at value 70 no element
  lines are drawn and the temperature readout keeps its previous value. (Values 69 and 70 both
  display the label "M9", as in the source.)
- **No animation:** this simulation has no time-based motion (no `onEnterFrame`/`getTimer`
  loop); the display is a pure function of state. Therefore there is no Pause control and
  nothing for `prefers-reduced-motion` to suspend (the preference is still honored for any
  incidental CSS transitions).
- **Color remaps:** none. The original spectrum colors are physically meaningful and are kept
  as-is; state is never conveyed by color alone (mode, element, type, class, and temperature
  are all available as text / labels / the live region).

## Assets

The decompiled export contains **no bitmaps** (`images/` is empty) and no informative vector
art — the `shapes/*.svg` files are only FUIComponent chrome (radio/checkbox/slider skins),
which are replaced by native controls. The only code-drawn art is the spectrum band itself,
reproduced on the canvas. Consequently `assets/` contains no reused source art; it holds only
the self-hosted MathJax library.

## contents.json entry

The shared `foundation/contents.json` **already contains** the `spectrum010` entry
(title "Spectrum Explorer", version 2.0, with Help and About text). No edit was required —
the foundation folder was copied byte-for-byte unchanged. For reference, the entry used is:

```json
"spectrum010": {
  "meta": { "title": "Spectrum Explorer", "version": "2.0" },
  "masthead": {
    "help":  { "title": "Help and Instructions",
               "content": "<p>This explorer allows one to generate a variety of simulated spectra, depending on factors such as the type of source, luminosity class, spectral type, and individually selected elements.</p>" },
    "about": { "title": "About this Explorer", "content": "…standard AAS/UNL boilerplate…" }
  }
}
```

## MathJax

The provided foundation does not bundle MathJax and there is no demo file showing a MathJax
include. Rule 5 forbids CDNs, so MathJax v3 (SVG output, `tex-svg.js`) is **self-hosted**
under `assets/mathjax/` and loaded locally. It typesets the wavelength axis labels
(`400 nm`, `700 nm`) and the temperature readout via the foundation helper
`klunlShowEquation` (with paired screen-reader text). MathJax's context menu is left enabled;
its `mjx-container` elements are demoted to `tabindex="-1"` so display-only math never enters
the tab order (see ACCESSIBILITY.md).

## Verification performed (served over HTTP)

- Continuous gradient orientation matches the screenshot (violet left → red right).
- Emission: bright wavelength-colored lines on black.
- Absorption: black lines over the gradient, intensity by spectral type, thickness by class;
  Hydrogen lines confirmed at 397/410.1/434/486.1/656.3 nm.
- Temperatures match the source tables (G2 V 5830, G2 III 5550, G2 I 5156 K); class III → V
  fallback for types < 40 confirmed (F0 III = F0 V = 7020 K).
- Reset (via the masthead `sim-reset` event) restores the exact initial state.
- No console errors/logs; no network requests beyond `foundation/contents.json` and the
  local MathJax file.
