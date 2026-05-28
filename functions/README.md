# `functions`

# Overview
The `functions/` directory contains all reusable, atomic logic used throughout the pipeline.

These scripts provide:
- validation primitives
- filesystem and variable checks
- tool installation helpers
- shared pipeline utilities

They represent the execution logic layer, but are strictly limited to stateless, reusable operations.

# Design Principles

| Principle | Description |
|----------|------------|
| Atomicity | Functions perform a single task |
| No orchestration | Control flow handled outside functions |
| Validation-first | Inputs are validated before use |
| Return-based | Failures propagate via return codes |

These principles ensure that:
- logic is modular and reusable
- failure handling is consistent and predictable
- orchestration remains external to function definitions

# File Overview
The `functions/` directory is structured into:
- a shared base layer (`functions_base.sh`)
- pipeline-level helpers (`functions_pipeline.sh`)
- tool-specific logic (`functions_sratoolkit.sh`)

Each file has a clearly defined responsibility.

| File | Responsibility |
|------|----------------|
| `functions_base.sh` | Core validation, filesystem checks, tool checks, and error handling |
| `functions_pipeline.sh` | Shared helpers (e.g. environment writing via `write_env`) |

## `functions_base.sh`
This file defines all core helper functions used across the entire pipeline.

It includes:
- argument validation (`arg_check_nonempty`)
- variable validation (`variable_check_nonempty`)
- array validation (`array_check_nonempty`)
- file and directory checks
- binary and tool validation
- error handling (`fail_message`)

This file forms the foundation of the contract-driven validation system.

All scripts that require validation or utility operations must source this file.

## `functions_pipeline.sh`
Contains shared helpers used across pipeline components.

Primary responsibility:
- writing tool environment files (`write_env`)

The `write_env` function:
- defines `TOOL_DIR`
- extends `PATH` deterministically `(${TOOL_DIR}/bin)`

This ensures that:
- tool environments are reproducible
- execution modules can reliably source `.env` files
- tool resolution is consistent across compute nodes

This file supports cross-cutting concerns, but does not implement orchestration logic.

## `functions_sratoolkit.sh`
Provides atomic helpers for working with the SRA Toolkit.

Responsibilities:
- downloading toolkit archives
- extracting toolkit contents
- exposing required binaries

Key characteristics:
- restart-safe behaviour (skips existing downloads)
- minimal assumptions about environment
- no validation or orchestration logic

Validation and setup decisions are handled in:
- `preflight_sratoolkit.sh`

This ensures a clean separation:
- functions → logic
- preflight → control and validation

# Execution Pattern
Functions follow a strict internal structure:
- argument validation
- execution logic
- return (no exit)

Example:
```bash
my_function() {
    local arg="${1-}"

    # VALIDATION
    arg_check_nonempty "${arg}" || return $?

    # FUNCTION
    do_something "${arg}" || return 1
}
```

This pattern guarantees:
- predictable behaviour
- clear error propagation
- composability across scripts

# Usage in Pipeline
Functions are used across:

- preflight scripts
→ validation, environment construction, tool installation
- pipeline scripts
→ orchestration helpers (e.g. `.env `construction)
- module scripts
→ filesystem operations, validation checks

Modules must explicitly source `functions_base.sh` when validation helpers are required.

# Error Handling
Functions:
- return non-zero exit codes on failure
- do not terminate execution directly

Pipeline scripts handle failure via:
- `function_call || fail_message "error description"`

This ensures:
- centralised failure control
- consistent messaging
- strict separation between logic and control flow

# Variable and Validation Model
Functions implement a layered validation model:
- `arg_check_nonempty`
→ validates function arguments
- `variable_check_nonempty`
→ validates named pipeline variables
- `array_check_nonempty`
→ validates collection structure

Each function:
- validates only its own level
- does not assume upstream guarantees unless explicitly enforced

This enables a composable validation chain across the pipeline.

# Key Rules
- Do not include orchestration logic in functions
- Do not use exit inside functions (except via `fail_message` outside them)
- Always validate inputs before execution
- Keep functions minimal and focused
- Avoid hidden dependencies or global state
- Ensure all functions are reusable across pipeline contexts

# Summary
The `functions/` directory provides the core logic building blocks of the pipeline.

It enables:
- consistent validation and error handling
- strict separation between logic and orchestration
- modular, reusable, and testable components

All higher-level behaviour in the pipeline is constructed from these atomic functions, ensuring:
- clarity of responsibility
- reproducibility
- maintainability