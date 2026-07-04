/**
 * constants_client.js â€” Client-side mirror of server-side game constants.
 * Keeps JS game logic in sync with backend scoring values without a build step.
 */

export const BASE_SCORE_PER_SECOND   = 10;
export const CLUTCH_BONUS            = 1_000;
export const POWERUP_MULTIPLIER_BOOST = 2;
export const SHIELD_DURATION_SECONDS  = 5;

export const DIFFICULTY_SPEEDS = {
  easy:   12,
  medium: 18,
  hard:   26,
};

export const RATING_THRESHOLDS = {
  S: 50_000,
  A: 25_000,
  B: 10_000,
  C:  5_000,
  D:      0,
};

export const LEADERBOARD_MAX = 15;
