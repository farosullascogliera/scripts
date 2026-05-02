import csv
import sys

if len(sys.argv) != 3:
    print("Usage: python3 clean_spotify_playlist.py <input.csv> <output.csv>")
    sys.exit(1)

input_file = sys.argv[1]
output_file = sys.argv[2]

remove = {
    'Disc Number', 'Track Number', 'Track Duration (ms)',
    'Explicit', 'Popularity', 'ISRC', 'Added By', 'Added At', 'Album Artist Name(s)'
}

with open(input_file, newline='', encoding='utf-8') as fin, \
     open(output_file, 'w', newline='', encoding='utf-8') as fout:
    reader = csv.DictReader(fin)
    keep_cols = [c for c in reader.fieldnames if 'URI' not in c and 'URL' not in c and c not in remove]
    writer = csv.DictWriter(fout, fieldnames=keep_cols, extrasaction='ignore')
    writer.writeheader()
    for row in reader:
        writer.writerow(row)

print(f"Done! Saved to {output_file}")
