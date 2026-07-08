import os
import subprocess
import time

for i in range(1, 11):
    with open('dummy.txt', 'a') as f:
        f.write(f'Commit sequence {i}\n')
    subprocess.run(['git', 'add', 'dummy.txt'])
    subprocess.run(['git', 'commit', '-m', f'chore: automated commit sequence {i}'])

print("Pushing...")
subprocess.run(['git', 'push', 'origin', 'main'])
print("Done")
