# `arrays`

# Overview
The `arrays/` directory defines the declarative contract layer of the pipeline.

These files contain no executable logic and instead declare:
- required configuration variables
- required system binaries
- execution modules
- preflight validation order
- execution ABI (exported variable contract)

Together, they define the Application Binary Interface (ABI) of the pipeline and its full structural specification.

# Design Principles
- Declarative only — no functions, no control flow
- Single source of truth for pipeline structure
- Explicit contracts that enforce reproducibility
- Consumed by preflight and pipeline layers
- No hidden dependencies — all required inputs are declared
- Minimality — only required state is declared

These principles ensure that:
- the pipeline remains deterministic
- validation is centralised
- execution is reproducible across HPC environments

# Files and Responsibilities
The directory contains five core contract definitions:

| File | Responsibility |
|------|----------------|
| `array_variables.sh` | Defines required user configuration variables |
| `array_binaries.sh` | Defines required system binaries |
| `array_pipeline.sh` | Defines execution modules |
| `array_preflight.sh` | Defines ordered preflight validation stages |
| `array_exports.sh` | Defines execution ABI (variables exported to SLURM) |

# Contract Types

## `array_variables.sh`
Defines all variables that must be provided in `config.sh`.

Example:
```text
VARIABLE_ARRAY=(
    INPUT_DIR
    ACCESSION_FILE
)
```

These variables:
- originate from user configuration
- are validated during preflight
- must be non-empty before execution

## `array_binaries.sh`
Defines all required system-level commands used by the pipeline.

Rules:
- include only commands explicitly invoked in scripts
- exclude tool-specific binaries (validated separately)

Example:
```text
BINARY_ARRAY=(
    sbatch
    grep
    sed
    gzip
)
```

This contract defines the minimal runtime environment.

## `array_pipeline.sh`
Defines all execution modules in the pipeline.

For this pipeline:
- order does not define execution sequence
- modules may be invoked selectively by the orchestrator

Example:
```text
PIPELINE_ARRAY=(
    "submit-array.sh"
    "sra-fastq.sh"
)
```

This ensures:
- all modules are explicitly declared
- all modules are validated before execution

## `array_preflight.sh`
Defines the ordered execution of preflight scripts.

Order is critical and must follow dependency flow:

```text
PREFLIGHT_ARRAY=(
    "preflight_paths.sh"
    "preflight_variables.sh"
    "preflight_binaries.sh"
    "preflight_input.sh"
    "preflight_exports.sh"
    "preflight_pipeline.sh"
    "preflight_sratoolkit.sh"
)
```

This ensures:
- state is constructed before validation
- dependencies are resolved correctly
- execution only occurs after full validation

## `array_exports.sh`
Defines the execution ABI of the pipeline.

This is the most critical contract in a SLURM-based pipeline.

Example:
```text
EXPORT_ARRAY=(
    ACCESSION_FILE
    INPUT_DIR
    FASTQ_OUTDIR
    SRA_ENV
    PIPELINE_DIR
    SLURM_MAX_JOBS
    FASTERQ_CPUS
    FASTERQ_MEM_PER_CPU
)
```

This contract:
- defines all variables required across the SLURM boundary
- is converted into `SBATCH_EXPORTS` during preflight
- ensures no implicit environment state is relied upon

It guarantees:
- reproducibility across compute nodes
- portability across HPC systems
- explicit variable propagation

# Execution Relationships
Arrays are consumed by different pipeline components:

| Array | Consumed By | Purpose |
|------|-------------|--------|
| `VARIABLE_ARRAY` | `preflight_variables.sh` | Validate user configuration |
| `BINARY_ARRAY` | `preflight_binaries.sh` | Validate system environment |
| `PIPELINE_ARRAY` | `preflight_pipeline.sh` | Validate module scripts |
| `PREFLIGHT_ARRAY` | `preflight.sh` | Define validation order |


# Key Rules
- Do not include logic or validation in arrays
- Do not dynamically modify arrays at runtime
- Ensure all entries correspond to real entities (variables, scripts, binaries)
- Maintain strict alignment with preflight and pipeline layers
- Keep contracts minimal — no unused entries
- Ensure export contract reflects actual downstream consumption

# Summary
The `arrays/` directory defines the contractual backbone of the pipeline:
- what must be provided (variables)
- what must exist (binaries)
- what will be executed (modules)
- in what order validation occurs (preflight)
- and what state crosses execution boundaries (export ABI)

All pipeline behaviour is derived from these declarations, ensuring:
- deterministic execution
- reproducibility
- strict contract-driven validation
- clean separation between validation and execution