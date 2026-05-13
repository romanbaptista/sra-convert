# `sra-convert`

# Overview
This repository contains the `sra-convert` pipeline — a modular, HPC‑compatible workflow for:

> Converting previously downloaded `.sra` files into FASTQ format in a robust, restart‑safe, parallelizable manner.

The pipeline is designed to operate downstream of `sra-download` and assumes that `.sra` files have already been acquired and organized in a deterministic directory layout. 

However, it can be used in conjuction with another sra download method, as long as input structure is consistent with this pipeline.

The pipeline is designed specifically for HPC environments and supports:
- SLURM array–based parallel conversion of SRA runs
- Explicit resource control (CPUs and memory per conversion task)
- Per‑accession output isolation for safe restart and partial completion
- Comprehensive preflight validation before any SLURM jobs are submitted
- Reproducible tool environments via pinned SRA Toolkit installation

All pipeline outputs are written to a dedicated `output/` directory, enabling clean chaining into downstream QC, trimming, or alignment workflows.

# Repository Structure
```text
sra-convert/
├── README.md                               # Top-level overview (this file)
├── config.sh                               # User configuration (inputs and SLURM parameters)
├── run_pipeline.sh                         # Entry point (login-node orchestration)
├── utils/                                  # Shared utilities and helpers
│   ├── arrays.sh                           # Canonical lists of scripts, commands, variables
│   ├── functions_base.sh                   # General-purpose helper functions
│   └── functions_sratoolkit.sh             # SRA Toolkit check/install helpers
├── preflight/                              # Preflight validation layer
│   ├── preflight.sh
│   ├── preflight_input.sh
│   ├── preflight_variables.sh
│   ├── preflight_scripts.sh
│   ├── preflight_commands.sh
│   └── preflight_sratoolkit.sh
├── modules/                                # Execution modules
│   ├── pipeline.sh
│   ├── submit_array.sh
│   └── convert_sra.sh
└── output/                                 # Pipeline-generated results (created at runtime)
```

# Workflow
At a high level, the pipeline proceeds as follows:

### Preflight validation
- Verifies all required framework-level commands are available
- Confirms all required user configuration variables are set
- Validates presence and non-emptiness of module scripts
- Confirms the input directory contains `.sra` files
- Checks for and installs the SRA Toolkit (pinned version)
- Writes reproducible environment files under `env/` for downstream sourcing

### Pipeline orchestration

Submits an internal orchestrator job (`pipeline.sh`) from the login node

The orchestrator submits a lightweight SLURM controller job

### Conversion execution
The controller submits a SLURM array spanning all SRA accessions. Each array task:
- Converts exactly one `.sra` file to FASTQ using `fasterq-dump`
- Writes output to a per‑accession directory
- Skips completed accessions safely on re‑run
- Captures logs per accession

All validation occurs before SLURM submission; execution modules assume preflight invariants.

# Configuration
All user‑tunable parameters are defined in `config.sh`.

| Variable | Description |
|----------|-------------|
| `INPUT_DIR` | Directory containing `.sra` files organized by accession (`${INPUT_DIR}/${SRR}/${SRR}.sra`). |
| `ACCESSION_FILE` | Plain-text file containing one SRR accession per line; ordering defines SLURM array indexing. |
| `SLURM_MAX_JOBS` | Maximum number of concurrent SLURM array tasks for conversion. |
| `FASTERQ_CPUS` | Number of CPU threads allocated per `fasterq-dump` conversion task. |
| `FASTERQ_MEM_PER_CPU` | Memory allocated per CPU for each conversion task (passed to SLURM). |

# Required input layout
The pipeline expects `.sra` files to follow this structure:

```text
INPUT_DIR/
└── SRRXXXXXXXX/
    └── SRRXXXXXXXX.sra
```

The order of accessions in `ACCESSION_FILE` defines SLURM array indexing.

# Usage
Navigate to the root of the repository and run:

```bash
run_pipeline.sh
```

This will:
- Perform all preflight validation checks
- Install and validate required tools if necessary
- Submit the conversion workflow to the cluster via SLURM

The pipeline is restart‑safe; re‑running `run_pipeline.sh` will skip already converted accessions.

# Outputs
All pipeline outputs are written under `output/`, grouped by module.

Example structure after completion:

```text
output/
└── convert_sra/
    ├── SRRXXXXXXXX/
    │   ├── SRRXXXXXXXX_1.fastq.gz
    │   ├── SRRXXXXXXXX_2.fastq.gz
    │   └── SRRXXXXXXXX.log
    └── SRRYYYYYYYY/
        └── ...
```

Each accession is isolated in its own directory, enabling safe partial completion and parallel downstream processing.

# Further Documentation
For detailed documentation on individual components, see:
- `preflight/README.md` — preflight validation guarantees and ordering
- `modules/README.md` — execution model and module contracts
- `utils/README.md` — shared utilities and helper responsibilities

# Citation
If you use this pipeline in published work, please cite:

> Baptista, R. _sra-convert: A reproducible HPC pipeline for SRA to FASTQ conversion_. GitHub repository: https://github.com/romanbaptista/sra

Optionally include the commit hash or release tag used for analysis.

# Why SRA Toolkit 2.10.9?
Many HPC systems provide an older SRA Toolkit module such as `sra-tools-2.10.3.tcl`. While functional, these older builds often suffer from:
- Outdated HTTPS handling (leading to prefetch failures)
- Incomplete or buggy fasterq-dump behavior
- Missing improvements to VDB configuration handling
- Reduced compatibility with newer SRA accessions
- Increased failure rates when running many jobs in parallel

SRA Toolkit v2.10.9 includes important fixes and improvements:
- More reliable HTTPS downloads and repository access
- Improved performance and stability of fasterq-dump
- Better handling of per-directory VDB_CONFIG files
- Fewer failures under high parallelism on HPC clusters

For these reasons, `sra-convert` installs and uses a local copy of SRA Toolkit 2.10.9 by default, ensuring consistent, reproducible behavior across users and clusters.