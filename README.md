# `sra-convert`

# Overview
This repository contains the `sra-convert` pipeline — a modular, HPC‑compatible workflow for:

> Converting .sra files into FASTQ format using a reproducible, restart‑safe, and parallelised SLURM execution model.

The pipeline is designed for execution in HPC environments and provides:
- Deterministic conversion of `.sra` files using a pinned SRA Toolkit version
- Parallel execution via SLURM array jobs for efficient large-scale processing
- Per‑accession isolation to ensure restart safety and prevent corruption
- Fully validated execution environment before any compute jobs are submitted

Internally, the pipeline follows a contract‑driven architecture, separating:
- configuration
- validation
- execution

to ensure reproducibility, portability, and fail‑fast behaviour across different cluster environments.

All outputs are written to a dedicated `output/` directory, enabling seamless integration with downstream pipelines such as QC, trimming, or alignment.

# Repository Structure
```text
sra-convert/
├── README.md                  # Top-level overview (this file)
├── config.sh                  # User configuration (input + SLURM parameters)
├── sra-convert.sh             # Entry point (logging + preflight + SLURM submission)
│
├── arrays/                    # Declarative pipeline contracts
│   ├── array_preflight.sh
│   ├── array_pipeline.sh
│   ├── array_variables.sh
│   ├── array_binaries.sh
│   └── array_exports.sh
│
├── utils/                     # Static variable definitions (no logic)
│   ├── utils_paths.sh
│   └── utils_sratoolkit.sh
│
├── functions/                 # Reusable helper functions
│   ├── functions_base.sh
│   ├── functions_pipeline.sh
│   └── functions_sratoolkit.sh
│
├── preflight/                 # Validation and environment setup
│   ├── preflight.sh
│   ├── preflight_paths.sh
│   ├── preflight_variables.sh
│   ├── preflight_binaries.sh
│   ├── preflight_input.sh
│   ├── preflight_exports.sh
│   ├── preflight_pipeline.sh
│   └── preflight_sratoolkit.sh
│
├── pipeline/                  # Execution layer
│   ├── pipeline.sh
│   ├── submit-array.sh
│   └── sra-fastq.sh
│
├── output/                    # Pipeline-generated data (created at runtime)
├── logs/                      # Centralised logs (orchestrator + SLURM)
└── env/                       # Tool environment files
```

# Workflow
At a high level, the pipeline proceeds as follows:

## Preflight validation
- Verifies required system binaries are available
- Confirms user configuration variables are defined and valid
- Validates pipeline scripts exist and are executable
- Checks input directory and accession file structure
- Installs and validates the SRA Toolkit (pinned version)
- Writes deterministic environment files for downstream execution
- Constructs an explicit execution ABI (`EXPORT_ARRAY`) for SLURM jobs

## Pipeline orchestration
Submits a SLURM orchestration job (`pipeline.sh`) from the login node

The orchestrator:
- Logs pipeline execution
- Submits a controller module (submit-array.sh)

## Array execution
`submit-array.sh` submits a SLURM job array:
- One array task per accession
- Concurrency limited by `SLURM_MAX_JOBS`

## Data conversion
Each SLURM array task (`sra-fastq.sh`):
- Resolves a single SRR accession from ACCESSION_FILE
- Loads the SRA Toolkit environment
- Converts `.sra` → FASTQ using fasterq-dump
- Writes outputs into accession-specific directories
- Compresses FASTQ files
- Skips completed accessions (restart-safe)

# Execution environment
- Preflight and orchestration execute on the login node
- Conversion runs on SLURM compute nodes
- Environment variables are explicitly passed via SBATCH_EXPORTS
- No implicit state is relied upon across execution boundaries

# Configuration
All user-defined parameters are located in `config.sh`.

At minimum, the pipeline requires:
```bash
INPUT_DIR="<path to SRA directory>"
ACCESSION_FILE="<file containing SRR IDs>"
```

| Variable | Description |
|----------|-------------|
| `INPUT_DIR` | Directory containing `.sra` files organised per accession (`${INPUT_DIR}/${SRR}/${SRR}.sra`). |
| `ACCESSION_FILE` | Plain-text file containing one SRR accession per line; ordering defines SLURM array indexing (`SLURM_ARRAY_TASK_ID`). |
| `SLURM_MAX_JOBS` | Maximum number of concurrent SLURM array tasks (controls parallelism). |
| `FASTERQ_CPUS` | Number of CPU threads allocated per `fasterq-dump` task. |
| `FASTERQ_MEM_PER_CPU` | Memory allocated per CPU for each conversion task (passed to SLURM as `--mem-per-cpu`). |

# Usage
From the pipeline root directory:
```bash
bash sra-convert.sh
```

This will:
- Run full preflight validation
- Set up tool environments
- Submit the pipeline to SLURM
- Execute conversions in parallel via array jobs

# Outputs
All outputs are written to `output/` grouped by module.

Example structure:
```text
output/
└── sra-fastq/
    └── SRRXXXXXXXX/
        ├── SRRXXXXXXXX_1.fastq.gz
        ├── SRRXXXXXXXX_2.fastq.gz
        └── SRRXXXXXXXX.log
```

Each accession is isolated into its own directory, allowing:
- safe restarts
- parallel downstream processing
- deterministic outputs

# Architecture Summary

| Layer | Responsibility |
|------|----------------|
| `config.sh` | User configuration |
| `arrays/` | Declarative pipeline contracts and ABI |
| `utils/` | Variable definitions |
| `functions/` | Reusable helper logic |
| `preflight/` | Validation and environment setup |
| `pipeline/` | Execution orchestration |

# Further Documentation
For detailed documentation on individual components, see:
- `arrays/README.md` — contract layer and execution ABI
- `preflight/README.md` — validation design and guarantees
- `pipeline/README.md` — execution model and modules
- `utils/README.md` — variable definitions
- `functions/README.md` — helper logic and abstractions

# Citation
If you use this pipeline in published work, please cite:

> Baptista, R. _sra-convert: A reproducible HPC pipeline for SRA to FASTQ conversion_. GitHub repository: https://github.com/romanbaptista/sra

Optionally include the commit hash or release version used.

# Why SRA Toolkit 2.10.9?
Many HPC systems provide an older SRA Toolkit module such as `sra-tools-2.10.3.tcl`.

While functional, these older builds often suffer from:
- Outdated HTTPS handling
- Unstable or inconsistent fasterq-dump behaviour
- Bugs in VDB configuration handling
- Reduced compatibility with newer SRA accessions

Version 2.10.9 includes important improvements:
- Improved stability and performance of fasterq-dump
- More reliable handling of large-scale conversions
- Better support for parallel HPC execution
- Reduced failure rates across batch workloads

For these reasons, the pipeline installs and uses a local copy of SRA Toolkit 2.10.9 by default, ensuring consistent and reproducible behaviour across different HPC environments.