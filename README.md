# DeepCraft AI Hub 🚀

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Actions](https://img.shields.io/badge/GitHub-Actions-blue.svg)](https://github.com/features/actions)
[![AWS](https://img.shields.io/badge/AWS-S3-orange.svg)](https://aws.amazon.com/s3/)

A comprehensive AI model repository hub that aggregates multiple DeepCraft AI solutions for embedded systems. This repository serves as a central portal for Infineon's edge AI solutions, combining model zoos for different platforms and studio accelerators.

## 📋 Table of Contents

- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Getting Started](#getting-started)
- [Workflows](#workflows)
- [Scripts](#scripts)
- [Contributing](#contributing)
- [Submodules](#submodules)
- [License](#license)

## 🎯 Overview

The DeepCraft AI Hub consolidates multiple AI model repositories into a single, unified platform:

- **Model Zoos**: Pre-trained models optimized for different hardware platforms
- **Studio Accelerators**: Ready-to-use AI solutions for common use cases
- **Automated Workflows**: CI/CD pipelines for deployment to AWS infrastructure
- **Unified Metadata**: Consolidated JSON catalog of all available models and solutions

## 📁 Repository Structure

```
deepcraft-ai-hub/
├── .github/
│   ├── scripts/
│   │   └── master.sh              # Script to generate unified metadata
│   └── workflows/
│       ├── aws_dev_pipeline.yml   # Development deployment pipeline
│       └── aws_prod_pipeline.yml  # Production deployment pipeline
├── deepcraft-model-zoo-for-aurix/ # Submodule: AURIX™ models
├── deepcraft-model-zoo-for-psoc/  # Submodule: PSoC™ Edge models
├── deepcraft-studio-accelerators/ # Submodule: Ready-to-use solutions
├── ai-hub-default-images/         # Submodule: Default/fallback image assets
├── images/                        # Submodule: Shared image assets
└── README.md                      # This file
```

## 🚀 Getting Started

### Prerequisites

- Git with submodule support
- Python 3.x
- AWS CLI (for deployment workflows)
- `jq` (for JSON processing)

### Clone the Repository

```bash
# Clone the repository with all submodules
git clone --recursive https://github.com/Reyev123/deepcraft-ai-hub.git
cd deepcraft-ai-hub

# Or if already cloned, initialize submodules
git submodule update --init --recursive
```

## 🔄 Workflows

The repository includes two automated deployment workflows:

### Development Workflow
- **Trigger**: Manual dispatch via GitHub Actions UI
- **Target**: `aihub-dev-ui` S3 bucket
- **Purpose**: Testing and validation of changes

### Production Workflow  
- **Trigger**: Manual dispatch via GitHub Actions UI
- **Target**: Production S3 bucket
- **Purpose**: Live deployment of validated changes

### Running Workflows

1. Navigate to the **Actions** tab in the GitHub repository
2. Select the appropriate workflow:
   - "Development AWS AI HUB workflow"
   - "Production AWS AI HUB workflow"  
3. Click "Run workflow" and confirm

⚠️ **Important**: Run workflows after any updates to:
- Submodule content
- Image assets in the `images/` folder
- Metadata files

## 🛠️ Scripts

### `master.sh`
Generates a unified `master.json` file containing metadata from all submodules.

**Features:**
- Scans all submodules for `metadata.json` files
- Handles both single objects and arrays in metadata
- Creates a flat JSON structure for easy access
- Validates JSON output

## 🤝 Contributing

### Adding New Submodules

1. **Add to `.gitmodules`**:
   ```ini
   [submodule "new-repo-name"]
       path = new-repo-name  
       url = https://github.com/Infineon/new-repo-name
   ```

2. **Initialize the submodule**:
   ```bash
   git submodule add https://github.com/Infineon/new-repo-name
   git submodule update --init --recursive
   ```

3. **Update workflows** if needed to include the new submodule

### Updating Submodules

```bash
# Update all submodules to latest
git submodule update --remote

# Update specific submodule
git submodule update --remote deepcraft-model-zoo-for-aurix
```

## 📦 Submodules

| Submodule | Description | Platform |
|-----------|-------------|----------|
| [deepcraft-model-zoo-for-aurix](https://github.com/Infineon/deepcraft-model-zoo-for-aurix) | AI models for AURIX™ microcontrollers | AURIX™ TC3x/TC4x |
| [deepcraft-model-zoo-for-psoc](https://github.com/Infineon/deepcraft-model-zoo-for-psoc) | AI models for PSoC™ Edge devices | PSoC™ Edge |
| [deepcraft-studio-accelerators](https://github.com/Infineon/deepcraft-studio-accelerators) | Ready-to-use AI solutions | Multi-platform |
| [images](https://github.com/Reyev123/images) | Shared image assets used across the hub | N/A |
| [ai-hub-default-images](https://github.com/Reyev123/ai-hub-default-images) | Default/fallback image assets for the AI Hub | N/A |

## 🔧 Maintenance

### Regular Tasks

1. **Update submodules** monthly or when new models are released
2. **Regenerate master.json** after submodule updates
3. **Run development workflow** to test changes
4. **Deploy to production** after validation

### Troubleshooting

**Submodule issues:**
```bash
git submodule deinit -f .
git submodule update --init --recursive
```

**Invalid JSON:**
```bash
python3 -m json.tool master.json
# Fix any JSON syntax errors and regenerate
```

## 📄 License

This project is licensed under the MIT License - see individual submodules for their specific licenses.

## 🔗 Related Links

- [Infineon DeepCraft Edge AI Solutions](https://www.infineon.com/design-resources/embedded-software/deepcraft-edge-ai-solutions)
- [AURIX™ Microcontrollers](https://www.infineon.com/aurix)
- [PSoC™ Edge AI](https://www.infineon.com/psoc-edge-ai)

---

**Maintained by**: [Reyev123](https://github.com/Reyev123)  
**Last Updated**: October 2025

