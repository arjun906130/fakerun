/**
 * profiler.js
 * -----------
 * Client-side performance monitoring utility for the Three.js engine.
 * Tracks FPS and frame delta to help identify performance bottlenecks.
 */

export class PerformanceProfiler {
    constructor() {
        this.fps = 0;
        this.frameTime = 0;
        this.lastTime = performance.now();
        this.frames = 0;
        this.active = true;
    }

    /**
     * Updates the profiler metrics. Should be called inside the main loop.
     */
    update() {
        if (!this.active) return;

        const time = performance.now();
        this.frames++;

        if (time >= this.lastTime + 1000) {
            this.fps = Math.round((this.frames * 1000) / (time - this.lastTime));
            this.frameTime = (time - this.lastTime) / this.frames;
            this.lastTime = time;
            this.frames = 0;

            if (this.fps < 30) {
                console.warn(`[Profiler] Low FPS detected: ${this.fps}`);
            }
        }
    }

    /**
     * Returns current performance stats.
     */
    getStats() {
        return {
            fps: this.fps,
            frameTime: this.frameTime.toFixed(2) + 'ms'
        };
    }
}
