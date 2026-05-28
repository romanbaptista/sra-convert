# `pipeline`

# Overview
The `pipeline/` directory contains the execution layer of the pipeline.

| File | Responsibility |
|------|----------------|
| `pipeline.sh` | Orchestrates execution and submits controller module |
| `submit-array.sh` | Submits SLURM array jobs |
| `sra-fastq.sh` | Converts `.sra` files to FASTQ (one task per accession) |

These scripts implement the data processing workflow, operating on a fully validated environment created by the preflight layer.

All execution in this directory assumes that:
- all required variables are defined
- all required tools are installed and functional
- all directories are correctly initialised

No validation or setup logic is duplicated here.

# Module Naming Convention
Module scripts follow the pattern:
```text
<input>-<output>.sh
```

This reflects the transformation performed at each stage of the pipeline.

Examples in this pipeline:
```text
sra-fastq.sh        → converts .sra → FASTQ
submit-array.sh     → submits array jobs (control module)
```

This convention provides:
- clear indication of data flow (for transformation modules)
- consistent naming across pipelines
- improved readability in logs and outputs

Control modules may use descriptive names when no direct data transformation is performed.

# Design Contract
All scripts in this directory adhere to the following principles:
- single responsibility per script
- execution-only (no validation logic beyond guards)
- explicit input and output paths
- deterministic behaviour
- no reliance on implicit working directories
- no reliance on undeclared global state
- compatibility with SLURM execution boundaries

Modules assume that all preflight invariants have already been enforced.

# Execution Model
The execution layer is orchestrated by `pipeline.sh`.

This script:
- runs as a SLURM job
- consumes a fully validated environment
- submits downstream execution tasks

Execution behaviour is defined indirectly via:
- explicit module references (not ordered arrays)
- SLURM submission logic

Unlike sequential pipelines, this implementation uses:
- controller module (`submit-array.sh`)
→ submits work units

- execution module (`sra-fastq.sh`)
→ performs parallel computation

| Component | Role |
|----------|------|
| Orchestrator (`pipeline.sh`) | Controls job submission |
| Controller module (`submit-array.sh`) | Defines array execution |
| Execution module (`sra-fastq.sh`) | Performs per-accession processing |

## `pipeline.sh`

### Role
- `pipeline.sh` is the internal orchestrator for the execution layer.
- It coordinates SLURM job submission but performs no data processing itself.

### Responsibilities
- configures pipeline logging
- submits the controller module (`submit-array.sh`) via SLURM
- passes the execution ABI via SBATCH_EXPORTS
- ensures fail-fast behaviour on job submission

### Guarantees
- deterministic orchestration
- no duplication of preflight validation
- explicit environment propagation
- separation of orchestration from computation

# Module Overview
Each module implements a single responsibility.

Modules are:
- execution-only
- stateless beyond defined inputs/outputs
- restart-safe where applicable
- fully dependent on preflight guarantees

## `submit-array.sh`

### Role
Submits a SLURM job array to process all accessions.

### Inputs
```text
ACCESSION_FILE
SLURM_MAX_JOBS
FASTERQ_CPUS
FASTERQ_MEM_PER_CPU
```

### Workflow
- counts the number of accessions in `ACCESSION_FILE`
- submits a SLURM array job via sbatch
- maps each array index to a single accession
- controls concurrency via `SLURM_MAX_JOBS`

### Outputs
SLURM array job execution (no direct file outputs)

### Guarantees
- correct array size (matches accession list)
- controlled parallel execution
- no duplication of work orchestration logic

## `sra-fastq.sh`

### Role
Converts a single `.sra` file into FASTQ format.

### Inputs
```text
SLURM_ARRAY_TASK_ID
ACCESSION_FILE
INPUT_DIR
FASTQ_OUTDIR
SRA_ENV
```

### Workflow
- resolves accession from `ACCESSION_FILE` using array index
- constructs input file path
- initialises per-accession output directory
- sources SRA Toolkit environment
- performs conversion using fasterq-dump
- compresses resulting FASTQ files
- skips processing if output already exists

### Outputs
```text
output/sra-fastq/
└── SRRXXXXXXXX/
    ├── SRRXXXXXXXX_1.fastq.gz
    ├── SRRXXXXXXXX_2.fastq.gz
    └── SRRXXXXXXXX.log
```

### Guarantees
- per-accession isolation
- restart-safe behaviour
- deterministic output structure
- parallel execution across compute nodes

# Execution Boundary Considerations
This pipeline is SLURM-native and operates across execution boundaries.

Key principles:
- preflight and orchestration run in a shared shell
- execution modules run in separate SLURM jobs
- environment must be explicitly reconstructed

This is achieved through:
- `EXPORT_ARRAY` → defines required variables
- `SBATCH_EXPORTS` → passes variables to SLURM

Modules:
- rely only on exported variables
- do not assume inherited state

# Logging Model
The pipeline implements a hierarchical logging structure:
- entrypoint → global pipeline log
- `pipeline.sh` → orchestration log
- `submit-array.sh` → SLURM job log
- `sra-fastq.sh` → per-accession logs

This ensures:
- traceability across all stages
- isolation of parallel execution logs
- reproducible debugging

# Key Rules
- do not include validation logic in modules
- do not install tools during execution
- do not modify global configuration
- always use explicit paths
- ensure restart-safe behaviour
- maintain strict separation between orchestration and execution
- never rely on implicit environment state across SLURM boundaries

# Summary
The `pipeline/` directory implements the execution phase of the pipeline.

It provides:
- a SLURM-based orchestration layer
- scalable, parallel execution via array jobs
- strict separation between control and computation

This design ensures that all runtime behaviour is:
- deterministic
- reproducible
- scalable across HPC environments
- easy to extend and maintain