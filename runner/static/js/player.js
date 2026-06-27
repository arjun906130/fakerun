/**
 * player.js â€” 3D player character mesh and lane management.
 * Owns the Three.js mesh for the runner and handles smooth lane transitions.
 */

import * as THREE from "three";

const LANE_X = [-2.5, 0, 2.5];
const LANE_TRANSITION_SPEED = 8; // units/s lateral speed

export class PlayerCharacter {
  constructor(scene) {
    this.scene      = scene;
    this.currentLane = 1;   // 0 = left, 1 = centre, 2 = right
    this.targetX    = LANE_X[1];
    this.mesh       = this._buildMesh();
    this.scene.add(this.mesh);
  }

  _buildMesh() {
    const group = new THREE.Group();
    // Body
    const body = new THREE.Mesh(
      new THREE.CapsuleGeometry(0.35, 0.8, 4, 8),
      new THREE.MeshStandardMaterial({ color: 0xffffff, emissive: 0xff3300, emissiveIntensity: 0.4 })
    );
    body.position.y = 0.9;
    group.add(body);
    group.position.set(LANE_X[1], 0, 0);
    return group;
  }

  moveLeft()  { if (this.currentLane > 0) { this.currentLane--; this.targetX = LANE_X[this.currentLane]; } }
  moveRight() { if (this.currentLane < 2) { this.currentLane++; this.targetX = LANE_X[this.currentLane]; } }

  update(dt, physicsY) {
    // Smooth lateral movement
    const dx = this.targetX - this.mesh.position.x;
    this.mesh.position.x += Math.sign(dx) * Math.min(Math.abs(dx), LANE_TRANSITION_SPEED * dt);
    // Sync vertical position from physics
    this.mesh.position.y = physicsY;
  }

  setSlideScale(sliding) {
    this.mesh.scale.y = sliding ? 0.5 : 1.0;
  }

  getLane() { return this.currentLane; }

  reset() {
    this.currentLane = 1;
    this.targetX     = LANE_X[1];
    this.mesh.position.set(LANE_X[1], 0, 0);
    this.mesh.scale.set(1, 1, 1);
  }
}
