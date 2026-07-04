/**
 * settings.js â€” User preferences manager.
 * Persists and loads game settings (bloom, sound, difficulty) via localStorage.
 */

const STORAGE_KEY = "clutchrun_settings";

const DEFAULTS = {
  bloomEnabled:  true,
  soundEnabled:  true,
  difficulty:    "medium",
  username:      "",
};

export class SettingsManager {
  constructor() {
    this._settings = this._load();
  }

  _load() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      return raw ? { ...DEFAULTS, ...JSON.parse(raw) } : { ...DEFAULTS };
    } catch {
      return { ...DEFAULTS };
    }
  }

  _save() {
    try { localStorage.setItem(STORAGE_KEY, JSON.stringify(this._settings)); } catch { /* ignore */ }
  }

  get(key)        { return this._settings[key]; }
  set(key, value) { this._settings[key] = value; this._save(); }

  applyToUI() {
    const bloomToggle = document.getElementById("bloom-toggle");
    const usernameInput = document.getElementById("username-input");
    if (bloomToggle)    bloomToggle.checked = this._settings.bloomEnabled;
    if (usernameInput)  usernameInput.value  = this._settings.username;

    document.querySelectorAll(".diff-btn").forEach(btn => {
      const active = btn.dataset.diff === this._settings.difficulty;
      btn.classList.toggle("opacity-100", active);
      btn.classList.toggle("opacity-60",  !active);
      btn.classList.toggle("border-2",    active);
    });
  }

  readFromUI() {
    const bloomToggle   = document.getElementById("bloom-toggle");
    const usernameInput = document.getElementById("username-input");
    const selectedDiff  = document.querySelector(".diff-btn.opacity-100");
    if (bloomToggle)   this.set("bloomEnabled", bloomToggle.checked);
    if (usernameInput) this.set("username",     usernameInput.value.trim().toUpperCase());
    if (selectedDiff)  this.set("difficulty",   selectedDiff.dataset.diff);
  }
}
