#!/bin/bash
# Combines all metadata.json files into a valid master.json
set -e

# Use Python to create valid JSON structure
python3 -c "
import json
from pathlib import Path
import os

cards = {}
# Search for metadata.json files in subdirectories (pattern */*/metadata.json)
for root, dirs, files in os.walk('.'):
    if 'metadata.json' in files:
        # Get the directory path relative to current directory
        rel_path = os.path.relpath(root, '.')
        # Skip if it's in current directory or too deep
        path_parts = rel_path.split(os.sep)
        if len(path_parts) == 2:  # Only process paths like 'parent/child'
            try:
                metadata_path = os.path.join(root, 'metadata.json')
                with open(metadata_path, 'r') as f:
                    metadata = json.load(f)
                
                # Use the leaf directory name as the key
                key = os.path.basename(root)
                
                # Handle both single objects and arrays of objects
                if isinstance(metadata, list):
                    # If it's an array, create separate entries for each item
                    for i, item in enumerate(metadata):
                        entry_key = f'{key}_{i+1}' if len(metadata) > 1 else key
                        cards[entry_key] = item
                else:
                    # If it's a single object, use directory name as key
                    cards[key] = metadata
                    
            except Exception as e:
                print(f'Warning: Error processing {metadata_path}: {e}')

# Create the master JSON structure
master_data = {'cards': cards}

# Write to master.json with proper formatting
with open('master.json', 'w') as f:
    json.dump(master_data, f, indent=2, ensure_ascii=False)

print(f'Successfully created master.json with {len(cards)} cards')
"

# Optionally, remove all other .json files except master.json if any exist from previous runs
find . -maxdepth 1 -type f -name '*.json' ! -name 'master.json' -delete