# Count lines of code in the lib/ and test/ directories, ignoring blank lines and comments.
# Usage (PowerShell): python .\scripts\loc_counter.py

import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
paths = [os.path.join(ROOT, 'root/lib'), os.path.join(ROOT, 'root/test')]
files = []
for p in paths:
    for dirpath, dirnames, filenames in os.walk(p):
        for f in filenames:
            if f.endswith('.dart'):
                files.append(os.path.join(dirpath, f))

counts = {}
total = 0
for fp in sorted(files):
    with open(fp, 'r', encoding='utf-8') as fh:
        lines = fh.readlines()
    count = 0
    for line in lines:
        s = line.strip()
        if s == '':
            continue
        if s.startswith('//'):
            continue
        count += 1
    counts[fp] = count
    total += count

print('Files scanned:')
for fp in sorted(counts.keys()):
    rel = os.path.relpath(fp, ROOT)
    print(f"- {rel}: {counts[fp]}")
print(f"Total: {total}")
