# Spectrum Explorer (Accessible HTML5)

An accessible HTML5 port of the legacy Flash **Spectrum Explorer** (`spectrum010.swf`),
built on the shared KL-UNL foundation. It lets you generate continuous, emission, and
absorption spectra and see how spectral type, luminosity class, and selected elements
change the result.

## ⚠️ It must be served over HTTP — double-clicking `index.html` will NOT work

The KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads its title and its
Help / About text with `fetch('foundation/contents.json')`. Browsers **block `fetch()`
of local files under the `file://` protocol** (the same-origin security policy), so if you
open `index.html` directly from your file system the masthead (title, Help, About) will be
empty or broken. Serving the folder over HTTP fixes this.

## How to run it locally

Open a terminal **inside this `html5/` folder** and start any static web server:

**Python**
```bash
python3 -m http.server 8123
```
then open <http://localhost:8123/>

**Node**
```bash
npx serve
```
(or `npx http-server`)

**VS Code**
Use the "Live Server" extension (right-click `index.html` → *Open with Live Server*).

> Because you are serving from **inside** `html5/`, the simulation is at the server root —
> the URL is `http://localhost:8123/`, **not** `.../html5/index.html`.

## Production

When deployed to the cloud host (served over HTTP/HTTPS) it just works with no changes.
The `file://` limitation only affects opening the file locally by double-clicking.

## What's in this folder

```
html5/
  index.html            KL-UNL scaffold: .app-shell + <kl-unl-masthead> + panels
  foundation/           Copied UNCHANGED from the source foundation/ (do not edit)
                          kl-unl-masthead.js, kl-unl.css, kl-unl.js, contents.json, favicons
  styles/styles.css     Sim-specific styles only (foundation is never modified)
  simulation.js         All sim logic (state, render, behavior, a11y)
  assets/mathjax/        Self-hosted MathJax (SVG output) — no CDN at runtime
  README.md             This file
  CONVERSION_NOTES.md   Behavior model, AS→HTML5 mapping, deviations
  ACCESSIBILITY.md      WCAG affordances and screen-reader notes
```

## Dependencies

None at build time — no bundler, no framework, no CDN, no analytics, no web fonts.
The only runtime fetches are local: `foundation/contents.json` (by the masthead) and the
self-hosted MathJax library in `assets/mathjax/`. Nothing leaves the host.
