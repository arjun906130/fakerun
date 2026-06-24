import * as THREE from 'three';
import { EffectComposer } from 'three/addons/postprocessing/EffectComposer.js';
import { RenderPass } from 'three/addons/postprocessing/RenderPass.js';
import { UnrealBloomPass } from 'three/addons/postprocessing/UnrealBloomPass.js';

class Game {
    constructor() {
        this.score = 0;
        this.distance = 0;
        this.multiplier = 1.0;
        this.speed = 0.35;
        this.targetSpeed = 0.35;
        this.clutchCooldown = 0;
        this.isRunning = false;
        this.isPaused = false;
        this.difficulty = 'medium';
        this.combo = 0;
        this.comboTimeout = 0;
        this.isSliding = false;
        this.isJumping = false;
        this.currentLane = 0;
        this.lanes = [-4, 0, 4];
        this.obstacles = [];
        this.powerups = [];
        this.buildings = [];
        this.particles = [];
        this.hasShield = false;
        this.shieldVisual = null;
        this.sessionHighScore = 0;
        this.isNewRecord = false;
        this.audioEnabled = true;
        this.nextMilestone = 60;
        this.clock = new THREE.Clock();
        
        this.init();
        this.setupEvents();
        this.loadLeaderboard();
        
        // Remove loader
        setTimeout(() => {
            const loader = document.getElementById('loader');
            if (loader) {
                loader.style.opacity = '0';
                setTimeout(() => loader.style.display = 'none', 1000);
            }
        }, 1500);
    }

    /**
     * Initialize the game engine, Three.js scene, and start the animation loop.
     */
    init() {
        // Scene setup
        this.scene = new THREE.Scene();
        this.scene.background = new THREE.Color(0x020205);
        this.scene.fog = new THREE.Fog(0x020205, 20, 90);

        // Camera
        this.camera = new THREE.PerspectiveCamera(70, window.innerWidth / window.innerHeight, 0.1, 1000);
        this.camera.position.set(0, 4.5, 9);
        this.camera.lookAt(0, 2, -5);

        // Renderer
        this.renderer = new THREE.WebGLRenderer({ antialias: false, powerPreference: "high-performance" });
        this.renderer.setSize(window.innerWidth, window.innerHeight);
        this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
        this.renderer.toneMapping = THREE.ReinhardToneMapping;
        document.body.appendChild(this.renderer.domElement);

        // Post Processing (BLOOM)
        const renderScene = new RenderPass(this.scene, this.camera);
        this.bloomPass = new UnrealBloomPass(new THREE.Vector2(window.innerWidth, window.innerHeight), 1.5, 0.4, 0.85);
        this.bloomPass.threshold = 0.2;
        this.bloomPass.strength = 1.2;
        this.bloomPass.radius = 0.5;

        this.composer = new EffectComposer(this.renderer);
        this.composer.addPass(renderScene);
        this.composer.addPass(this.bloomPass);

        // Lights
        const ambientLight = new THREE.AmbientLight(0x404040, 1);
        this.scene.add(ambientLight);

        this.mainLight = new THREE.PointLight(0x00ffff, 2, 50);
        this.mainLight.position.set(0, 10, 0);
        this.scene.add(this.mainLight);

        // Objects
        this.createPlayer();
        this.createTrack();
        this.createBackground();

        this.animate();
    }

    createPlayer() {
        // Ship Group
        this.playerGroup = new THREE.Group();
        this.scene.add(this.playerGroup);

        // Main Body
        const bodyGeo = new THREE.BoxGeometry(1.2, 0.4, 2.5);
        const bodyMat = new THREE.MeshPhongMaterial({ color: 0x111111, shininess: 100 });
        this.playerBody = new THREE.Mesh(bodyGeo, bodyMat);
        this.playerGroup.add(this.playerBody);

        // Wings
        const wingGeo = new THREE.BoxGeometry(3, 0.1, 1);
        const wingMat = new THREE.MeshPhongMaterial({ color: 0x333333 });
        const wings = new THREE.Mesh(wingGeo, wingMat);
        wings.position.z = 0.2;
        this.playerGroup.add(wings);

        // Cockpit
        const cockpitGeo = new THREE.SphereGeometry(0.5, 16, 16, 0, Math.PI * 2, 0, Math.PI / 2);
        const cockpitMat = new THREE.MeshPhongMaterial({ color: 0x00aaff, transparent: true, opacity: 0.7, emissive: 0x0044ff });
        const cockpit = new THREE.Mesh(cockpitGeo, cockpitMat);
        cockpit.position.set(0, 0.2, 0);
        cockpit.scale.set(1, 1, 1.5);
        this.playerGroup.add(cockpit);

        // Thrusters (Glow)
        const thrusterGeo = new THREE.CylinderGeometry(0.3, 0.3, 0.5, 16);
        const thrusterMat = new THREE.MeshBasicMaterial({ color: 0x00ffff });
        this.thrusterL = new THREE.Mesh(thrusterGeo, thrusterMat);
        this.thrusterL.rotation.x = Math.PI / 2;
        this.thrusterL.position.set(-0.4, 0, 1.3);
        this.playerGroup.add(this.thrusterL);

        this.thrusterR = this.thrusterL.clone();
        this.thrusterR.position.x = 0.4;
        this.playerGroup.add(this.thrusterR);

        this.playerGroup.position.y = 1;
        
        // Tilt group for animations
        this.playerTilt = new THREE.Group();
        this.playerTilt.add(this.playerGroup);
        this.scene.add(this.playerTilt);

        // Shield Visual (Start hidden)
        const shieldGeo = new THREE.IcosahedronGeometry(2, 2);
        const shieldMat = new THREE.MeshBasicMaterial({ color: 0x00ff88, wireframe: true, transparent: true, opacity: 0 });
        this.shieldVisual = new THREE.Mesh(shieldGeo, shieldMat);
        this.playerTilt.add(this.shieldVisual);
    }

    createTrack() {
        // Procedural floor with shader-like grid
        const floorGeo = new THREE.PlaneGeometry(12, 200, 1, 100);
        const floorMat = new THREE.MeshStandardMaterial({ 
            color: 0x050510,
            metalness: 0.9,
            roughness: 0.1,
            emissive: 0x001122
        });
        this.floor = new THREE.Mesh(floorGeo, floorMat);
        this.floor.rotation.x = -Math.PI / 2;
        this.floor.position.z = -50;
        this.scene.add(this.floor);

        // Grid Lines
        const grid = new THREE.GridHelper(200, 40, 0x00ffff, 0x002244);
        grid.position.y = 0.05;
        grid.position.z = -50;
        this.scene.add(grid);
        this.grid = grid;
    }

    createBackground() {
        // Distant Cyber Towers
        for (let i = 0; i < 40; i++) {
            this.spawnBuilding(true);
        }
    }

    spawnBuilding(isInitial = false) {
        const h = 10 + Math.random() * 40;
        const w = 4 + Math.random() * 8;
        const color = new THREE.Color().setHSL(Math.random() * 0.1 + 0.5, 0.8, 0.5);
        
        const geo = new THREE.BoxGeometry(w, h, w);
        const mat = new THREE.MeshStandardMaterial({ 
            color: 0x0a0a0a,
            emissive: color,
            emissiveIntensity: 0.2
        });
        
        const b = new THREE.Mesh(geo, mat);
        const side = Math.random() > 0.5 ? 1 : -1;
        b.position.set(side * (15 + Math.random() * 20), h/2, isInitial ? -(Math.random() * 200) : -200);
        
        // Add neon windows
        const windowGeo = new THREE.PlaneGeometry(0.4, 0.4);
        const windowMat = new THREE.MeshBasicMaterial({ color: color });
        for(let j=0; j<5; j++) {
            const win = new THREE.Mesh(windowGeo, windowMat);
            win.position.set(side === 1 ? -w/2 - 0.1 : w/2 + 0.1, Math.random() * h - h/2, Math.random() * w - w/2);
            win.rotation.y = side === 1 ? -Math.PI/2 : Math.PI/2;
            b.add(win);
        }

        this.scene.add(b);
        this.buildings.push(b);
    }

    spawnParticle() {
        const geo = new THREE.BoxGeometry(0.1, 0.1, 0.1);
        const mat = new THREE.MeshBasicMaterial({ color: 0x00ffff, transparent: true, opacity: 0.8 });
        const p = new THREE.Mesh(geo, mat);
        
        p.position.copy(this.playerGroup.position);
        p.position.z += 1.5;
        p.position.x += (Math.random() - 0.5) * 0.4;
        p.position.y += (Math.random() - 0.5) * 0.2;
        
        this.scene.add(p);
        this.particles.push({ mesh: p, life: 1.0 });
    }

    setupEvents() {
        window.addEventListener('resize', () => {
            this.camera.aspect = window.innerWidth / window.innerHeight;
            this.camera.updateProjectionMatrix();
            this.renderer.setSize(window.innerWidth, window.innerHeight);
            this.composer.setSize(window.innerWidth, window.innerHeight);
        });

        window.addEventListener('keydown', (e) => {
            if (!this.isRunning) return;
            if (e.key === 'ArrowLeft' || e.key === 'a') this.moveLane(-1);
            if (e.key === 'ArrowRight' || e.key === 'd') this.moveLane(1);
            if (e.key === 'ArrowUp' || e.key === 'w') this.jump();
            if (e.key === 'ArrowDown' || e.key === 's') this.slide();
            if (e.key === 'Escape') this.togglePause();
        });

        // Swipe
        let startX, startY;
        window.addEventListener('touchstart', e => {
            startX = e.touches[0].clientX;
            startY = e.touches[0].clientY;
        });
        window.addEventListener('touchend', e => {
            if (!this.isRunning) return;
            const dx = e.changedTouches[0].clientX - startX;
            const dy = e.changedTouches[0].clientY - startY;
            if (Math.abs(dx) > Math.abs(dy)) {
                if (dx > 40) this.moveLane(1); else if (dx < -40) this.moveLane(-1);
            } else {
                if (dy < -40) this.jump(); else if (dy > 40) this.slide();
            }
        });

        document.getElementById('start-btn').onclick = () => this.startGame();
        document.getElementById('restart-btn').onclick = () => this.startGame();
        document.getElementById('resume-btn').onclick = () => this.togglePause();
        document.getElementById('pause-back-btn').onclick = () => this.quitToMenu();
        document.getElementById('back-btn').onclick = () => this.quitToMenu();

        // Difficulty buttons
        const diffBtns = document.querySelectorAll('.diff-btn');
        diffBtns.forEach(btn => {
            btn.onclick = () => {
                this.difficulty = btn.dataset.diff;
                diffBtns.forEach(b => {
                    b.classList.remove('border-2', 'bg-red-600/20', 'border-red-500/50', 'opacity-100');
                    b.classList.add('bg-white/5', 'border-white/10', 'opacity-60');
                });
                btn.classList.add('border-2', 'bg-red-600/20', 'border-red-500/50', 'opacity-100');
                btn.classList.remove('bg-white/5', 'border-white/10', 'opacity-60');
            };
        });

        // Bloom toggle
        const bloomToggle = document.getElementById('bloom-toggle');
        const bloomKnob = document.getElementById('bloom-knob');
        if (bloomToggle) {
            bloomToggle.onchange = () => {
                const enabled = bloomToggle.checked;
                this.bloomPass.enabled = enabled;
                if (enabled) {
                    bloomKnob.classList.add('translate-x-4');
                    bloomKnob.classList.remove('translate-x-0', 'bg-gray-500');
                    bloomKnob.classList.add('bg-cyan-500');
                } else {
                    bloomKnob.classList.remove('translate-x-4', 'bg-cyan-500');
                    bloomKnob.classList.add('translate-x-0', 'bg-gray-500');
                }
            };
        }

        // Sound toggle
        const soundBtn = document.createElement('button');
        soundBtn.id = 'sound-toggle';
        soundBtn.className = 'fixed bottom-6 right-6 z-50 glass p-3 rounded-full hover:bg-white/10 transition-all';
        soundBtn.innerHTML = '🔊';
        soundBtn.onclick = () => {
            this.audioEnabled = !this.audioEnabled;
            soundBtn.innerHTML = this.audioEnabled ? '🔊' : '🔇';
        };
        document.body.appendChild(soundBtn);
    }

    /**
     * Core sound generator using Web Audio API.
     * @param {number} freq - Tone frequency
     * @param {string} type - Waveform type
     * @param {number} duration - Playtime in seconds
     * @param {number} volume - Volume gain
     */
    playSound(freq, type = 'square', duration = 0.1, volume = 0.1) {
        if (!this.audioEnabled) return;
        const ctx = new (window.AudioContext || window.webkitAudioContext)();
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        
        osc.type = type;
        osc.frequency.setValueAtTime(freq, ctx.currentTime);
        
        gain.gain.setValueAtTime(volume, ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.0001, ctx.currentTime + duration);
        
        osc.connect(gain);
        gain.connect(ctx.destination);
        
        osc.start();
        osc.stop(ctx.currentTime + duration);
    }

    /**
     * Toggles play/pause state and updates UI accordingly.
     */
    togglePause() {
        if (!this.isRunning && !this.isPaused) return;
        
        if (this.isPaused) {
            this.isPaused = false;
            this.isRunning = true;
            document.getElementById('pause-menu').classList.add('hidden');
        } else {
            this.isPaused = true;
            this.isRunning = false;
            document.getElementById('pause-menu').classList.remove('hidden');
        }
    }

    quitToMenu() {
        this.isRunning = false;
        this.isPaused = false;
        document.getElementById('pause-menu').classList.add('hidden');
        document.getElementById('game-over').classList.add('hidden');
        document.getElementById('main-menu').classList.remove('hidden');
        document.getElementById('hud').style.opacity = '0';
        this.obstacles.forEach(o => this.scene.remove(o));
        this.powerups.forEach(p => this.scene.remove(p));
        this.obstacles = [];
        this.powerups = [];
    }

    /**
     * Resets game state and hides menus to start a new run.
     */
    startGame() {
        this.playSound(440, 'square', 0.2);
        setTimeout(() => this.playSound(880, 'square', 0.4), 100);
        
        this.isRunning = true;
        this.score = 0;
        this.distance = 0;
        this.multiplier = 1.0;
        
        // Difficulty adjustments
        const configs = {
            'easy': { speed: 0.35, spawnRate: 0.015, speedInc: 0.00001 },
            'medium': { speed: 0.5, spawnRate: 0.025, speedInc: 0.00003 },
            'hard': { speed: 0.7, spawnRate: 0.04, speedInc: 0.00008 }
        };
        const config = configs[this.difficulty];
        this.speed = config.speed;
        this.spawnRate = config.spawnRate;
        this.speedInc = config.speedInc;

        this.currentLane = 0;
        this.playerGroup.position.set(0, 1, 0);
        this.obstacles.forEach(o => this.scene.remove(o));
        this.powerups.forEach(p => this.scene.remove(p));
        this.obstacles = [];
        this.powerups = [];
        this.hasShield = false;
        if (this.shieldVisual) this.shieldVisual.material.opacity = 0;
        
        this.username = document.getElementById('username-input').value || 'PILOT';
        document.getElementById('main-menu').classList.add('hidden');
        document.getElementById('game-over').classList.add('hidden');
        document.getElementById('hud').style.opacity = '1';
    }

    triggerClutch() {
        this.playSound(1200, 'sine', 0.1, 0.2);
        this.clutchCooldown = 1.0;
        this.multiplier += 0.2;
        this.score += 1000;
        
        // Combo increment
        this.combo++;
        this.comboTimeout = 3.0; // 3 seconds to get next clutch
        document.getElementById('combo-hud').classList.remove('opacity-0');
        document.getElementById('combo-display').innerText = this.combo;
        gsap.fromTo('#combo-display', { scale: 1.5 }, { scale: 1, duration: 0.2 });

        // Visual Feedback
        const msg = document.getElementById('clutch-msg');
        msg.style.opacity = '1';
        msg.style.transform = 'translate(-50%, -20px) rotate(-5deg) scale(1.2) skewX(12deg)';
        
        // Shake Camera
        gsap.to(this.camera.position, {
            x: 0.5, yoyo: true, repeat: 5, duration: 0.05,
            onComplete: () => this.camera.position.x = 0
        });

        // Bloom punch
        this.bloomPass.strength = 3.0;
        gsap.to(this.bloomPass, { strength: 1.2, duration: 0.5 });

        setTimeout(() => {
            msg.style.opacity = '0';
            msg.style.transform = 'translate(-50%, 0) rotate(-1deg) skewX(12deg)';
        }, 800);
    }

    moveLane(dir) {
        const n = Math.max(-1, Math.min(1, this.currentLane + dir));
        if (n !== this.currentLane) {
            this.currentLane = n;
            gsap.to(this.playerGroup.position, { x: this.lanes[this.currentLane + 1], duration: 0.3, ease: "power2.out" });
            gsap.to(this.playerGroup.rotation, { z: -dir * 0.4, duration: 0.2, yoyo: true, repeat: 1 });
        }
    }

    jump() {
        if (this.isJumping || this.isSliding) return;
        this.playSound(300, 'triangle', 0.4);
        this.isJumping = true;
        gsap.to(this.playerGroup.position, {
            y: 4.5, duration: 0.4, ease: "power2.out",
            onComplete: () => {
                gsap.to(this.playerGroup.position, { y: 1, duration: 0.4, ease: "power2.in", onComplete: () => this.isJumping = false });
            }
        });
    }

    slide() {
        if (this.isSliding || this.isJumping) return;
        this.playSound(150, 'sawtooth', 0.4);
        this.isSliding = true;
        gsap.to(this.playerGroup.scale, { y: 0.3, duration: 0.2 });
        gsap.to(this.playerGroup.position, { y: 0.4, duration: 0.2 });
        
        setTimeout(() => {
            gsap.to(this.playerGroup.scale, { y: 1, duration: 0.2 });
            gsap.to(this.playerGroup.position, { y: 1, duration: 0.2, onComplete: () => this.isSliding = false });
        }, 800);
    }

    spawnObstacle() {
        const lane = Math.floor(Math.random() * 3) - 1;
        const type = Math.random();
        let obs;
        
        if (type < 0.4) { // Low bar (jump)
            obs = new THREE.Mesh(new THREE.BoxGeometry(4, 1.2, 0.8), new THREE.MeshStandardMaterial({ color: 0xff0055, emissive: 0xff0000 }));
            obs.position.set(this.lanes[lane + 1], 0.6, -100);
        } else if (type < 0.7) { // High bar (slide)
            obs = new THREE.Mesh(new THREE.BoxGeometry(4, 1.5, 0.8), new THREE.MeshStandardMaterial({ color: 0x00ffff, emissive: 0x0088ff }));
            obs.position.set(this.lanes[lane + 1], 3.5, -100);
            obs.isHigh = true;
        } else { // Center shard
            obs = new THREE.Mesh(new THREE.OctahedronGeometry(1.5), new THREE.MeshStandardMaterial({ color: 0xffcc00, emissive: 0xaa6600 }));
            obs.position.set(this.lanes[lane + 1], 1.5, -100);
        }

        this.scene.add(obs);
        this.obstacles.push(obs);
    }

    spawnPowerup() {
        const lane = Math.floor(Math.random() * 3) - 1;
        const color = 0x00ff88;
        
        const core = new THREE.Group();
        const geo = new THREE.SphereGeometry(0.8, 16, 16);
        const mat = new THREE.MeshStandardMaterial({ color: color, emissive: color, emissiveIntensity: 2 });
        const mesh = new THREE.Mesh(geo, mat);
        core.add(mesh);

        // Glow ring
        const ringGeo = new THREE.TorusGeometry(1.2, 0.05, 16, 32);
        const ringMat = new THREE.MeshBasicMaterial({ color: color });
        const ring = new THREE.Mesh(ringGeo, ringMat);
        ring.rotation.x = Math.PI / 2;
        core.add(ring);

        core.position.set(this.lanes[lane + 1], 1.5, -100);
        this.scene.add(core);
        this.powerups.push(core);
    }

    update(delta) {
        if (!this.isRunning) return;

        this.speed += this.speedInc;
        const moveDist = this.speed * 80 * delta;
        this.distance += moveDist * 0.1;
        this.score += moveDist * this.multiplier;

        // HUD
        const currentScore = Math.floor(this.score);
        document.getElementById('score-display').innerText = currentScore;
        
        if (currentScore > this.sessionHighScore && currentScore > 0) {
            if (!this.isNewRecord) {
                this.isNewRecord = true;
                const label = document.getElementById('high-score-label');
                label.classList.remove('opacity-0');
                gsap.fromTo(label, { scale: 0 }, { scale: 1, duration: 0.3, ease: 'back.out' });
            }
            this.sessionHighScore = currentScore;
        }

        document.getElementById('multiplier-display').innerText = this.multiplier.toFixed(1) + 'x';
        document.getElementById('speed-display').innerText = Math.floor(this.speed * 100);

        // Speed Milestone Flash
        if (this.speed * 100 > this.nextMilestone) {
            this.nextMilestone += 10;
            this.bloomPass.strength = 5.0;
            gsap.to(this.bloomPass, { strength: 1.2, duration: 1.0 });
            this.playSound(1500, 'sine', 0.5, 0.1);
        }

        // Combo timeout check
        if (this.comboTimeout > 0) {
            this.comboTimeout -= delta;
            if (this.comboTimeout <= 0) {
                this.combo = 0;
                document.getElementById('combo-hud').classList.add('opacity-0');
            }
        }

        // Infinite Track Illusion
        this.grid.position.z += moveDist;
        if (this.grid.position.z > 5) this.grid.position.z = 0;

        // Obstacles
        if (this.clutchCooldown > 0) this.clutchCooldown -= delta;
        
        for (let i = this.obstacles.length - 1; i >= 0; i--) {
            const o = this.obstacles[i];
            o.position.z += moveDist;
            o.rotation.x += delta;

            const dx = Math.abs(o.position.x - this.playerGroup.position.x);
            const dz = Math.abs(o.position.z - this.playerGroup.position.z);
            const dy = Math.abs(o.position.y - this.playerGroup.position.y);

            // 1. COLLISION CHECK (More forgiving hitboxes for Medium level)
            if (dx < 1.1 && dz < 0.9) {
                if (o.isHigh && this.isSliding) {
                    // Safe!
                } else if (!o.isHigh && this.isJumping && o.position.y < 2) {
                    // Safe!
                } else {
                    this.gameOver();
                }
            }
            
            // 2. CLUTCH (NEAR MISS) CHECK
            if (dx < 2.2 && dz < 1.2 && this.clutchCooldown <= 0) {
                this.triggerClutch();
            }

            if (o.position.z > 15) {
                this.scene.remove(o);
                this.obstacles.splice(i, 1);
            }
        }

        // Powerups
        for (let i = this.powerups.length - 1; i >= 0; i--) {
            const p = this.powerups[i];
            p.position.z += moveDist;
            p.rotation.y += delta * 2;

            const dx = Math.abs(p.position.x - this.playerGroup.position.x);
            const dz = Math.abs(p.position.z - this.playerGroup.position.z);
            const dy = Math.abs(p.position.y - this.playerGroup.position.y);

            if (dx < 2 && dz < 1.5) {
                this.collectPowerup();
                this.scene.remove(p);
                this.powerups.splice(i, 1);
            } else if (p.position.z > 15) {
                this.scene.remove(p);
                this.powerups.splice(i, 1);
            }
        }

        // Buildings
        for (let i = this.buildings.length - 1; i >= 0; i--) {
            const b = this.buildings[i];
            b.position.z += moveDist * 0.5; // Parallax
            if (b.position.z > 30) {
                this.scene.remove(b);
                this.buildings.splice(i, 1);
                this.spawnBuilding();
            }
        }

        if (Math.random() < this.spawnRate) this.spawnObstacle(); 
        if (Math.random() < 0.005) this.spawnPowerup(); // Rare powerup spawn

        // Animation effects
        this.thrusterL.scale.y = 1 + Math.random();
        this.thrusterR.scale.y = 1 + Math.random();
        this.playerGroup.position.y += Math.sin(Date.now() * 0.01) * 0.005; // Hover wobble
        this.camera.position.y = 4.5 + Math.sin(Date.now() * 0.005) * 0.1; // Camera breathing
        
        // Dynamic FOV based on speed
        this.camera.fov = 70 + (this.speed * 10);
        this.camera.updateProjectionMatrix();

        this.mainLight.position.x = this.playerGroup.position.x;

        // Particles
        this.spawnParticle();
        for (let i = this.particles.length - 1; i >= 0; i--) {
            const p = this.particles[i];
            p.life -= delta * 2;
            p.mesh.position.z += moveDist * 0.2;
            p.mesh.scale.setScalar(p.life);
            p.mesh.material.opacity = p.life;
            
            if (p.life <= 0) {
                this.scene.remove(p.mesh);
                this.particles.splice(i, 1);
            }
        }

        if (this.hasShield) {
            this.shieldVisual.rotation.y += delta * 5;
            this.shieldVisual.rotation.x += delta * 2;
            this.shieldVisual.position.copy(this.playerGroup.position);
        }
    }

    collectPowerup() {
        this.playSound(800, 'sine', 0.5, 0.2);
        setTimeout(() => this.playSound(1000, 'sine', 0.5, 0.2), 100);
        
        this.hasShield = true;
        this.multiplier += 0.5;
        this.score += 5000;
        
        // Visuals
        this.shieldVisual.material.opacity = 0.4;
        this.bloomPass.strength = 4.0;
        gsap.to(this.bloomPass, { strength: 1.2, duration: 1.0 });

        // Shake Camera
        gsap.to(this.camera.position, {
            x: 0.2, yoyo: true, repeat: 3, duration: 0.05,
            onComplete: () => this.camera.position.x = 0
        });

        const msg = document.getElementById('clutch-msg');
        const originalText = msg.innerText;
        msg.innerText = "SHIELD ACTIVATED!";
        msg.style.color = "#00ff88";
        msg.style.opacity = '1';
        
        setTimeout(() => {
            msg.style.opacity = '0';
            setTimeout(() => {
                msg.innerText = "CLUTCH!";
                msg.style.color = "";
            }, 500);
        }, 1500);
    }

    gameOver() {
        if (this.hasShield) {
            this.playSound(200, 'sawtooth', 0.3, 0.4);
            this.hasShield = false;
            this.shieldVisual.material.opacity = 0;
            // Explosion or break effect
            this.bloomPass.strength = 5.0;
            gsap.to(this.bloomPass, { strength: 1.2, duration: 0.5 });
            
            // Shake
            gsap.to(this.camera.position, {
                x: 1, yoyo: true, repeat: 10, duration: 0.03,
                onComplete: () => this.camera.position.x = 0
            });

            // Temporary invincibility
            this.clutchCooldown = 1.0;
            return;
        }
        this.playSound(100, 'sawtooth', 0.8, 0.3);
        
        // Heavy Shake
        gsap.to(this.camera.position, {
            x: 2, y: 6, yoyo: true, repeat: 20, duration: 0.02,
            onComplete: () => {
                this.camera.position.x = 0;
                this.camera.position.y = 4.5;
            }
        });

        this.isRunning = false;
        document.getElementById('game-over').classList.remove('hidden');
        document.getElementById('final-score').innerText = Math.floor(this.score);
        document.getElementById('final-distance').innerText = Math.floor(this.distance) + 'm';
        this.submitScore();
    }

    async submitScore() {
        fetch('/api/submit-score/', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ username: this.username, score: Math.floor(this.score) })
        }).then(() => this.loadLeaderboard());
    }

    async loadLeaderboard() {
        fetch('/api/leaderboard/').then(r => r.json()).then(data => {
            const container = document.getElementById('top-scores');
            container.innerHTML = data.leaderboard.map((s, i) => `
                <div class="flex justify-between items-center bg-white/5 p-2 rounded border border-white/5">
                    <span class="text-cyan-400 font-bold w-6">#${i+1}</span>
                    <span class="flex-1 px-2 truncate">${s.username}</span>
                    <span class="font-mono text-pink-500">${s.score}</span>
                </div>
            `).join('');
        });
    }

    animate() {
        requestAnimationFrame(() => this.animate());
        const delta = this.clock.getDelta();
        this.update(delta);
        this.composer.render();
    }
}

new Game();
