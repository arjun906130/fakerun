/**
 * score.js â€” Score and combo tracking system.
 * Manages real-time score, multiplier, clutch bonuses, and combo counter.
 */

import { CLUTCH_BONUS, BASE_SCORE_PER_SECOND } from "./constants_client.js";

export class ScoreTracker {
  constructor() { this.reset(); }

  reset() {
    this.score         = 0;
    this.multiplier    = 1.0;
    this.combo         = 0;
    this.comboTimer    = 0;
    this.comboDuration = 3.0;  // seconds before combo resets
    this.distance      = 0;
    this.sessionBest   = parseInt(localStorage.getItem("clutchrun_best") || "0", 10);
    this.isNewBest     = false;
  }

  update(dt, speed) {
    this.score    += BASE_SCORE_PER_SECOND * this.multiplier * speed * dt;
    this.distance += speed * dt;

    if (this.combo > 0) {
      this.comboTimer -= dt;
      if (this.comboTimer <= 0) this._resetCombo();
    }

    if (Math.floor(this.score) > this.sessionBest) {
      this.sessionBest = Math.floor(this.score);
      this.isNewBest   = true;
      localStorage.setItem("clutchrun_best", this.sessionBest);
    }
  }

  clutch() {
    this.score      += CLUTCH_BONUS * this.multiplier;
    this.combo++;
    this.comboTimer  = this.comboDuration;
    this.multiplier  = Math.min(10, 1 + this.combo * 0.5);
  }

  _resetCombo() { this.combo = 0; this.comboTimer = 0; this.multiplier = 1.0; }

  getDisplayScore()    { return Math.floor(this.score); }
  getMultiplierText()  { return `${this.multiplier.toFixed(1)}x`; }
  getDistanceText()    { return `${Math.floor(this.distance)}m`; }
  getRating() {
    const s = Math.floor(this.score);
    if (s >= 50000) return "S"; if (s >= 25000) return "A";
    if (s >= 10000) return "B"; if (s >= 5000)  return "C"; return "D";
  }
}
