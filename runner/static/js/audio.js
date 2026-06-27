/**
 * audio.js â€” Procedural sound engine for CLUTCH RUN.
 * Generates game sounds dynamically using the Web Audio API.
 * No external audio files required.
 */

export class AudioEngine {
  constructor() {
    this.ctx = null;
    this.masterGain = null;
    this.enabled = true;
  }

  /** Initialises the AudioContext on first user interaction. */
  init() {
    if (this.ctx) return;
    this.ctx = new (window.AudioContext || window.webkitAudioContext)();
    this.masterGain = this.ctx.createGain();
    this.masterGain.gain.value = 0.4;
    this.masterGain.connect(this.ctx.destination);
  }

  toggle() { this.enabled = !this.enabled; this.masterGain.gain.value = this.enabled ? 0.4 : 0; }

  _beep(freq, type, duration, vol = 0.3) {
    if (!this.ctx || !this.enabled) return;
    const osc  = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = type;
    osc.frequency.value = freq;
    gain.gain.setValueAtTime(vol, this.ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + duration);
    osc.connect(gain);
    gain.connect(this.masterGain);
    osc.start();
    osc.stop(this.ctx.currentTime + duration);
  }

  playJump()    { this._beep(440, "sine",     0.15, 0.25); }
  playSlide()   { this._beep(220, "sawtooth", 0.2,  0.2); }
  playClutch()  { this._beep(880, "square",   0.1,  0.4); this._beep(1100, "sine", 0.2, 0.3); }
  playCrash()   { this._beep(80,  "sawtooth", 0.5,  0.5); }
  playPowerup() { [440, 550, 660, 880].forEach((f, i) => setTimeout(() => this._beep(f, "sine", 0.12, 0.3), i * 60)); }
}
