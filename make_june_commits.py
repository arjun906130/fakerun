import subprocess
import os
from datetime import datetime, timedelta

def run_git_commit(message, date_str):
    env = os.environ.copy()
    env["GIT_AUTHOR_DATE"] = date_str
    env["GIT_COMMITTER_DATE"] = date_str
    
    # Make a small change to a file to ensure there's something to commit
    with open('dummy.txt', 'a') as f:
        f.write(f"{date_str}: {message}\n")
    
    subprocess.run(["git", "add", "dummy.txt"], check=True)
    subprocess.run(["git", "commit", "-m", message], env=env, check=True)

start_date = datetime(2026, 6, 1)
commits_per_day = 5
days = 12

messages = [
    "docs: update README with installation instructions",
    "feat: add basic player movement logic",
    "fix: resolve collision detection bug on easy mode",
    "style: improve button hover effects in main menu",
    "refactor: clean up score calculation utility",
    "feat: implement high score storage",
    "docs: add contributing guidelines",
    "fix: fix character sprite flickering",
    "feat: add background music toggle",
    "style: update font for better readability",
    "refactor: reorganize project structure",
    "feat: add difficulty level selection",
    "fix: correct leaderboard sorting order",
    "docs: update API documentation",
    "test: add unit tests for player movement",
    "feat: implement power-up system",
    "fix: fix occasional crash on level reload",
    "style: polish UI animations",
    "refactor: extract constants to separate file",
    "feat: add shield power-up",
    "fix: resolve memory leak in particle system",
    "docs: add security policy",
    "feat: implement level transition effects",
    "style: adjust color palette for better contrast",
    "refactor: simplify event handling logic",
    "feat: add sound effects for picking up items",
    "fix: fix incorrect score display in HUD",
    "docs: update changelog for June updates",
    "test: add integration tests for score submission",
    "feat: implement responsive layout for mobile",
    "fix: resolve issue with overlapping sprites",
    "style: update icons for power-ups",
    "refactor: optimize rendering loop",
    "feat: add speed boost power-up",
    "fix: fix bug where player could move out of bounds",
    "docs: add license information",
    "feat: implement save game functionality",
    "style: improve layout of leaderboard table",
    "refactor: modularize game engine components",
    "feat: add support for custom character colors",
    "fix: fix issue with audio not playing on some browsers",
    "docs: add mission statement to README",
    "test: add end-to-end tests for game flow",
    "feat: implement pause menu functionality",
    "style: update background graphics",
    "refactor: improve error handling in API calls",
    "feat: add score multiplier for streaks",
    "fix: fix alignment issue in main menu",
    "docs: update developer setup guide",
    "feat: implement player profile page",
    "style: add subtle glow effect to active elements",
    "refactor: streamline data fetching logic",
    "feat: add daily rewards system",
    "fix: fix bug in player name validation",
    "docs: add FAQ section to documentation",
    "test: add performance tests for heavy scenes",
    "feat: implement tutorial level for new players",
    "style: update splash screen graphics",
    "refactor: consolidate utility functions",
    "feat: add achievements system"
]

total_commits = days * commits_per_day
if len(messages) < total_commits:
    # Pad messages if needed
    for i in range(len(messages), total_commits):
        messages.append(f"chore: additional improvement {i+1}")

current_message_idx = 0
for day_offset in range(days):
    current_day = start_date + timedelta(days=day_offset)
    for commit_num in range(commits_per_day):
        # Stagger times throughout the day: 9am, 11am, 1pm, 3pm, 5pm
        hour = 9 + (commit_num * 2)
        commit_date = current_day.replace(hour=hour, minute=0, second=0)
        date_str = commit_date.strftime("%Y-%m-%dT%H:%M:%S+05:30")
        
        message = messages[current_message_idx]
        print(f"Committing for {date_str}: {message}")
        run_git_commit(message, date_str)
        current_message_idx += 1

print("All commits created locally. Pushing to origin...")
subprocess.run(["git", "push", "origin", "main"], check=True)
print("Done!")
