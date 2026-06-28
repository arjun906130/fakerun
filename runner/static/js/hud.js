/**
 * hud.js â€” HUD (Heads-Up Display) DOM controller.
 * Handles all in-game UI updates: score, speed, multiplier, combo, clutch msg.
 */

export class HUDController {
  constructor() {
    this.scoreEl      = document.getElementById("score-display");
    this.speedEl      = document.getElementById("speed-display");
    this.multEl       = document.getElementById("multiplier-display");
    this.comboEl      = document.getElementById("combo-display");
    this.comboProgress= document.getElementById("combo-progress");
    this.comboHud     = document.getElementById("combo-hud");
    this.clutchMsg    = document.getElementById("clutch-msg");
    this.bestLabel    = document.getElementById("high-score-label");
    this._clutchTimeout = null;
  }

  update(scoreTracker, speed) {
    this.scoreEl.textContent = scoreTracker.getDisplayScore().toLocaleString();
    this.speedEl.textContent = Math.floor(speed);
    this.multEl.textContent  = scoreTracker.getMultiplierText();

    if (scoreTracker.combo > 0) {
      this.comboHud.style.opacity = "1";
      this.comboEl.textContent    = scoreTracker.combo;
      const pct = (scoreTracker.comboTimer / scoreTracker.comboDuration) * 100;
      this.comboProgress.style.width = `${pct}%`;
    } else {
      this.comboHud.style.opacity = "0";
    }

    this.bestLabel.style.opacity = scoreTracker.isNewBest ? "1" : "0";
  }

  flashClutch() {
    this.clutchMsg.style.opacity = "1";
    clearTimeout(this._clutchTimeout);
    this._clutchTimeout = setTimeout(() => { this.clutchMsg.style.opacity = "0"; }, 900);
  }

  showHUD()  { document.getElementById("hud").style.opacity = "1"; }
  hideHUD()  { document.getElementById("hud").style.opacity = "0"; }
}
