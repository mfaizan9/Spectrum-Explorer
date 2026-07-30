# Accessibility Notes — Spectrum Explorer

Target: **WCAG 2.1 AA** (AAA where reasonable). Human screen-reader QA on real devices
(NVDA + Chrome/Firefox on Windows, VoiceOver + Safari on macOS/iOS) is still required — the
notes below describe what was built and mentally tested.

## Structure & landmarks

- The masthead component renders the single `<h1>` (the simulation title). The page adds no
  competing `h1`; panels use `<h2>` (`.panel__heading`) / `<legend>`, so the heading order
  does not skip levels.
- `<main class="app-layout">` is the main landmark; each panel is a `<section>` with an
  accessible name (`aria-labelledby` / `aria-label`).
- `<html lang="en">` is set.

## Keyboard operability (2.1.1 / 2.1.2 / 2.4.7)

- Every control is a **native** element, fully keyboard-operable with a visible
  `:focus-visible` ring (from `kl-unl.css`):
  - Spectrum mode: 3 radios (`<input type="radio">`).
  - Elements: 6 checkboxes.
  - Luminosity Class: 3 radios.
  - Spectral Type: `<input type="range">` — Left/Down decrement, Right/Up increment,
    PageUp/PageDown large step, Home/End = min/max (all native), **plus** a mouse-wheel
    handler that increments/decrements while the slider is focused (`preventDefault` so the
    page does not scroll). Respects min 0 / max 70 / step 1.
- **Tab order contains only interactive controls.** Verified the focusable set is exactly the
  13 inputs — no canvas, labels, readouts, or math are tab stops.
- **No keyboard traps.** The masthead dialog manages its own focus/Escape; the sim does not
  interfere.
- There are **no draggable canvas objects** in this simulation (the only continuous control
  is the slider), so the focus-then-arrow "draggable" pattern does not apply here.

## MathJax (rules 8 / 8a / 8b)

- All mathematical/units content shown to the user is typeset by **MathJax** (LaTeX), never
  as raster images or hand-built HTML: the wavelength axis labels `\(400\,\mathrm{nm}\)` /
  `\(700\,\mathrm{nm}\)` and the temperature readout `\(5830\,\mathrm{K}\)`.
- The temperature is updated through the foundation helper `klunlShowEquation`, which also
  updates a paired **screen-reader description** (`#se-temp-sr`, e.g. "Temperature 5830
  kelvin").
- The MathJax context menu is **left enabled** (right-clicking any typeset symbol opens
  "Show Math As → TeX / MathML").
- Typeset math is **display-only, not a tab stop.** MathJax's SVG output tags its
  `mjx-container` with a `tabindex`; a `MutationObserver` demotes every container to
  `tabindex="-1"` as it is created, keeping math out of the Tab order while preserving the
  right-click menu and screen-reader access. Verified: no `mjx-container` is keyboard
  focusable.
- Spectral-type **class letters** (O, B, A, F, G, K, M) and the class code like "G2" are
  spectral-classification labels, not mathematical notation, so they are presented as plain
  text (and spoken letter-then-digit, e.g. "G 2", via the slider's `aria-valuetext`).

## Text alternatives & the diagram (1.1.1)

- The `<canvas>` has `role="img"` with a descriptive `aria-label`.
- A visually-hidden `role="status" aria-live="polite"` region (`#se-live`) gives an
  audio-only user a continuously-updated description of **what the band currently shows**,
  updated from the single `render()` on every change — e.g.:
  - "Continuous spectrum: a smooth rainbow from 400 to 700 nanometers, violet through red,
    with no spectral lines."
  - "Emission spectrum: bright colored lines on a black background. Elements shown: Hydrogen."
  - "Absorption spectrum over a rainbow background. Spectral type G 2, luminosity class five
    (V), temperature 5830 kelvin. Dark absorption lines shown for: Hydrogen."
  The absorption/emission wording lists only elements whose lines are **actually visible**
  (strength > 10), matching the drawing.

## Units spoken with numbers (explicit supervisor requirement)

Every value with a unit is announced with its quantity name **and** unit — never a bare
number:

- Temperature: "Temperature 5830 kelvin" (visible symbol "K"; spoken word "kelvin").
- Wavelengths: axis labels and the live region say "400 nanometers", "656 nanometers", etc.
- Spectral Type slider `aria-valuetext`: "Spectral type G 2" (and, in absorption,
  ", temperature 5830 kelvin").

## Color & contrast (1.4.1 / 1.4.3 / 1.4.11)

- UI text/controls use the KL-UNL palette variables and meet ≥ 4.5:1 (≥ 3:1 for large text).
- **No state is conveyed by color alone.** Spectrum mode, selected elements, spectral type,
  luminosity class, and temperature are all available as radio/checkbox state, text readouts,
  and the live region. The spectrum colors themselves are the physical subject matter and are
  intentionally preserved; the accompanying text/labels carry the meaning for anyone who
  cannot distinguish them.
- Disabled control text is dimmed but remains legible; disabled state is also exposed
  natively via the `disabled` attribute (announced by screen readers), not by color alone.

## Control enable/visibility (mirrors the original)

- **Continuous:** Elements + Luminosity Class disabled; Spectral Type / Temperature hidden.
- **Emission:** Elements enabled; Luminosity Class disabled; Spectral Type / Temperature hidden.
- **Absorption:** Elements + Luminosity Class enabled; Spectral Type / Temperature shown.

## Timing / motion (2.2.2 / 2.3.3)

- No time-based animation, so nothing moves for > 5 s and nothing flashes. No Pause control is
  needed. `prefers-reduced-motion` is honored for any incidental CSS transitions.

## Zoom & reflow (1.4.4 / 1.4.10)

- Body copy is ≥ 1.125rem and everything is sized in rem/em, so text tracks the browser font
  setting. Layout uses relative units and CSS grid/flex; it reflows to a single-column,
  phone-portrait layout with **no horizontal scrolling** (verified at 375 px width) and
  remains usable at 200% zoom. The canvas scales with `aspect-ratio` + `width:100%`.

## Touch / cross-browser

- All controls are native, so touch works on iOS Safari and Android; targets meet the
  ≥ 44 px minimum from the KL-UNL control styles. No hover-only affordances. No Chrome-only
  APIs; no prefix-only CSS; MathJax is self-hosted with SVG output (resolution-independent,
  no external web-font fetch), which renders consistently across Chrome, Edge, Firefox, and
  Safari.

## Known limitations / QA still required

- Live-region verbosity and VoiceOver/NVDA phrasing should be confirmed with real assistive
  technology; wording was chosen to avoid flooding (updates on commit, not per animation tick,
  and the sim has no ticks).
- No canvas-baked text exists (labels live in HTML), so nothing needed to be moved off the
  canvas for zoom/legibility.
