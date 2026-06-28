/**
 * menu.js â€” Menu screen controller.
 * Handles main menu, game-over, and pause screen transitions + leaderboard rendering.
 */

import { fetchLeaderboard } from "./api.js";

export class MenuManager {
  constructor() {
    this.mainMenu   = document.getElementById("main-menu");
    this.gameOver   = document.getElementById("game-over");
    this.pauseMenu  = document.getElementById("pause-menu");
    this.topScores  = document.getElementById("top-scores");
  }

  showMainMenu()  { this.mainMenu.classList.remove("hidden");  this.gameOver.classList.add("hidden"); this.pauseMenu.classList.add("hidden"); }
  hideMainMenu()  { this.mainMenu.classList.add("hidden"); }
  showGameOver()  { this.gameOver.classList.remove("hidden"); }
  hideGameOver()  { this.gameOver.classList.add("hidden"); }
  showPause()     { this.pauseMenu.classList.remove("hidden"); }
  hidePause()     { this.pauseMenu.classList.add("hidden"); }

  populateGameOver(scoreTracker) {
    document.getElementById("final-score").textContent    = scoreTracker.getDisplayScore().toLocaleString();
    document.getElementById("final-distance").textContent = scoreTracker.getDistanceText();
    document.getElementById("rating-value").textContent   = scoreTracker.getRating();
  }

  async renderLeaderboard() {
    try {
      const entries = await fetchLeaderboard();
      this.topScores.innerHTML = entries.slice(0, 8).map((e, i) => `
        <div class="flex justify-between items-center text-xs px-2 py-1.5 rounded-lg bg-white/5">
          <span class="text-gray-400 font-mono w-5">${i + 1}</span>
          <span class="font-bold flex-1 ml-2 truncate">${e.username}</span>
          <span class="text-yellow-400 font-black tabular-nums">${e.score.toLocaleString()}</span>
        </div>`).join("");
    } catch {
      this.topScores.innerHTML = `<p class="text-gray-500 text-xs text-center">Leaderboard unavailable</p>`;
    }
  }
}
