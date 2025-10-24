#!/bin/bash
# Converts all top-level metadata.json files to .json in ModelJsons
set -e
touch master.json
echo "{" >> master.json
for d in */*/ ; do
  if [ -f "$d/metadata.json" ]; then
    name=$(basename "$d")
    echo "    \"$name\":" >> master.json
    python3 -c 'import sys, json; json.dump(json.load(sys.stdin), sys.stdout, indent=4)' < "$d/metadata.json" | sed 's/^/    /' >> master.json
    echo "," >> master.json
  fi
done
echo "}" >> master.json
# Optionally, remove all .json files except master.json if any exist from previous runs
find . -maxdepth 1 -type f -name '*.json' ! -name 'master.json' -delete