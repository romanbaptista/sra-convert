# `preflight`
This directory contains the preflight validation layer for the `sra-convert` pipeline.

Preflight scripts are responsible for all validation and environment checks required to safely execute the pipeline on an HPC system before any SLURM jobs are submitted.

No pipeline modules are executed unless all preflight checks succeed.

All preflight scripts are sourced and executed by `run_pipeline.sh` on the login node, ensuring that pipeline execution begins only after the environment, configuration, and inputs are fully validated.

# Design Contract
All preflight scripts adhere to the following principles:
- Fail‑fast validation before any pipeline execution
- No side effects beyond controlled, deterministic tool installation
- Clear, actionable error messages on failure
- Deterministic behavior with explicit ordering
- Validation only — no execution or data processing logic
- Centralized enforcement of pipeline invariants

Once preflight validation completes successfully, downstream scripts may assume:
- All required configuration variables are valid and non‑empty
- All required commands and tools are available and usable
- Input data is present and correctly typed
- Required directories exist and are writable
- Tool environments can be safely sourced without further checks

# Responsibilities of Preflight
The preflight layer ensures that:
- User configuration is complete and non‑empty
- Input data directories exist and contain valid `.sra` files
- Accession lists exist and contain data
- Pipeline module scripts exist and are non‑empty
- Required framework‑level commands are available
- Required toolchains (SRA Toolkit) are installed and usable
- Tool installations are reproducible and environment files are written

This prevents late‑stage failures, wasted cluster resources, and partially‑executed pipelines caused by missing dependencies or invalid inputs.

# Preflight Script Overview
The set and execution order of all preflight scripts is centrally defined in:

```text
utils/arrays.sh  → PREFLIGHT_ARRAY
```

`preflight/preflight.sh` sources and executes each script listed in `PREFLIGHT_ARRAY` sequentially, terminating immediately on failure.

### Current preflight order
```text
preflight_input.sh
preflight_variables.sh
preflight_scripts.sh
preflight_commands.sh
preflight_sratoolkit.sh
```

## `preflight_input.sh`
Validates pipeline input data.

### Responsibilities
- Confirms `INPUT_DIR` is defined and exists
- Verifies that `.sra` files are present somewhere under `INPUT_DIR`
- Confirms `ACCESSION_FILE` exists and contains data

This script enforces the pipeline’s input data contract, ensuring that the pipeline is operating on the correct data type before any execution occurs.

## `preflight_variables.sh`
Validates required user‑defined configuration variables.

### Responsibilities
Confirms all required variables in `config.sh` are:
- Defined
- Non‑empty

Variables validated include:
- `INPUT_DIR`
- `ACCESSION_FILE`
- `SLURM_MAX_JOBS`
- `FASTERQ_CPUS`
- `FASTERQ_MEM_PER_CPU`

This ensures the pipeline has sufficient configuration to submit and execute SLURM jobs deterministically.

## `preflight_scripts.sh`
Validates pipeline module integrity.

### Responsibilities
- Confirms all expected module scripts exist under `modules/`
- Verifies that each module script is non‑empty
- Confirms presence and integrity of `modules/pipeline.sh`

This prevents execution of incomplete or corrupted module code.

## `preflight_commands.sh`
Validates required framework‑level external commands.

### Responsibilities
- Confirms availability of all generic, non‑tool‑specific commands used by the pipeline
- Uses strict `PATH`‑based validation

Commands validated here include:
- Shell and filesystem utilities
- Stream processing tools
- SLURM submission commands

Tool‑specific binaries (e.g. `fasterq-dump`) are intentionally excluded and handled by dedicated tool preflight scripts.

## `preflight_sratoolkit.sh`
Validates and installs the SRA Toolkit.

### Responsibilities
- Confirms a coherent SRA Toolkit installation is available
- Verifies required toolkit binaries (`prefetch`, `fasterq-dump`, `vdb-config`)
- Downloads and installs the toolkit if missing or incorrect
- Writes a reproducible environment file (`env/sratoolkit.env`)
- Ensures downstream scripts can safely source the tool environment

This script centralizes all SRA Toolkit invariants so that execution modules never repeat validation or installation logic.

# Execution Model
All preflight scripts are:
- Executed on the login node
- Sourced into a single shell for shared context
- Terminated immediately on failure

The pipeline does not proceed unless all preflight scripts complete successfully.

# Invariants Guaranteed After Preflight
After successful preflight validation, downstream pipeline stages may assume:
- Configuration variables are defined and valid
- Input directories exist and contain `.sra` files
- Accession lists exist and are non‑empty
- Required framework‑level commands are available
- The SRA Toolkit is installed, version‑correct, and usable
- Tool environment files exist and can be safely sourced
- Module scripts exist and contain valid code

This contract enforces a clean separation between validation and execution throughout the sra-convert pipeline.

# Notes
- Preflight scripts are not intended to be run directly by end users
- Tool installation performed during preflight is deterministic and restart‑safe
- All validation logic is centralized in this directory
- Module scripts do not repeat validation checks
- Any modification to configuration, inputs, or pipeline code requires rerunning preflight