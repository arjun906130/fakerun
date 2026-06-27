/**
 * obstacles.js â€” Procedural obstacle generation and collision detection.
 * Manages the lifecycle of all obstacle objects in the 3D scene.
 */

import * as THREE from "three";

const LANE_POSITIONS = [-2.5, 0, 2.5];  // X positions for left/centre/right lanes

export class ObstacleManager {
  constructor(scene) {
    this.scene     = scene;
    this.obstacles = [];
    this.spawnZ    = -80;
    this.despawnZ  = 6;
  }

  /** Spawns a new obstacle in a random lane. */
  spawn(speed) {
    const type = this._randomType();
    const lane = Math.floor(Math.random() * 3);
    const mesh = this._createMesh(type);
    mesh.position.set(LANE_POSITIONS[lane], type === "low" ? 0.5 : 1.5, this.spawnZ);
    mesh.userData = { type, lane, speed };
    this.scene.add(mesh);
    this.obstacles.push(mesh);
  }

  update(dt) {
    for (let i = this.obstacles.length - 1; i >= 0; i--) {
      const obs = this.obstacles[i];
      obs.position.z += obs.userData.speed * dt;
      if (obs.position.z > this.despawnZ) {
        this.scene.remove(obs);
        obs.geometry.dispose();
        this.obstacles.splice(i, 1);
      }
    }
  }

  checkCollision(playerLane, physics) {
    for (const obs of this.obstacles) {
      if (obs.position.z < 1 || obs.position.z > 3) continue;
      if (obs.userData.lane !== playerLane) continue;
      if (obs.userData.type === "low"  && !physics.isJumping())  return true;
      if (obs.userData.type === "high" && !physics.isSliding())  return true;
      if (obs.userData.type === "shard") return true;
    }
    return false;
  }

  reset() { this.obstacles.forEach(o => { this.scene.remove(o); o.geometry.dispose(); }); this.obstacles = []; }

  _randomType() { return ["low", "high", "shard"][Math.floor(Math.random() * 3)]; }

  _createMesh(type) {
    const colors = { low: 0xff2233, high: 0x00ffff, shard: 0xffaa00 };
    const geo = type === "shard"
      ? new THREE.OctahedronGeometry(0.7)
      : new THREE.BoxGeometry(1.8, type === "low" ? 1 : 2, 0.4);
    const mat = new THREE.MeshStandardMaterial({ color: colors[type], emissive: colors[type], emissiveIntensity: 0.6 });
    return new THREE.Mesh(geo, mat);
  }
}
