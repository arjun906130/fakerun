/**
 * effects.js â€” Visual feedback effects: screen shake, flash, and death overlay.
 */

export class EffectsManager {
  constructor(renderer) {
    this.renderer     = renderer;
    this.shakeAmt     = 0;
    this.shakeDecay   = 0.85;
    this.originalPos  = { x: 0, y: 0 };
  }

  /** Triggers a screen shake of given intensity. */
  shake(intensity = 0.3) { this.shakeAmt = intensity; }

  /** Flashes the screen with a given CSS colour for a brief duration. */
  flash(color = "rgba(255,0,0,0.25)", duration = 150) {
    const overlay = document.createElement("div");
    Object.assign(overlay.style, {
      position: "fixed", inset: "0", background: color,
      pointerEvents: "none", zIndex: "200", transition: `opacity ${duration}ms`,
    });
    document.body.appendChild(overlay);
    requestAnimationFrame(() => {
      overlay.style.opacity = "0";
      setTimeout(() => overlay.remove(), duration);
    });
  }

  /** Advances shake simulation each frame. */
  update() {
    if (this.shakeAmt < 0.005) { this.shakeAmt = 0; return; }
    const canvas = this.renderer.domElement;
    canvas.style.transform = `translate(${(Math.random() - 0.5) * this.shakeAmt * 20}px, ${(Math.random() - 0.5) * this.shakeAmt * 20}px)`;
    this.shakeAmt *= this.shakeDecay;
    if (this.shakeAmt < 0.005) canvas.style.transform = "";
  }

  /** Resets all effects to neutral state. */
  reset() { this.shakeAmt = 0; this.renderer.domElement.style.transform = ""; }
}
