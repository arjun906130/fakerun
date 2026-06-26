/**
 * api.js â€” Client-side wrapper for the CLUTCH RUN REST API.
 * Provides clean async functions for submitting scores and fetching leaderboard data.
 */

const API_BASE = "";  // Empty string = same origin

/**
 * Submits a player's score to the backend.
 * @param {string} username - The player's callsign (uppercase, 2-12 chars).
 * @param {number} score    - The final integer score to submit.
 * @returns {Promise<object>} Parsed JSON response from the server.
 */
export async function submitScore(username, score) {
  const response = await fetch(`${API_BASE}/api/submit-score/`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ username, score }),
  });
  if (!response.ok) {
    const err = await response.json();
    throw new Error(err.message || "Failed to submit score.");
  }
  return response.json();
}

/**
 * Fetches the global leaderboard from the backend.
 * @returns {Promise<Array>} Array of leaderboard entry objects.
 */
export async function fetchLeaderboard() {
  const response = await fetch(`${API_BASE}/api/leaderboard/`);
  if (!response.ok) throw new Error("Failed to fetch leaderboard.");
  const data = await response.json();
  return data.leaderboard || [];
}

/**
 * Fetches aggregated statistics for a specific player.
 * @param {string} username - The player callsign to look up.
 * @returns {Promise<object>} Player stats object.
 */
export async function fetchPlayerStats(username) {
  const response = await fetch(`${API_BASE}/api/player/${encodeURIComponent(username)}/stats/`);
  if (!response.ok) throw new Error("Player not found.");
  return response.json();
}
