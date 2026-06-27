/**
 * physics.js â€” Simplified physics engine for player jump and slide mechanics.
 * Handles vertical movement, gravity, and state transitions.
 */

export class PhysicsEngine {
  constructor() {
    this.gravity       = -28;   // units/sÂ²
    this.jumpVelocity  =  10;   // initial upward velocity
    this.groundY       =  0;    // baseline Y position

    this.posY   = 0;
    this.velY   = 0;
    this.state  = "running";  // "running" | "jumping" | "sliding"
    this.slideTimer = 0;
    this.slideDuration = 0.6; // seconds
  }

  jump() {
    if (this.state === "running") {
      this.state = "jumping";
      this.velY  = this.jumpVelocity;
    }
  }

  slide() {
    if (this.state === "running") {
      this.state = "sliding";
      this.slideTimer = this.slideDuration;
    }
  }

  /**
   * Advances physics simulation by one frame.
   * @param {number} dt - Delta time in seconds since last frame.
   */
  update(dt) {
    if (this.state === "jumping") {
      this.velY  += this.gravity * dt;
      this.posY  += this.velY    * dt;
      if (this.posY <= this.groundY) {
        this.posY  = this.groundY;
        this.velY  = 0;
        this.state = "running";
      }
    } else if (this.state === "sliding") {
      this.slideTimer -= dt;
      if (this.slideTimer <= 0) this.state = "running";
    }
  }

  isJumping()  { return this.state === "jumping"; }
  isSliding()  { return this.state === "sliding"; }
  isRunning()  { return this.state === "running"; }
  reset()      { this.posY = 0; this.velY = 0; this.state = "running"; this.slideTimer = 0; }
}
