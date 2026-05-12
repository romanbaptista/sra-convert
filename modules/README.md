# `modules`
This directory contains the execution modules for the `sra-convert` pipeline.

Each module is responsible for exactly one execution role and operates under a strict, preflight‑validated contract designed for HPC environments where compute‑intensive work must be offloaded to the scheduler.

Modules are coordinated by `modules/pipeline.sh`, which is invoked by `run_pipeline.sh` only after all preflight checks have completed successfully.

# Design Contract
All modules in this directory adhere to the following principles:
- Single responsibility per script
- Explicit, absolute input and output paths
- Strong separation between validation and execution
- Restart‑safe behavior where possible
- Deterministic execution model
- No reliance on implicit working directories
- No reliance on undeclared global state
- No duplication of preflight validation logic
- Assumption that all preflight invariants have already been enforced

Modules do not perform input validation, tool installation, or configuration checks.

All such guarantees are established by the preflight layer.

# Execution Model
`sra-convert` is a scheduler‑backed pipeline:
- Orchestration logic runs on the login node
- Conversion work runs as SLURM array jobs on compute nodes
- Execution order and submission logic are explicit and centralized

The execution flow is:

```text
run_pipeline.sh
  └─ pipeline.sh
       └─ submit_array.sh
            └─ convert_sra.sh (SLURM array jobs)
```

All SLURM submissions occur only after successful preflight validation.

# Module Overview
## `pipeline.sh`
Internal orchestrator for the `sra-convert` pipeline.

### Role
`pipeline.sh` coordinates submission of downstream execution components. It is not intended to be executed directly by end users.

### Workflow
- Runs as a SLURM job submitted by `run_pipeline.sh`
- Re‑establishes pipeline context and logging
- Assumes all preflight checks have succeeded
- Submits the controller module (`submit_array.sh`) via sbatch
- Captures the submitted job ID for diagnostic purposes
- Does not perform data processing itself

### Guarantees
- Deterministic orchestration
- Centralized logging
- No data mutation
- No tool execution
- No duplication of preflight logic

## `submit_array.sh`
Lightweight controller module responsible for submitting the conversion workload.

### Role
`submit_array.sh` submits a SLURM job array that performs SRA‑to‑FASTQ conversion.

It acts as a thin scheduling wrapper, not a compute module.

### Inputs
- `INPUT_DIR`
- `ACCESSION_FILE`
- SLURM configuration variables (`SLURM_MAX_JOBS`, `FASTERQ_CPUS`, `FASTERQ_MEM_PER_CPU`)
- `SBATCH_EXPORTS` (execution ABI snapshot)

### Workflow
Counts SRR accessions from `ACCESSION_FILE`

Submits a SLURM array job:
- One task per SRR accession
- Concurrency capped by `SLURM_MAX_JOBS`

Passes the complete pipeline execution ABI to the array jobs.

### Guarantees
- Does not create pipeline outputs
- Does not validate inputs (assumes preflight)
- Does not perform conversion itself
- Submits exactly one SLURM array job per pipeline run

## `convert_sra.sh`
Leaf execution module responsible for converting a single `.sra` file to FASTQ.

### Role
Each SLURM array task runs one instance of `convert_sra.sh`, converting exactly one SRR accession.

### Inputs
- `.sra` files under `INPUT_DIR`
- SRR accession list (`ACCESSION_FILE`)
- SRA Toolkit environment (`env/sratoolkit.env`)
- SLURM‑injected variables (`SLURM_ARRAY_TASK_ID`, `SLURM_CPUS_PER_TASK`)

### Expected Input Layout
```text
INPUT_DIR/
└── SRRXXXXXXXX/
    └── SRRXXXXXXXX.sra
```

### Workflow
- Resolves SRR accession using `SLURM_ARRAY_TASK_ID`
- Creates a per‑accession output directory
- Converts `.sra` to FASTQ using `fasterq-dump`
- Compresses FASTQ files
- Writes a per‑accession log file
- Skips conversion if output already exists

### Outputs
```text
output/convert_sra/
└── SRRXXXXXXXX/
    ├── SRRXXXXXXXX_1.fastq.gz
    ├── SRRXXXXXXXX_2.fastq.gz
    └── SRRXXXXXXXX.log
```

### Guarantees
- One accession per SLURM task
- No shared state between tasks
- Restart‑safe (completed accessions are skipped)
- Deterministic directory layout
- Assumes all tool and input validation completed in preflight

# Notes
- All modules assume preflight validation has completed successfully
- No module installs software or modifies user environment files
- All filesystem paths are absolute and derived from the pipeline ABI
- No module requires interactive input
- The pipeline is safe to re‑run to resume partial conversions
- Downstream QC, trimming, or alignment pipelines may safely consume outputs