# AI Hub Card Contract

This document defines the repository structure and metadata format required by the Developer Journey AI Hub sync.

## Problem

The AI Hub repository currently contains new content in these unsupported forms:

```text
getting_started/getting_started.page.json
partners/partners.page.json
partners/partners.json
resources/resources.page.json
resources/resources.json
```

These files do not follow the established card contract. The backend intentionally discovers cards only at:

```text
<category>/<card-directory>/metadata.json
```

Introducing `*.page.json` files or category-level collection files creates a second content model that the existing card sync does not understand. The upstream repository should be corrected instead of adding special-case scraping logic to the backend.

## Required Directory Structure

Every AI Hub card must have its own directory directly beneath a category directory:

```text
<category>/
  <card-directory>/
    metadata.json
    <optional card-specific images>
```

Examples:

```text
partners/
  embedur/
    metadata.json
    embedur-ai-overview.webp
  wgtech/
    metadata.json
    wgtech-edge-ai.webp

resources/
  unlocking-edge-ai-psoc6-deepcraft-modustoolbox/
    metadata.json
  smart-entrance-counter-radar-application-note/
    metadata.json
  artificial-intelligence-at-the-edge-whitepaper/
    metadata.json
  deepcraft-ai-suite-accelerating-edge-ai-innovation/
    metadata.json
  what-is-tinyml/
    metadata.json
    tinyml-hero.webp

getting_started/
  getting-started-with-deepcraft-ai-hub/
    metadata.json
```

Directory names should be stable, lowercase, URL-safe identifiers. Do not place multiple unrelated cards in one `metadata.json` unless there is a compelling compatibility reason; one card per directory is the preferred contract.

## Required Filename and Depth

The metadata filename must be exactly:

```text
metadata.json
```

It must be exactly two directory levels below the repository root:

```text
repository-root/category/card/metadata.json
```

The following are not valid card locations:

```text
category.json
category/category.json
category/card.page.json
category/metadata.json
category/group/card/metadata.json
```

The sync does not recursively search arbitrary depths.

## Metadata Shape

Each `metadata.json` must contain one card object using the same field names as existing models, tools, solutions, and accelerators.

Example:

```json
{
  "title": "DEEPCRAFT™ Example Card",
  "type": "Resources",
  "description": "A short summary displayed on the card.",
  "long_description": "A complete description displayed on the detail page.",
  "sensors": ["Camera"],
  "domain": ["Vision"],
  "application": ["Industrial IoT"],
  "use_case": ["Object Detection"],
  "kit": ["PSOC™ Edge E84 Evaluation Kit"],
  "device": ["PSOC™ Edge"],
  "thumbnail_image_id": "example-thumbnail.webp",
  "main_image_id": "example-main.webp",
  "brand_image_id": "deepcraft.webp",
  "brand_url": "https://www.infineon.com/",
  "links": [
    {
      "label": "Learn More",
      "url": "https://www.infineon.com/example",
      "heading": "Example resource",
      "sub-heading": "Open the resource"
    }
  ],
  "metrics": []
}
```

### Field rules

- `title` must be a non-empty string and should be unique across the catalog. The backend derives the stable card key from this title.
- `type` must identify the card category. Use the same spelling and capitalization consistently, such as `Partners`, `Resources`, or `Getting Started`.
- `description` is the short card summary.
- `long_description` is the full detail text.
- `sensors`, `domain`, `application`, `use_case`, `kit`, and `device` must be arrays of strings, including when only one value is present.
- `thumbnail_image_id`, `main_image_id`, and `brand_image_id` must identify resolvable image files.
- `brand_url` and link URLs must be valid URLs when they point to external content.
- `links` must be an array of link objects following the established card schema.
- `metrics` should be an array. Use an empty array when the card has no metrics.
- Card-specific extension fields may be retained only if consumers explicitly support them. They must not replace the established fields.

Do not wrap cards in category-level objects such as:

```json
{ "partners": [...] }
```

or:

```json
{ "resources": [...] }
```

Each array item must instead become its own card directory and `metadata.json` file.

## Images

Images must use the same resolution rules as existing cards.

Preferred options:

1. Put shared images in the repository's shared `images` source.
2. Put a card-specific image directly in the same directory as that card's `metadata.json`.
3. Use a filename in the image ID fields, not a site deployment path.

Valid card-local example:

```text
resources/
  what-is-tinyml/
    metadata.json
    tinyml-hero.webp
```

```json
{
  "thumbnail_image_id": "tinyml-hero.webp",
  "main_image_id": "tinyml-hero.webp"
}
```

Avoid deployment-specific paths such as:

```json
{
  "main_image_id": "/pages/getting_started/images/deepcraft-ai-hub.png"
}
```

The sync uploads images to object storage and generates the served API path. Metadata should identify the source image, not prescribe the deployed URL.

Image filenames should be unique across the entire AI Hub catalog because synced files share the same object-storage prefix. Reusing the same filename for different image contents can cause one card's upload to overwrite another's.

## Links

External links should use absolute `https://` URLs.

Relative links such as these are unsupported unless the linked content is separately published by the platform:

```json
{ "url": "embedur.md" }
{ "url": "what-is-tinyml.md" }
```

Either:

- replace the relative URL with the final public URL, or
- add an explicit, separately designed publishing mechanism for Markdown content before referencing it.

Do not assume cloning the repository makes Markdown files publicly reachable.

## Fixing the New Folders

### `partners`

1. Remove `partners/partners.json` after migration.
2. Convert every item in its `partners` array into a separate directory.
3. Save each item as `<partner-id>/metadata.json`.
4. Move or copy each referenced image into the card directory or shared image source.
5. Replace relative profile links such as `embedur.md` with valid published URLs, or omit them until the content has a supported publisher.
6. Remove `partners/partners.page.json` or convert it into a normal card at `partners/partners-overview/metadata.json` if it must appear in the catalog.

### `resources`

1. Remove `resources/resources.json` after migration.
2. Convert every item in its `resources` array into a separate directory.
3. Save each item as `<resource-id>/metadata.json`.
4. Normalize image IDs to shared-image filenames or card-local filenames.
5. Replace relative article links such as `what-is-tinyml.md` with valid published URLs, or omit them until Markdown publishing is supported.
6. Remove `resources/resources.page.json` or convert it into a normal card at `resources/resources-overview/metadata.json` if it must appear in the catalog.

### `getting_started`

If Getting Started is intended to be an AI Hub card, convert it to:

```text
getting_started/
  getting-started-with-deepcraft-ai-hub/
    metadata.json
    deepcraft-ai-hub.png
```

Map its standard fields directly to the card metadata schema. The current `boxes` field is page-layout content and is not part of the established card contract. Move that information into `long_description`, represent useful destinations in `links`, or add a separately reviewed schema extension that all consumers support.

If Getting Started is intended to be a standalone page rather than a card, it should not be added to the card repository as though the existing sync will publish it. It requires a separate page-content contract and implementation.

## Validation Checklist

Before merging upstream changes, verify:

- Every intended card exists at `<category>/<card>/metadata.json`.
- No card depends on a `*.page.json` convention.
- No category-level JSON file wraps multiple cards.
- Every metadata file contains valid JSON.
- Every card has a non-empty, unique `title`.
- Array fields are arrays, not comma-separated strings.
- Every image ID resolves to a shared image or a file in the card directory.
- Image filenames do not collide with unrelated image contents.
- External links are absolute HTTPS URLs.
- Relative Markdown links are removed unless a publisher exists.
- A backend sync discovers the expected number of new cards.
- The sync completes without per-card errors.
- Synced thumbnails, main images, brand images, and links work from the deployed site.

## Backend Compatibility

The backend implementation in `server/aiHubSync.ts` deliberately follows this established contract. It:

- scans non-hidden top-level category directories;
- scans their immediate child card directories;
- reads only `metadata.json` from those card directories;
- maps standard metadata fields into AI Hub database cards;
- resolves shared or card-local images; and
- ignores unrelated files and unsupported content layouts.

The backend should not be extended with filename-specific cases for `partners.json`, `resources.json`, or `*.page.json`. Correcting the upstream content preserves one predictable card format and prevents repository-specific parsing rules from accumulating in the sync service.
