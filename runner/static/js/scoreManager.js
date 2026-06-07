/**
 * scoreManager.js
 * ---------------
 * Manages the local game score state, inclusive of combo multipliers
 * and high-score persistence calculation.
 */

export class ScoreManager {
    constructor() {
        this.score = 0;
        this.baseRate = 10;
        this.multiplier = 1.0;
        this.combo = 0;
    }

    /**
     * Resets the score state for a new run.
     */
    reset() {
        this.score = 0;
        this.multiplier = 1.0;
        this.combo = 0;
    }

    /**
     * Increments the score based on elapsed time and current multiplier.
     */
    addTimeScore(delta) {
        this.score += delta * this.baseRate * this.multiplier;
        return Math.floor(this.score);
    }

    /**
     * Adds a fixed bonus (e.g. for Clutch or Power-up).
     */
    addBonus(points) {
        this.score += points * this.multiplier;
        return Math.floor(this.score);
    }

    /**
     * Increments the combo, affecting the multiplier.
     */
    incrementCombo() {
        this.combo++;
        this.multiplier = 1.0 + (this.combo * 0.05);
        return this.multiplier;
    }

    /**
     * Breaks the current combo.
     */
    breakCombo() {
        this.combo = 0;
        this.multiplier = 1.0;
    }
}
