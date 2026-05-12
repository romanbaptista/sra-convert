# `utils`
This directory contains shared utility scripts used by the `sra-convert` pipeline.

The scripts in utils/ provide reusable, defensive helper logic that supports:
- Preflight validation
- Tool installation and verification
- Configuration enforcement
- Deterministic pipeline behavior under strict Bash execution

Utility scripts are sourced by:
- `run_pipeline.sh`
- Preflight scripts
- Pipeline module scripts (where explicitly required)

They are not intended to be executed directly.

# Design Contract
All utility scripts in this directory adhere to the following principles:
- Pure helper logic only (no pipeline orchestration)
- Safe operation under `set -euo pipefail`
- Explicit, readable control flow
- Clear and actionable error messages
- No reliance on implicit working directories
- No modification of global system settings
- Deterministic behavior across HPC environments

Utility functions are stateless and rely entirely on:
- Explicit function arguments, and/or
- Variables provided by the sourced pipeline context

# Utility Script Overview
```text
arrays.sh
functions_base.sh
functions_sratoolkit.sh
```
Each script serves a narrow, well‑defined purpose and participates in a strict separation of concerns between validation, installation, and execution.

## `arrays.sh`
Defines the canonical arrays that describe the structure and requirements of the `sra-convert` pipeline.

### Responsibilities
- Declares the ordered set of preflight scripts executed during pipeline validation
- Declares the ordered set of module scripts that comprise the pipeline
- Declares the execution ABI (`EXPORT_ARRAY`) passed to downstream SLURM jobs
- Declares the set of framework‑level external commands required
- Declares the set of required user configuration variables

All preflight scripts defer to `arrays.sh` as the single source of truth for what must be validated.

### Arrays

| Array | Purpose |
|------|---------|
| `PREFLIGHT_ARRAY` | Ordered list of preflight scripts executed by `preflight.sh` |
| `SCRIPT_ARRAY` | Ordered list of pipeline module scripts |
| `EXPORT_ARRAY` | Pipeline‑owned variables that define the execution ABI |
| `COMMAND_ARRAY` | Framework‑level commands required by the pipeline |
| `VARIABLE_ARRAY` | Required user‑defined configuration variables |

This script is purely declarative and contains no executable logic.

## `functions_base.sh`
Provides core validation and helper functions used throughout the pipeline.

### Responsibilities
- Validates files, directories, commands, and variables
- Enforces non‑empty configuration values
- Provides consistent error handling and messaging
- Supplies reusable filesystem and path helpers
- Writes reproducible environment files for tool configuration

These functions form the foundation upon which all preflight validation and guard enforcement are built.

### Functions

| Function | Purpose |
|---------|---------|
| `check_file` | Confirms that a regular file exists |
| `check_file_data` | Confirms that a file exists and is non‑empty |
| `check_directory` | Confirms that a directory exists |
| `check_variable` | Confirms that a named variable is set and non‑empty |
| `check_string` | Confirms that a string value is non‑empty |
| `check_command` | Confirms that a command is available in `PATH` |
| `check_executable` | Confirms that a file exists and is executable |
| `make_executable` | Adds execute permissions to a file |
| `check_arg` | Confirms that required function arguments are provided |
| `fail` | Emits an error message and terminates execution |
| `write_env` | Writes a reproducible environment file for tool setup |
| `get_directory` | Resolves the directory containing a given path |
| `get_parent_directory` | Resolves the parent directory of a given path |

All functions are designed to fail early and emit context‑rich error messages.

## `functions_sratoolkit.sh`
Provides SRA Toolkit–specific helpers for validation and installation.

### Responsibilities
- Detects whether a coherent SRA Toolkit installation is available
- Enforces a pinned SRA Toolkit version
- Downloads and installs the toolkit if missing or incorrect
- Derives and exports the toolkit installation directory
- Supports reproducible, environment‑file‑based configuration

All SRA Toolkit logic is centralized here so that:
- Preflight establishes all tool invariants
- Module scripts can assume correctness at runtime
- Tool installation never occurs during execution

### Functions

| Function | Purpose |
|---------|---------|
| `check_sratoolkit` | Verifies toolkit presence and derives `SRA_DIR` |
| `download_sratoolkit` | Downloads the pinned SRA Toolkit archive |
| `extract_sratoolkit` | Extracts the toolkit and exposes binaries to `PATH` |
| `install_sratoolkit` | Orchestrates installation and post‑install validation |

As with all utilities, installation is deterministic and restart‑safe.

# Usage
Utility scripts are sourced where required and must never be executed directly.

functions_base.sh is sourced by:
- `run_pipeline.sh`
- All preflight scripts
- Orchestration modules requiring helpers

Tool‑specific utility scripts are sourced only by their corresponding preflight scripts.

# Error Handling
All utility functions are designed to:
- Fail immediately on invalid input
- Emit concise, context‑aware error messages
- Prevent execution from progressing in an unsafe state

This ensures that pipeline failures occur as early and close to the source of the problem as possible.

# Notes
- Utility scripts deliberately contain no pipeline execution logic
- Tool installation logic is isolated, deterministic, and repeat‑safe
- No utility script assumes a specific SLURM execution context
- All validation logic is centralized; module scripts do not repeat checks
- Adding a new tool or pipeline stage should include corresponding utility helpers