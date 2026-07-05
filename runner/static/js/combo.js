/**
 * combo.js â€” Combo multiplier visual feedback controller.
 * Drives the combo HUD bar, colour transitions, and decay animation.
 */

export class ComboVisuals {
  constructor() {
    this.hud      = document.getElementById("combo-hud");
    this.display  = document.getElementById("combo-display");
    this.bar      = document.getElementById("combo-progress");
    this._prevCombo = 0;
  }

  update(combo, timerRatio) {
    if (combo > 0) {
      this.hud.style.opacity = "1";
      this.display.textContent = combo;

      // Colour transitions: cyan â†’ yellow â†’ orange â†’ red as combo grows
      const colours = ["#22d3ee", "#facc15", "#fb923c", "#ef4444", "#dc2626"];
      const idx = Math.min(colours.length - 1, Math.floor((combo - 1) / 3));
      this.bar.style.background = colours[idx];
      this.bar.style.width = `${timerRatio * 100}%`;

      // Pulse on new combo increment
      if (combo > this._prevCombo) {
        this.display.style.transform = "scale(1.4)";
        setTimeout(() => { this.display.style.transform = "scale(1)"; }, 150);
        this.display.style.transition = "transform 0.15s ease";
      }
    } else {
      this.hud.style.opacity = "0";
    }
    this._prevCombo = combo;
  }

  reset() { this._prevCombo = 0; this.hud.style.opacity = "0"; }
}
