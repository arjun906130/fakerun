/**
 * touch.js â€” Mobile touch-zone overlay controller.
 * Creates transparent touch zones over the game canvas for swipe detection,
 * ensuring touch events are captured reliably across devices.
 */

export class TouchZoneController {
  constructor(onLeft, onRight, onJump, onSlide) {
    this.callbacks = { onLeft, onRight, onJump, onSlide };
    this._startX   = 0;
    this._startY   = 0;
    this._threshold = 35;
    this._zone = null;
  }

  mount() {
    this._zone = document.createElement("div");
    this._zone.className = "touch-zone";
    document.body.appendChild(this._zone);
    this._zone.addEventListener("touchstart", this._onStart.bind(this), { passive: true });
    this._zone.addEventListener("touchend",   this._onEnd.bind(this),   { passive: true });
  }

  unmount() { this._zone?.remove(); this._zone = null; }

  _onStart(e) {
    this._startX = e.changedTouches[0].clientX;
    this._startY = e.changedTouches[0].clientY;
  }

  _onEnd(e) {
    const dx = e.changedTouches[0].clientX - this._startX;
    const dy = e.changedTouches[0].clientY - this._startY;
    if (Math.abs(dx) < this._threshold && Math.abs(dy) < this._threshold) return;
    if (Math.abs(dx) > Math.abs(dy)) {
      dx < 0 ? this.callbacks.onLeft() : this.callbacks.onRight();
    } else {
      dy < 0 ? this.callbacks.onJump() : this.callbacks.onSlide();
    }
  }
}
