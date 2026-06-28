/**
 * loader.js â€” Loading screen controller with simulated progress animation.
 * Provides a smooth percentage ramp-up while Three.js assets are being initialised.
 */

export class LoadingScreen {
  constructor() {
    this.el         = document.getElementById("loader");
    this.pctEl      = document.getElementById("load-pct");
    this.statusEl   = document.getElementById("loader-status");
    this._progress  = 0;
    this._interval  = null;
    this._steps = [
      [20,  "Loading Engine..."],
      [45,  "Building World..."],
      [65,  "Spawning Obstacles..."],
      [80,  "Syncing Leaderboard..."],
      [95,  "Charging Reactor..."],
      [100, "Ready"],
    ];
    this._stepIndex = 0;
  }

  start() {
    this._interval = setInterval(() => {
      if (this._stepIndex >= this._steps.length) { clearInterval(this._interval); return; }
      const [target, label] = this._steps[this._stepIndex];
      if (this._progress < target) {
        this._progress = Math.min(target, this._progress + 3);
        this.pctEl.textContent   = `${this._progress}%`;
        this.statusEl.textContent = label;
      } else {
        this._stepIndex++;
      }
    }, 40);
  }

  finish(callback) {
    this._progress = 100;
    this.pctEl.textContent    = "100%";
    this.statusEl.textContent = "Initialised";
    clearInterval(this._interval);
    setTimeout(() => {
      this.el.style.opacity = "0";
      setTimeout(() => { this.el.style.display = "none"; callback?.(); }, 600);
    }, 400);
  }
}
