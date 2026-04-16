#!/bin/bash
# Combines all metadata.json files into a valid master.json
set -e

# Use Python to create valid JSON structure
python3 -c "
import json
import os
import re

TITLE_PREFIX = 'DEEPCRAFT\u2122 '
GITHUB_BASE_URL = os.environ.get('GITHUB_BASE_URL', 'https://github.com/Infineon').rstrip('/')
TITLE_OBJECT_PREFIX = 'DEEPCRAFT'

def has_excluded_prefix(path_parts):
    return any(part.startswith('_') or part.startswith('*') for part in path_parts)


def load_config(config_path):
    config = {
        'title_prefix': '',
        'title_order': []
    }

    if os.path.isfile(config_path):
        try:
            with open(config_path, 'r') as config_file:
                config_data = json.load(config_file)

            config_prefix = config_data.get('title_prefix')
            if isinstance(config_prefix, str):
                config['title_prefix'] = config_prefix if config_prefix.strip() != '' else ''
            elif config_prefix is not None:
                print(f'Warning: title_prefix in {config_path} is not a string, ignoring it')

            config_order = config_data.get('title_order')
            if isinstance(config_order, list):
                non_string_items = [item for item in config_order if not isinstance(item, str)]
                if non_string_items:
                    print(f'Warning: title_order in {config_path} contains non-string values, ignoring them')
                config['title_order'] = [item for item in config_order if isinstance(item, str)]
            elif config_order is not None:
                print(f'Warning: title_order in {config_path} is not an array, ignoring it')
        except Exception as e:
            print(f'Warning: Error reading {config_path}: {e}')

    return config


def get_root_config(cache):
    root_cache_key = '__root__'
    if root_cache_key in cache:
        return cache[root_cache_key]

    root_config = load_config(os.path.join('.', 'config.json'))
    cache[root_cache_key] = root_config
    return root_config


def get_module_config(path_parts, cache):
    module_root = path_parts[0] if path_parts else ''
    cache_key = module_root if module_root else '__module_root__'
    if cache_key in cache:
        return cache[cache_key]

    module_config = {
        'title_prefix': '',
        'title_order': []
    }
    if module_root:
        module_config = load_config(os.path.join('.', module_root, 'config.json'))

    cache[cache_key] = module_config
    return module_config


def get_module_title_prefix(path_parts, cache):
    return get_module_config(path_parts, cache).get('title_prefix', '')


def get_module_title_order(path_parts, cache):
    module_title_order = get_module_config(path_parts, cache).get('title_order', [])
    if module_title_order:
        return module_title_order

    return get_root_config(cache).get('title_order', [])


def has_non_empty_prefix(value):
    return isinstance(value, str) and value.strip() != ''


def get_prefixed_object_name(existing_name, module_title_prefix):
    if not has_non_empty_prefix(module_title_prefix):
        return existing_name

    key_prefix = f'{TITLE_OBJECT_PREFIX}{module_title_prefix}'.replace(' ', '')
    return f'{key_prefix}{existing_name}'


def rename_top_level_type_key(obj):
    if not isinstance(obj, dict) or 'type' not in obj:
        return obj

    renamed = {}
    for key, value in obj.items():
        if key == 'type':
            if 'Type' not in obj:
                renamed['Type'] = value
            continue

        renamed[key] = value

    return renamed


def normalize_metadata(obj, repo_url, base_title_prefix, module_title_prefix):
    if isinstance(obj, dict):
        if obj.get('label') == 'GitHub':
            obj['url'] = repo_url

        for k, v in list(obj.items()):
            if k == 'title' and isinstance(v, str):
                if not has_non_empty_prefix(module_title_prefix):
                    continue

                title_value = v[len(base_title_prefix):] if v.startswith(base_title_prefix) else v
                if has_non_empty_prefix(module_title_prefix) and not title_value.startswith(module_title_prefix):
                    title_value = f'{module_title_prefix}{title_value}'
                obj[k] = f'{base_title_prefix}{title_value}'
            else:
                normalize_metadata(v, repo_url, base_title_prefix, module_title_prefix)
    elif isinstance(obj, list):
        for item in obj:
            normalize_metadata(item, repo_url, base_title_prefix, module_title_prefix)


def sanitize_key_from_title(title):
    sanitized = title.replace('™', '').replace('\\u2122', '')
    sanitized = re.sub(r'\s+', '', sanitized)
    return sanitized


def split_type_tokens(value):
    if not isinstance(value, str):
        return []

    return [part.strip() for part in value.split(',') if part.strip() != '']


def get_type_values(obj):
    if not isinstance(obj, dict):
        return []

    raw_type = obj.get('type', obj.get('Type'))
    if isinstance(raw_type, list):
        type_values = []
        for item in raw_type:
            type_values.extend(split_type_tokens(item))
        return type_values
    if isinstance(raw_type, str):
        return split_type_tokens(raw_type)

    return []


def get_card_sort_key(original_title, type_values, title_order, fallback_key):
    normalized_title = original_title.casefold() if isinstance(original_title, str) and original_title.strip() != '' else fallback_key.casefold()

    if not type_values:
        return (1, float('inf'), normalized_title, fallback_key.casefold())

    if not title_order:
        return (0, 0, normalized_title, fallback_key.casefold())

    normalized_title_order = [value.strip() for value in title_order if isinstance(value, str) and value.strip() != '']
    order_lookup = {value: index for index, value in enumerate(normalized_title_order)}
    matching_priorities = [order_lookup[type_value] for type_value in type_values if type_value in order_lookup]
    if matching_priorities:
        return (0, min(matching_priorities), normalized_title, fallback_key.casefold())

    return (0, len(normalized_title_order), normalized_title, fallback_key.casefold())


def sort_cards(cards, card_sort_keys):
    ordered = {}
    for key, value in sorted(cards.items(), key=lambda item: card_sort_keys.get(item[0], (1, float('inf'), item[0].casefold(), item[0].casefold()))):
        ordered[key] = value

    return ordered


def rewrite_top_level_keys_from_title(data):
    rewritten = {}
    for original_key, value in data.items():
        if isinstance(value, dict) and isinstance(value.get('title'), str) and value['title'].strip() != '':
            base_key = sanitize_key_from_title(value['title'])
            if base_key == '':
                base_key = original_key
        else:
            base_key = original_key

        unique_key = base_key
        suffix = 2
        while unique_key in rewritten:
            unique_key = f'{base_key}_{suffix}'
            suffix += 1

        rewritten[unique_key] = value

    return rewritten


cards = {}
card_sort_keys = {}
module_config_cache = {}
# Search for metadata.json files in subdirectories (pattern */*/metadata.json)
for root, dirs, files in os.walk('.'):
    # Prune excluded directories while walking
    dirs[:] = [d for d in dirs if not (d.startswith('_') or d.startswith('*'))]

    if 'metadata.json' in files:
        # Get the directory path relative to current directory
        rel_path = os.path.relpath(root, '.')
        # Skip if it's in current directory or too deep
        path_parts = rel_path.split(os.sep)
        if len(path_parts) == 2 and not has_excluded_prefix(path_parts):  # Only process paths like 'parent/child'
            try:
                metadata_path = os.path.join(root, 'metadata.json')
                with open(metadata_path, 'r') as f:
                    metadata = json.load(f)

                normalized_rel_path = rel_path.replace(os.sep, '/')
                parent_path, leaf_path = normalized_rel_path.rsplit('/', 1)
                repo_url = '{}/{}/tree/main/{}'.format(GITHUB_BASE_URL, parent_path, leaf_path)
                module_title_prefix = get_module_title_prefix(path_parts, module_config_cache)
                module_title_order = get_module_title_order(path_parts, module_config_cache)
                
                # Use the leaf directory name as the key
                key = os.path.basename(root)
                prefixed_key = get_prefixed_object_name(key, module_title_prefix)
                
                # Handle both single objects and arrays of objects
                if isinstance(metadata, list):
                    # If it's an array, create separate entries for each item
                    for i, item in enumerate(metadata):
                        original_title = item.get('title') if isinstance(item, dict) else ''
                        type_values = get_type_values(item)
                        item = rename_top_level_type_key(item)
                        normalize_metadata(item, repo_url, TITLE_PREFIX, module_title_prefix)
                        entry_key = f'{prefixed_key}_{i+1}' if len(metadata) > 1 else prefixed_key
                        cards[entry_key] = item
                        card_sort_keys[entry_key] = get_card_sort_key(original_title, type_values, module_title_order, entry_key)
                else:
                    # If it's a single object, use directory name as key
                    original_title = metadata.get('title') if isinstance(metadata, dict) else ''
                    type_values = get_type_values(metadata)
                    metadata = rename_top_level_type_key(metadata)
                    normalize_metadata(metadata, repo_url, TITLE_PREFIX, module_title_prefix)
                    cards[prefixed_key] = metadata
                    card_sort_keys[prefixed_key] = get_card_sort_key(original_title, type_values, module_title_order, prefixed_key)
                    
            except Exception as e:
                print(f'Warning: Error processing {metadata_path}: {e}')

# Sort cards before rewriting top-level keys so insertion order is preserved in the output file.
# Ordering rules:
# 1. Cards with a type come before cards without a type.
# 2. If the module config defines title_order, the lowest matching type index wins.
# 3. If a card has multiple types, the best-ranked type determines its priority.
# 4. Cards with the same priority are ordered alphabetically by the original metadata title.
# 5. Typed cards not listed in title_order are placed after configured types but before untyped cards.
cards = sort_cards(cards, card_sort_keys)

# Last step: overwrite all top-level keys using sanitized title values
# (remove whitespace and trademark marker).
cards = rewrite_top_level_keys_from_title(cards)

# Write cards directly to master.json (no 'cards' wrapper)
with open('master.json', 'w') as f:
    json.dump(cards, f, indent=2, ensure_ascii=False)

print(f'Successfully created master.json with {len(cards)} cards')
"

# Optionally, remove all other .json files except master.json if any exist from previous runs
find . -maxdepth 1 -type f -name '*.json' ! -name 'master.json' -delete
