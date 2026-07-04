/**
 * renderer.js â€” Three.js WebGL renderer and camera setup.
 * Encapsulates renderer creation, camera positioning, and resize handling.
 */

import * as THREE from "three";

export class GameRenderer {
  constructor(container) {
    this.renderer = new THREE.WebGLRenderer({ antialias: true, alpha: false });
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.renderer.setSize(window.innerWidth, window.innerHeight);
    this.renderer.shadowMap.enabled = true;
    this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
    this.renderer.toneMappingExposure = 1.2;
    container.appendChild(this.renderer.domElement);

    this.camera  = new THREE.PerspectiveCamera(70, window.innerWidth / window.innerHeight, 0.1, 300);
    this.camera.position.set(0, 3.5, 7);
    this.camera.lookAt(0, 1, 0);

    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(0x050508);
    this.scene.fog = new THREE.Fog(0x050508, 30, 150);

    window.addEventListener("resize", () => this.onResize());
  }

  onResize() {
    this.camera.aspect = window.innerWidth / window.innerHeight;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(window.innerWidth, window.innerHeight);
  }

  render() { this.renderer.render(this.scene, this.camera); }

  getDomElement() { return this.renderer.domElement; }
  getScene()      { return this.scene; }
  getCamera()     { return this.camera; }
  getRenderer()   { return this.renderer; }
}
