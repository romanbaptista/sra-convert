# `preflight`

# Overview
The `preflight/` directory implements the validation and environment construction layer of the pipeline.

This layer is responsible for ensuring that all requirements are satisfied before any SLURM jobs are submitted.

It performs:
- validation of user configuration
- validation of system environment
- validation of input data
- validation of pipeline structure
- installation and verification of required tools
- construction of runtime directories
- creation of environment files
- construction of the execution ABI (`SBATCH_EXPORTS`)

The preflight phase enforces a strict fail‑fast model, guaranteeing that downstream execution begins only in a fully validated and deterministic state.

# Design Principles
The preflight layer follows core architectural rules:
- Fail-fast — any error immediately terminates the pipeline
- Validation-only responsibility — no execution or data processing logic
- Deterministic ordering — all steps run in a strictly defined sequence
- Explicit contracts — validation driven entirely by arrays
- No hidden state — all required variables, tools, and inputs are explicitly checked
- Reproducibility — tool environments are written to `.env` files

This ensures that all downstream scripts can assume:
- consistent state
- valid inputs
- functional tools

# Role in the Pipeline
The preflight layer is executed immediately after the entrypoint script (`sra-convert.sh`) and before any SLURM submission occurs.

It ensures:
- all required variables are defined and non-empty
- all required binaries are available
- all input files and directories are valid
- all pipeline scripts exist and are executable
- all tools are installed and functional
- all runtime directories exist
- all environment files are correctly written
- the execution ABI is fully constructed

Only once all checks succeed does execution proceed to the pipeline orchestration stage.

# Execution Flow
Preflight is orchestrated by `preflight.sh`.

This script:
- sources `array_preflight.sh`
- executes each preflight script in order
- terminates immediately on failure

Each script:
- consumes only validated upstream state
- constructs or validates a specific part of the environment

This enforces a strict producer → consumer relationship between stages.

# Preflight Stages
The pipeline implements the following validation stages:

### Paths
- Defines all pipeline directories via `utils_paths.sh`
- Extends `DIR_ARRAY` with pipeline-specific directories
- Creates all required directories

### Variables
- Validates user-defined configuration variables from `config.sh`

### Binaries
- Verifies required system-level CLI tools from `BINARY_ARRAY`

### Input
- Validates input directory structure
- Confirms presence of .sra files
- Validates accession file contents

### Exports
- Constructs the pipeline execution ABI from `EXPORT_ARRAY`
- Generates `SBATCH_EXPORTS` for SLURM submission

### Pipeline
- Confirms all module scripts exist
- Ensures scripts are non-empty and executable
- Validates presence of `pipeline.sh`

### Tools
- Installs and validates required tools (SRA Toolkit)
- Constructs and writes environment files

# Script Structure
Each preflight script follows a consistent structure:
```text
GUARDS
SETUP
SOURCE
CHECKS
MAIN
```

- `GUARDS` validate required input variables
- `SETUP` defines script-level constants
- `SOURCE` imports required definitions
- `CHECKS` validate consumed state
- `MAIN` performs validation or state construction

This structure ensures:
- predictable control flow
- minimal side effects
- explicit dependencies

# Tool Integration Model
Tools follow a three-layer integration model:

- `utils_<tool>.sh`
→ defines parameters (version, URL, paths)

- `functions_<tool>.sh`
→ implements atomic install and validation logic

- `preflight_<tool>.sh`
→ orchestrates installation and validation

For this pipeline:
- only the SRA Toolkit is required
- validation is centred on `fasterq-dump` functionality

This ensures:
- tools are installed deterministically
- validation is consistent
- execution modules do not perform tool checks

# Environment Construction
The preflight layer builds the runtime environment by:
- creating all required directories
- installing tools if missing
- resolving installation paths
- writing `.env` files to `env/`

These environment files:
- define tool locations
- reconstruct `PATH` for execution
- ensure reproducible behaviour across compute nodes

# Execution ABI
The preflight layer constructs the execution ABI via:
- `array_exports.sh` → defines required variables
- `preflight_exports.sh` → constructs `SBATCH_EXPORTS`

This ensures that:
- only required variables are passed to SLURM jobs
- no implicit environmental state is relied upon
- execution is reproducible across nodes

# Execution Relationships
Each preflight script is responsible for a specific contract:

| Script | Responsibility |
|--------|----------------|
| `preflight.sh` | Orchestrates execution of all preflight checks |
| `preflight_paths.sh` | Defines and creates required directories |
| `preflight_variables.sh` | Validates user configuration variables |
| `preflight_binaries.sh` | Validates required system binaries |
| `preflight_input.sh` | Validates input directories and accession file |
| `preflight_exports.sh` | Constructs SBATCH_EXPORTS from EXPORT_ARRAY |
| `preflight_pipeline.sh` | Validates pipeline scripts and orchestrator |

# Key Rules
- Do not include execution logic in preflight scripts
- Do not defer validation to later stages
- Always fail immediately on errors
- Only validate variables consumed by the script
- Maintain strict ordering via `PREFLIGHT_ARRAY`
- Do not rely on implicit environment state
- Ensure all execution dependencies are satisfied before completion

# Summary
The `preflight/` directory guarantees that the pipeline executes in an environment that is:
- fully validated
- reproducible
- deterministic

By enforcing strict contracts and fail-fast validation, it provides a clean boundary between setup and execution.
This ensures that all downstream pipeline stages can operate:
- without ambiguity
- without hidden dependencies
- with full confidence in their execution context