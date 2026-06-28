/**
 * powerups.js â€” Power-up (Energy Core) spawn and collection logic.
 * Energy Cores grant a temporary shield and multiplier boost.
 */

import * as THREE from "three";

const LANE_POSITIONS = [-2.5, 0, 2.5];

export class PowerUpManager {
  constructor(scene) {
    this.scene   = scene;
    this.items   = [];
    this.spawnZ  = -80;
  }

  /** Randomly spawns an Energy Core at a given speed. ~15% chance per call. */
  maybeSpawn(speed) {
    if (Math.random() > 0.15) return;
    const lane = Math.floor(Math.random() * 3);
    const geo  = new THREE.SphereGeometry(0.4, 16, 16);
    const mat  = new THREE.MeshStandardMaterial({
      color: 0x00ff88, emissive: 0x00ff88, emissiveIntensity: 1.5,
    });
    const mesh = new THREE.Mesh(geo, mat);
    mesh.position.set(LANE_POSITIONS[lane], 1.2, this.spawnZ);
    mesh.userData = { lane, speed };
    this.scene.add(mesh);
    this.items.push(mesh);
  }

  update(dt) {
    for (let i = this.items.length - 1; i >= 0; i--) {
      const item = this.items[i];
      item.position.z += item.userData.speed * dt;
      item.rotation.y += 2 * dt;
      if (item.position.z > 6) { this._remove(i); }
    }
  }

  checkCollection(playerLane) {
    for (let i = this.items.length - 1; i >= 0; i--) {
      const item = this.items[i];
      if (item.position.z > 1 && item.position.z < 3 && item.userData.lane === playerLane) {
        this._remove(i);
        return true;
      }
    }
    return false;
  }

  _remove(i) { this.scene.remove(this.items[i]); this.items[i].geometry.dispose(); this.items.splice(i, 1); }
  reset() { [...this.items].forEach((_, i) => this._remove(0)); }
}
