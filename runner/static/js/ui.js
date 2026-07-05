/**
 * ui.js â€” General-purpose UI utility functions.
 * Provides helpers for showing/hiding elements and animating transitions.
 */

/** Sets element opacity with a CSS transition. */
export function fadeIn(el, duration = 300) {
  if (!el) return;
  el.style.transition = `opacity ${duration}ms ease`;
  el.style.opacity    = "1";
}

export function fadeOut(el, duration = 300, callback) {
  if (!el) return;
  el.style.transition = `opacity ${duration}ms ease`;
  el.style.opacity    = "0";
  if (callback) setTimeout(callback, duration);
}

export function showEl(el)  { el?.classList.remove("hidden"); }
export function hideEl(el)  { el?.classList.add("hidden"); }
export function toggleEl(el){ el?.classList.toggle("hidden"); }

/**
 * Animates a number counter from current displayed value to target.
 * @param {HTMLElement} el     - DOM element whose textContent to animate.
 * @param {number}      target - Final numeric value.
 * @param {number}      duration - Animation duration in ms (default 800).
 */
export function animateCounter(el, target, duration = 800) {
  if (!el) return;
  const start    = parseInt(el.textContent.replace(/,/g, "") || "0", 10);
  const startTime = performance.now();
  function tick(now) {
    const t    = Math.min(1, (now - startTime) / duration);
    const ease = 1 - Math.pow(1 - t, 3); // ease-out cubic
    el.textContent = Math.floor(start + (target - start) * ease).toLocaleString();
    if (t < 1) requestAnimationFrame(tick);
  }
  requestAnimationFrame(tick);
}
