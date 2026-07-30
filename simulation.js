/* =============================================================================
 * Spectrum Explorer  --  HTML5 port of spectrum010.swf (Flash AS1, SWF v6)
 *
 * Behavior is a faithful port of the decompiled ActionScript:
 *   - frame_1/DoAction.as     (controller: modes, line-strength arrays, temp tables)
 *   - spectra.as              (the drawing class: gradient + spectral lines)
 *   - SliderV3SpectralType.as  (spectral-type slider: value 0..70, label O0..M9)
 *
 * All physics constants, wavelength tables, line-strength formulas and the
 * temperature interpolation tables are copied VERBATIM from the source.
 *
 * Rendering: the original drew a 500x50 "spectrum band" on the Flash stage.
 * On stage the clip was mirrored (red on the right), so we draw directly in the
 * user-visible orientation: violet (400 nm) at the left, red (700 nm) at right.
 * The wavelength -> x mapping is derived from the source and simplifies to
 *   x(w) = (w - 395) / 310 * 500      (band is 500 px wide; 395..705 nm)
 * which is exactly equivalent to the AS xPos()/spectPos() math after the flip.
 * ===========================================================================*/

(function () {
  'use strict';

  // ---- Stage / band geometry (original internal coordinates) ----------------
  var BAND_W = 500;   // spectrum band width  (Flash stage units)
  var BAND_H = 50;    // spectrum band height (Flash stage units)

  // Map a wavelength (nm) to a horizontal position within the band.
  // Derived from spectra.as: after the on-stage horizontal flip,
  //   x = (w - 395) * (500/310).  (395 nm -> 0, 705 nm -> 500)
  function xForWavelength(w) {
    return (w - 395) / 310 * BAND_W;
  }

  // ---- Colors ---------------------------------------------------------------
  // Continuous-gradient color stops, VERBATIM from spectra.as:
  //   colors = [red, orange, yellow, green, cyan, blue, purple]
  //   ratios = [redPos, orgPos, yelPos, grnPos, cynPos, bluPos, purPos]
  // Expressed here in visible orientation as {wavelength, color}; fraction along
  // the band is (w-395)/310 which matches the AS spectPos()/box-matrix ratios.
  var GRADIENT_STOPS = [
    { w: 400, color: 0x800080 }, // purple  (8388736)
    { w: 445, color: 0x0000FF }, // blue    (255)
    { w: 475, color: 0x00FFFF }, // cyan    (65535)
    { w: 510, color: 0x00FF00 }, // green   (65280)
    { w: 570, color: 0xFFFF00 }, // yellow  (16776960)
    { w: 590, color: 0xFFA500 }, // orange  (16753920)
    { w: 700, color: 0xFF0000 }  // red     (16711680)
  ];

  // Convert an AS decimal RGB int to a CSS #rrggbb string.
  function intToHex(c) {
    var s = (c & 0xFFFFFF).toString(16);
    while (s.length < 6) { s = '0' + s; }
    return '#' + s;
  }

  // spectra.as colorFromLength(): emission-line color as a function of wavelength.
  function colorFromLength(wavelength) {
    var clr;
    if (wavelength < 430)      { clr = 10485920; } // 0xA000A0 purple
    else if (wavelength < 460) { clr = 255; }      // 0x0000FF blue
    else if (wavelength < 495) { clr = 65535; }    // 0x00FFFF cyan
    else if (wavelength < 540) { clr = 65280; }    // 0x00FF00 green
    else if (wavelength < 580) { clr = 16776960; } // 0xFFFF00 yellow
    else if (wavelength < 620) { clr = 16753920; } // 0xFFA500 orange
    else                       { clr = 16711680; } // 0xFF0000 red
    return clr;
  }

  // ---- Element line lists (nm) ---------------------------------------------
  // VERBATIM from createArrays() in DoAction.as. Order preserved.
  var ELEMENT_LINES = {
    ihelium:  [433.9, 454.2, 468.6],
    helium:   [402.6, 438.8, 447.1, 706.5],
    hydrogen: [397, 410.1, 434, 486.1, 656.3],
    imetals:  [393.3, 396.8, 407.7, 417.5, 421.5, 423.3, 424.6, 426.7, 430, 444.4, 448.1],
    metals:   [403.2, 404.5, 432.5, 422.6, 589],
    molecules:[421.5, 430, 458.4, 462.5, 467, 469.7, 467, 478]
  };

  // Human-readable element names + a representative color word for a11y.
  var ELEMENT_LABELS = {
    ihelium: 'Ionized Helium',
    helium: 'Helium',
    hydrogen: 'Hydrogen',
    imetals: 'Ionized Metals',
    metals: 'Metals',
    molecules: 'Molecules'
  };

  // Which line-strength array each element uses (indexed by spectral-type number).
  var ELEMENT_STRENGTH_KEY = {
    ihelium: 'iHe',
    helium: 'He',
    hydrogen: 'H',
    imetals: 'imet',
    metals: 'met',
    molecules: 'mol'
  };

  // ---- Line-strength arrays (alpha 0..100 vs. spectral-type number 0..69) ----
  // Ported VERBATIM from createLineArrays() in DoAction.as.
  var lineStrength = { iHe: [], He: [], H: [], imet: [], met: [], mol: [] };

  function createLineArrays() {
    var i;
    for (i = 0; i < 70; i++) {
      lineStrength.iHe[i] = (i < 8) ? Math.floor(-12.5 * i + 100) : 0;
    }
    for (i = 0; i < 70; i++) {
      if (i < 8)       { lineStrength.He[i] = Math.floor(3.75 * i + 70); }
      else if (i < 21) { lineStrength.He[i] = Math.floor(-7.7 * i + 161.7); }
      else             { lineStrength.He[i] = 0; }
    }
    for (i = 0; i < 70; i++) {
      if (i < 7)        { lineStrength.H[i] = 0; }
      else if (i < 20)  { lineStrength.H[i] = Math.floor(7.7 * i - 53.9); }
      else if (i < 54)  { lineStrength.H[i] = Math.floor(-2.94 * i + 158.7); }
      else              { lineStrength.H[i] = 0; }
    }
    for (i = 0; i < 70; i++) {
      if (i < 11)       { lineStrength.imet[i] = 0; }
      else if (i < 38)  { lineStrength.imet[i] = Math.floor(3.7 * i - 40.7); }
      else if (i < 52)  { lineStrength.imet[i] = Math.floor(-7.14 * i + 371.3); }
      else              { lineStrength.imet[i] = 0; }
    }
    for (i = 0; i < 70; i++) {
      if (i < 30)       { lineStrength.met[i] = 0; }
      else if (i < 49)  { lineStrength.met[i] = Math.floor(5.26 * i - 157.8); }
      else if (i < 62)  { lineStrength.met[i] = Math.floor(-7.7 * i + 477.4); }
      else              { lineStrength.met[i] = 0; }
    }
    for (i = 0; i < 70; i++) {
      lineStrength.mol[i] = (i < 50) ? 0 : Math.floor(5.26 * i - 263.16);
    }
  }

  // ---- Temperature tables (Teff vs. spectral-type number, per lum class) -----
  // VERBATIM from getTempFromSpectralType() in DoAction.as.
  var TEMP_TABLES = {
    v: [
      {type:7,teff:38000},{type:9,teff:33200},{type:9.5,teff:31450},{type:10,teff:29700},
      {type:11,teff:25600},{type:12,teff:22300},{type:13,teff:19000},{type:14,teff:17200},
      {type:15,teff:15400},{type:16,teff:14100},{type:17,teff:13000},{type:18,teff:11800},
      {type:19,teff:10700},{type:20,teff:9480},{type:22,teff:8810},{type:25,teff:8160},
      {type:27,teff:7930},{type:30,teff:7020},{type:32,teff:6750},{type:35,teff:6530},
      {type:37,teff:6240},{type:40,teff:5930},{type:42,teff:5830},{type:44,teff:5740},
      {type:46,teff:5620},{type:50,teff:5240},{type:52,teff:5010},{type:54,teff:4560},
      {type:55,teff:4340},{type:57,teff:4040},{type:60,teff:3800},{type:61,teff:3680},
      {type:62,teff:3530},{type:63,teff:3380},{type:64,teff:3180},{type:65,teff:3030},
      {type:66,teff:2850}
    ],
    iii: [
      {type:40,teff:5910},{type:44,teff:5190},{type:46,teff:5050},{type:48,teff:4960},
      {type:50,teff:4810},{type:51,teff:4610},{type:52,teff:4500},{type:53,teff:4320},
      {type:54,teff:4080},{type:55,teff:3980},{type:60,teff:3820},{type:61,teff:3780},
      {type:62,teff:3710},{type:63,teff:3630},{type:64,teff:3560},{type:65,teff:3420},
      {type:66,teff:3250}
    ],
    i: [
      {type:9,teff:32500},{type:10,teff:26000},{type:11,teff:20700},{type:12,teff:17800},
      {type:13,teff:15600},{type:14,teff:13900},{type:15,teff:13400},{type:16,teff:12700},
      {type:17,teff:12000},{type:18,teff:11200},{type:19,teff:10500},{type:20,teff:9730},
      {type:21,teff:9230},{type:22,teff:9080},{type:25,teff:8510},{type:30,teff:7700},
      {type:32,teff:7170},{type:35,teff:6640},{type:38,teff:6100},{type:40,teff:5510},
      {type:43,teff:4980},{type:48,teff:4590},{type:50,teff:4420},{type:51,teff:4330},
      {type:52,teff:4260},{type:53,teff:4130},{type:55,teff:3850},{type:60,teff:3650},
      {type:61,teff:3550},{type:62,teff:3450},{type:63,teff:3200},{type:64,teff:2980}
    ]
  };

  // Port of getTempFromSpectralType(). Inputs are already known here
  // (integer spectral-type number and the lum-class string), so we apply the
  // same class-remapping rules and linear interpolation/extrapolation.
  // Returns a Number (Teff in Kelvin) or null (matching the AS null cases).
  function getTempFromSpectralType(spectralTypeNumber, lumClassStr) {
    var cls = String(lumClassStr).toLowerCase(); // "i" | "iii" | "v"

    // Class remaps from the source:
    if (cls === 'iv') { cls = 'v'; }
    else if (cls === 'ii') { cls = 'i'; }
    if (cls === 'iii' && spectralTypeNumber < 40) { cls = 'v'; }

    var tempsArray = TEMP_TABLES[cls];
    if (tempsArray === undefined) { return null; }

    var len = tempsArray.length;
    var i = 0;
    while (i < len) {
      if (spectralTypeNumber < tempsArray[i].type) { break; }
      i++;
    }
    var i1, i2;
    if (i === 0)        { i1 = 0;       i2 = 1; }
    else if (i === len) { i1 = len - 2; i2 = len - 1; }
    else                { i1 = i - 1;   i2 = i; }

    var m = (tempsArray[i2].teff - tempsArray[i1].teff) /
            (tempsArray[i2].type - tempsArray[i1].type);
    var b = tempsArray[i1].teff - m * tempsArray[i1].type;
    return m * spectralTypeNumber + b;
  }

  // Spectral-type letter for a given base (0..6). VERBATIM switch from source.
  var TYPE_LETTERS = ['O', 'B', 'A', 'F', 'G', 'K', 'M'];

  // Slider value -> displayed spectral-type code ("O0".."M9"),
  // matching SliderV3SpectralType.setValue() (precision 0).
  function spectralTypeCode(value) {
    if (value >= 0 && value < 70) {
      var letter = TYPE_LETTERS[Math.floor(value / 10)];
      return letter + String(value % 10);
    }
    if (value === 70) { return 'M9'; } // AS: "M" + (10 - 1/k) with prec 0 -> "M9"
    return '';
  }

  // =========================================================================
  // STATE  (single source of truth)
  // =========================================================================
  var INITIAL_STATE = {
    mode: 'continuous',                 // continuous | emission | absorption
    elements: {
      ihelium: false, helium: false, hydrogen: false,
      imetals: false, metals: false, molecules: false
    },
    lumClass: 5,                        // 1 | 3 | 5   (data values from source)
    spectralTypeNumber: 42,             // slider value 0..70 (default G2)
    temperature: null                   // last computed Teff (K); null until absorption
  };

  var state = cloneInitial();

  function cloneInitial() {
    return {
      mode: INITIAL_STATE.mode,
      elements: {
        ihelium: INITIAL_STATE.elements.ihelium,
        helium: INITIAL_STATE.elements.helium,
        hydrogen: INITIAL_STATE.elements.hydrogen,
        imetals: INITIAL_STATE.elements.imetals,
        metals: INITIAL_STATE.elements.metals,
        molecules: INITIAL_STATE.elements.molecules
      },
      lumClass: INITIAL_STATE.lumClass,
      spectralTypeNumber: INITIAL_STATE.spectralTypeNumber,
      temperature: INITIAL_STATE.temperature
    };
  }

  // Line thickness by luminosity class (I=1, III=2, V=3). From classChange().
  function lineThicknessFor(lumClass) {
    if (lumClass === 1) { return 1; }
    if (lumClass === 3) { return 2; }
    return 3; // class 5 (V), and the source default
  }

  // =========================================================================
  // DOM references
  // =========================================================================
  var canvas, ctx;
  var el = {}; // cached elements

  function grab() {
    canvas = document.getElementById('se-canvas');
    ctx = canvas.getContext('2d');

    el.continuous = document.getElementById('se-continuous');
    el.emission   = document.getElementById('se-emission');
    el.absorption = document.getElementById('se-absorption');

    el.class1 = document.getElementById('se-class1');
    el.class3 = document.getElementById('se-class3');
    el.class5 = document.getElementById('se-class5');

    el.slider = document.getElementById('se-spectraltype');
    el.typeValue = document.getElementById('se-type-value');
    el.tempEqn = document.getElementById('se-temp-eqn');

    el.lumFieldset = document.getElementById('se-lumclass-fieldset');
    el.typeFieldset = document.getElementById('se-spectraltype-fieldset');
    el.elementsFieldset = document.getElementById('se-elements-fieldset');
    el.elementsHint = document.getElementById('se-elements-hint');

    el.live = document.getElementById('se-live');

    el.checks = {
      ihelium: document.getElementById('se-ihelium'),
      helium: document.getElementById('se-helium'),
      hydrogen: document.getElementById('se-hydrogen'),
      imetals: document.getElementById('se-imetals'),
      metals: document.getElementById('se-metals'),
      molecules: document.getElementById('se-molecules')
    };
  }

  // =========================================================================
  // BUILD LINE SET  (port of createArrays() -> element/alpha/color arrays)
  // =========================================================================
  // Returns { lines: [{wavelength, alpha(0..100), color(int)}], aborted:bool }.
  function buildLineSet() {
    var lines = [];
    var num = state.spectralTypeNumber;
    var base = Math.floor(num / 10);

    // AS: switch(base){ ... default: return null } aborts createArrays at value 70.
    if (base > 6) {
      return { lines: lines, aborted: true };
    }

    var isEmission = (state.mode === 'emission');

    var keys = ['ihelium', 'helium', 'hydrogen', 'imetals', 'metals', 'molecules'];
    for (var k = 0; k < keys.length; k++) {
      var key = keys[k];
      if (!state.elements[key]) { continue; }

      var waves = ELEMENT_LINES[key];
      var strengthArr = lineStrength[ELEMENT_STRENGTH_KEY[key]];

      for (var i = 0; i < waves.length; i++) {
        var w = waves[i];
        var color, alpha;
        if (isEmission) {
          color = colorFromLength(w);
          alpha = 100;
        } else {
          color = 0;                       // black absorption line
          alpha = strengthArr[num];        // strength depends on spectral type
        }
        lines.push({ wavelength: w, alpha: alpha, color: color });
      }
    }
    return { lines: lines, aborted: false };
  }

  // =========================================================================
  // DRAWING  (canvas port of spectra.as)
  // =========================================================================
  function drawContinuousBackground() {
    // beginGradientFill across the 500px band (spectra.drawContinuous()).
    var grad = ctx.createLinearGradient(0, 0, BAND_W, 0);
    for (var i = 0; i < GRADIENT_STOPS.length; i++) {
      var frac = (GRADIENT_STOPS[i].w - 395) / 310; // matches AS ratio positions
      if (frac < 0) { frac = 0; }
      if (frac > 1) { frac = 1; }
      grad.addColorStop(frac, intToHex(GRADIENT_STOPS[i].color));
    }
    ctx.fillStyle = grad;
    ctx.fillRect(0, 0, BAND_W, BAND_H);
  }

  function drawEmissionBackground() {
    // spectra.drawEmission(): solid black background.
    ctx.fillStyle = '#000000';
    ctx.fillRect(0, 0, BAND_W, BAND_H);
  }

  // Port of spectra.drawColorLineAt(): clamp wavelength to [395,705] then draw a
  // vertical line at its x-position. Only called for alpha > 10 (drawColorSet()).
  function drawSpectralLine(line, thickness) {
    var w = line.wavelength;
    if (w >= 395 && w <= 705) { /* keep */ }
    else if (w < 400) { w = 400; }
    else { w = 700; }

    var x = xForWavelength(w);
    ctx.save();
    ctx.globalAlpha = Math.max(0, Math.min(100, line.alpha)) / 100;
    ctx.strokeStyle = intToHex(line.color);
    ctx.lineWidth = thickness;
    // Align to a crisp column but keep the exact stage x.
    ctx.beginPath();
    ctx.moveTo(x, 0);
    ctx.lineTo(x, BAND_H);
    ctx.stroke();
    ctx.restore();
  }

  function drawColorSet(lines, thickness) {
    // spectra.drawColorSet(): draw each line whose alpha > 10.
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].alpha > 10) {
        drawSpectralLine(lines[i], thickness);
      }
    }
  }

  // =========================================================================
  // RENDER  (port of makeSpectrum() + control enable/visibility)
  // =========================================================================
  function render() {
    // Clear the band.
    ctx.clearRect(0, 0, BAND_W, BAND_H);

    var thickness = lineThicknessFor(state.lumClass);

    if (state.mode === 'continuous') {
      setElementsEnabled(false);
      setLumClassEnabled(false);
      setSpectralTypeVisible(false);
      drawContinuousBackground();
    } else if (state.mode === 'emission') {
      setElementsEnabled(true);
      setLumClassEnabled(false);
      setSpectralTypeVisible(false);
      drawEmissionBackground();
      var em = buildLineSet();
      drawColorSet(em.lines, thickness);
    } else { // absorption
      setElementsEnabled(true);
      setLumClassEnabled(true);
      setSpectralTypeVisible(true);
      updateTemperature();     // sets state.temperature + readout (may abort at v=70)
      drawContinuousBackground();
      var ab = buildLineSet();
      drawColorSet(ab.lines, thickness);
    }

    // Draw a thin frame around the band for definition (non-semantic).
    ctx.save();
    ctx.strokeStyle = 'rgba(0,0,0,0.35)';
    ctx.lineWidth = 1;
    ctx.strokeRect(0.5, 0.5, BAND_W - 1, BAND_H - 1);
    ctx.restore();

    // Keep the slider's readout + spoken value in sync.
    syncSliderReadout();

    // Update the audio-only description.
    announce();
  }

  // ---- Control enable / visibility (checkState/radioState/tempState) --------
  function setElementsEnabled(enabled) {
    for (var key in el.checks) {
      if (el.checks.hasOwnProperty(key)) {
        el.checks[key].disabled = !enabled;
      }
    }
    el.elementsFieldset.classList.toggle('se-disabled', !enabled);
    el.elementsHint.textContent = enabled
      ? 'Select one or more sources of spectral lines.'
      : 'Available for Emission and Absorption spectra.';
  }

  function setLumClassEnabled(enabled) {
    el.class1.disabled = !enabled;
    el.class3.disabled = !enabled;
    el.class5.disabled = !enabled;
    el.lumFieldset.classList.toggle('se-disabled', !enabled);
  }

  function setSpectralTypeVisible(visible) {
    el.typeFieldset.hidden = !visible;
  }

  // ---- Temperature (port of the createArrays temperature branch) -----------
  function updateTemperature() {
    var num = state.spectralTypeNumber;
    var base = Math.floor(num / 10);
    if (base > 6) {
      // AS aborts createArrays here; temperature text is left unchanged.
      return;
    }
    var lumStr = (state.lumClass === 1) ? 'I' : (state.lumClass === 3) ? 'III' : 'V';
    var temp = getTempFromSpectralType(num, lumStr);
    if (temp === null || !isFinite(temp)) {
      state.temperature = null;
    } else {
      state.temperature = Math.floor(temp); // AS: String(Math.floor(temp)) + " K"
    }
    showTemperature();
  }

  // Render the temperature via MathJax (kl-unl.js helper) with a spoken form.
  function showTemperature() {
    var latex, spoken;
    if (state.temperature === null) {
      latex = '\\text{--}';
      spoken = 'Temperature unavailable';
    } else {
      latex = state.temperature + '\\ \\mathrm{K}';
      spoken = 'Temperature ' + state.temperature + ' kelvin';
    }
    if (typeof window.klunlShowEquation === 'function') {
      window.klunlShowEquation(['se-temp-eqn', '\\(' + latex + '\\)'], ['se-temp-sr', spoken]);
    } else if (el.tempEqn) {
      el.tempEqn.innerHTML = '\\(' + latex + '\\)';
    }
  }

  // ---- Slider readout -------------------------------------------------------
  function syncSliderReadout() {
    var code = spectralTypeCode(state.spectralTypeNumber);
    el.typeValue.textContent = code;

    // Fully-spoken accessible value (quantity + value + unit) for the slider.
    var vt = 'Spectral type ' + speakType(code);
    if (state.mode === 'absorption' && state.temperature !== null) {
      vt += ', temperature ' + state.temperature + ' kelvin';
    }
    el.slider.setAttribute('aria-valuetext', vt);
    el.slider.setAttribute('aria-valuenow', String(state.spectralTypeNumber));
  }

  // Turn "G2" into "G 2" so screen readers read the class letter then the digit.
  function speakType(code) {
    if (!code) { return 'unknown'; }
    return code.charAt(0) + ' ' + code.slice(1);
  }

  // =========================================================================
  // AUDIO-ONLY DESCRIPTION (aria-live)
  // =========================================================================
  function selectedElementNames() {
    var names = [];
    var keys = ['ihelium', 'helium', 'hydrogen', 'imetals', 'metals', 'molecules'];
    for (var i = 0; i < keys.length; i++) {
      if (state.elements[keys[i]]) { names.push(ELEMENT_LABELS[keys[i]]); }
    }
    return names;
  }

  // Names of elements that currently contribute at least one VISIBLE line
  // (alpha > 10), so the audio description matches what is actually drawn.
  function visibleElementNames() {
    var names = [];
    var num = state.spectralTypeNumber;
    var keys = ['ihelium', 'helium', 'hydrogen', 'imetals', 'metals', 'molecules'];
    for (var i = 0; i < keys.length; i++) {
      var key = keys[i];
      if (!state.elements[key]) { continue; }
      if (state.mode === 'emission') {
        names.push(ELEMENT_LABELS[key]); // emission lines are always full strength
      } else {
        var arr = lineStrength[ELEMENT_STRENGTH_KEY[key]];
        if (arr[num] > 10) { names.push(ELEMENT_LABELS[key]); }
      }
    }
    return names;
  }

  function listToText(names) {
    if (names.length === 0) { return 'none'; }
    return names.join(', ');
  }

  function announce() {
    var msg;
    if (state.mode === 'continuous') {
      msg = 'Continuous spectrum: a smooth rainbow from 400 to 700 nanometers, ' +
            'violet through red, with no spectral lines.';
    } else if (state.mode === 'emission') {
      var emNames = visibleElementNames();
      msg = 'Emission spectrum: bright colored lines on a black background. ' +
            'Elements shown: ' + listToText(emNames) + '.';
    } else {
      var code = spectralTypeCode(state.spectralTypeNumber);
      var lumStr = (state.lumClass === 1) ? 'one (I)' :
                   (state.lumClass === 3) ? 'three (III)' : 'five (V)';
      var tempTxt = (state.temperature !== null)
        ? state.temperature + ' kelvin' : 'unavailable';
      var abNames = visibleElementNames();
      msg = 'Absorption spectrum over a rainbow background. Spectral type ' +
            speakType(code) + ', luminosity class ' + lumStr +
            ', temperature ' + tempTxt + '. Dark absorption lines shown for: ' +
            listToText(abNames) + '.';
    }
    // Replace text so screen readers re-announce the change.
    el.live.textContent = msg;
  }

  // =========================================================================
  // EVENT WIRING
  // =========================================================================
  function wire() {
    // Spectrum mode radios (typeChange -> makeSpectrum).
    el.continuous.addEventListener('change', function () {
      if (el.continuous.checked) { state.mode = 'continuous'; render(); }
    });
    el.emission.addEventListener('change', function () {
      if (el.emission.checked) { state.mode = 'emission'; render(); }
    });
    el.absorption.addEventListener('change', function () {
      if (el.absorption.checked) { state.mode = 'absorption'; render(); }
    });

    // Element checkboxes (changeChecks -> createArrays + makeSpectrum).
    for (var key in el.checks) {
      if (el.checks.hasOwnProperty(key)) {
        (function (k) {
          el.checks[k].addEventListener('change', function () {
            state.elements[k] = el.checks[k].checked;
            render();
          });
        })(key);
      }
    }

    // Luminosity class radios (classChange -> lineThickness + makeSpectrum).
    el.class1.addEventListener('change', function () {
      if (el.class1.checked) { state.lumClass = 1; render(); }
    });
    el.class3.addEventListener('change', function () {
      if (el.class3.checked) { state.lumClass = 3; render(); }
    });
    el.class5.addEventListener('change', function () {
      if (el.class5.checked) { state.lumClass = 5; render(); }
    });

    // Spectral-type slider (changeSpectralType -> createArrays + makeSpectrum).
    el.slider.addEventListener('input', function () {
      state.spectralTypeNumber = parseInt(el.slider.value, 10);
      render();
    });

    // Mouse-wheel adjusts the focused slider (WCAG numeric-field requirement).
    el.slider.addEventListener('wheel', function (e) {
      if (document.activeElement !== el.slider) { return; }
      e.preventDefault();
      var step = (e.deltaY < 0) ? 1 : -1;
      var v = parseInt(el.slider.value, 10) + step;
      v = Math.max(0, Math.min(70, v));
      if (v !== state.spectralTypeNumber) {
        el.slider.value = String(v);
        state.spectralTypeNumber = v;
        render();
      }
    }, { passive: false });

    // Reset comes from the masthead component (bubbling 'sim-reset').
    document.addEventListener('sim-reset', function () {
      resetToInitial();
    });
  }

  function resetToInitial() {
    state = cloneInitial();

    el.continuous.checked = true;
    el.emission.checked = false;
    el.absorption.checked = false;

    el.class1.checked = false;
    el.class3.checked = false;
    el.class5.checked = true;

    for (var key in el.checks) {
      if (el.checks.hasOwnProperty(key)) {
        el.checks[key].checked = false;
      }
    }

    el.slider.value = String(state.spectralTypeNumber);

    render();
  }

  // =========================================================================
  // INIT
  // =========================================================================
  // MathJax (SVG output) tags its mjx-container elements with tabindex, which
  // would place display-only math in the keyboard tab order. Typeset math is
  // NOT interactive (WCAG rule 8b), so demote every container to tabindex="-1".
  // The right-click "Show Math As" menu still works with tabindex="-1".
  function demoteMathFromTabOrder(root) {
    var scope = root && root.querySelectorAll ? root : document;
    var nodes = scope.querySelectorAll('mjx-container');
    for (var i = 0; i < nodes.length; i++) {
      if (nodes[i].getAttribute('tabindex') !== '-1') {
        nodes[i].setAttribute('tabindex', '-1');
      }
    }
  }

  // Catch containers created by ANY typeset (ours or the foundation helper).
  function watchMath() {
    demoteMathFromTabOrder(document);
    if (!window.MutationObserver) { return; }
    var obs = new MutationObserver(function (mutations) {
      for (var m = 0; m < mutations.length; m++) {
        var added = mutations[m].addedNodes;
        for (var n = 0; n < added.length; n++) {
          var node = added[n];
          if (node.nodeType !== 1) { continue; }
          if (node.tagName && node.tagName.toLowerCase() === 'mjx-container') {
            node.setAttribute('tabindex', '-1');
          } else if (node.querySelectorAll) {
            demoteMathFromTabOrder(node);
          }
        }
      }
    });
    obs.observe(document.body, { childList: true, subtree: true });
  }

  // Redefine the foundation hook so MathJax's startup.ready re-typesets our
  // math once MathJax has finished loading.
  window.klunlInitEqn = function () {
    showTemperature();
    if (window.MathJax && window.MathJax.typesetPromise) {
      window.MathJax.typesetPromise().then(function () {
        demoteMathFromTabOrder(document);
      }).catch(function (err) { console.error(err); });
    }
  };

  function init() {
    grab();
    createLineArrays();          // build the line-strength arrays (verbatim)
    wire();
    watchMath();                 // keep typeset math out of the tab order
    // init() in the source: createLineArrays(); makeSpectrum();
    render();
    // Typeset any math already present (nm labels + temperature) if MathJax
    // is already available; otherwise startup.ready -> klunlInitEqn() handles it.
    if (window.MathJax && window.MathJax.typesetPromise) {
      window.MathJax.typesetPromise().then(function () {
        demoteMathFromTabOrder(document);
      }).catch(function (err) { console.error(err); });
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
