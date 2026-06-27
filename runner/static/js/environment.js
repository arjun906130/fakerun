/**
 * environment.js â€” Procedural environment generation.
 * Handles the neon cityscape, grid floor, and atmospheric lighting.
 */

import * as THREE from "three";

export class EnvironmentManager {
  constructor(scene) {
    this.scene      = scene;
    this.buildings  = [];
    this.lanes      = [];
    this._buildFloor();
    this._buildLighting();
  }

  _buildFloor() {
    const geo = new THREE.PlaneGeometry(20, 300);
    const mat = new THREE.MeshStandardMaterial({
      color: 0x050510,
      emissive: 0x0a0a2a,
      emissiveIntensity: 0.3,
      roughness: 0.9,
    });
    const floor = new THREE.Mesh(geo, mat);
    floor.rotation.x = -Math.PI / 2;
    floor.position.z = -140;
    this.scene.add(floor);
  }

  _buildLighting() {
    const ambient = new THREE.AmbientLight(0x111133, 1.5);
    this.scene.add(ambient);
    const dirLight = new THREE.DirectionalLight(0xff3300, 2);
    dirLight.position.set(5, 10, 5);
    this.scene.add(dirLight);
    const rimLight = new THREE.DirectionalLight(0x00ffff, 1);
    rimLight.position.set(-5, 5, -10);
    this.scene.add(rimLight);
  }

  spawnBuilding() {
    const h   = THREE.MathUtils.randFloat(4, 20);
    const geo = new THREE.BoxGeometry(THREE.MathUtils.randFloat(1.5, 4), h, THREE.MathUtils.randFloat(1.5, 4));
    const mat = new THREE.MeshStandardMaterial({
      color: 0x0a0a1a,
      emissive: Math.random() > 0.5 ? 0xff3300 : 0x00ffff,
      emissiveIntensity: THREE.MathUtils.randFloat(0.1, 0.5),
    });
    const mesh = new THREE.Mesh(geo, mat);
    const side = Math.random() > 0.5 ? 1 : -1;
    mesh.position.set(side * THREE.MathUtils.randFloat(6, 14), h / 2, -80);
    this.scene.add(mesh);
    this.buildings.push(mesh);
  }

  update(dt, speed) {
    for (let i = this.buildings.length - 1; i >= 0; i--) {
      this.buildings[i].position.z += speed * dt * 0.6;
      if (this.buildings[i].position.z > 12) {
        this.scene.remove(this.buildings[i]);
        this.buildings[i].geometry.dispose();
        this.buildings.splice(i, 1);
      }
    }
  }

  reset() { this.buildings.forEach(b => { this.scene.remove(b); b.geometry.dispose(); }); this.buildings = []; }
}
