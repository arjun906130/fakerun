/**
 * controls.js â€” Unified keyboard and touch input handler for CLUTCH RUN.
 * Abstracts keyboard events and touch swipes into a single action callback.
 */

export class ControlsManager {
  /**
   * @param {object} callbacks - { onLeft, onRight, onJump, onSlide, onPause }
   */
  constructor(callbacks) {
    this.cb = callbacks;
    this._touchStartX = 0;
    this._touchStartY = 0;
    this._swipeThreshold = 40;
    this._keyHandler  = this._onKey.bind(this);
    this._touchStart  = this._onTouchStart.bind(this);
    this._touchEnd    = this._onTouchEnd.bind(this);
  }

  attach() {
    window.addEventListener("keydown", this._keyHandler);
    window.addEventListener("touchstart", this._touchStart, { passive: true });
    window.addEventListener("touchend",   this._touchEnd,   { passive: true });
  }

  detach() {
    window.removeEventListener("keydown", this._keyHandler);
    window.removeEventListener("touchstart", this._touchStart);
    window.removeEventListener("touchend",   this._touchEnd);
  }

  _onKey(e) {
    const map = {
      ArrowLeft: "onLeft",  a: "onLeft",  A: "onLeft",
      ArrowRight:"onRight", d: "onRight", D: "onRight",
      ArrowUp:   "onJump",  w: "onJump",  W: "onJump",
      ArrowDown: "onSlide", s: "onSlide", S: "onSlide",
      Escape:    "onPause", p: "onPause", P: "onPause",
    };
    const action = map[e.key];
    if (action && this.cb[action]) { e.preventDefault(); this.cb[action](); }
  }

  _onTouchStart(e) {
    this._touchStartX = e.changedTouches[0].clientX;
    this._touchStartY = e.changedTouches[0].clientY;
  }

  _onTouchEnd(e) {
    const dx = e.changedTouches[0].clientX - this._touchStartX;
    const dy = e.changedTouches[0].clientY - this._touchStartY;
    if (Math.abs(dx) < this._swipeThreshold && Math.abs(dy) < this._swipeThreshold) return;
    if (Math.abs(dx) > Math.abs(dy)) {
      dx < 0 ? this.cb.onLeft?.() : this.cb.onRight?.();
    } else {
      dy < 0 ? this.cb.onJump?.() : this.cb.onSlide?.();
    }
  }
}
