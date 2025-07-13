
import json
import csv

with open('colors.json', 'r') as f:
    data = json.load(f)

with open('colors.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['Name', 'C', 'M', 'Y', 'K'])
    for color in data:
        name = color['name']
        c, m, y, k = color['cmyk']
        writer.writerow([name, c, m, y, k])
