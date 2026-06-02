#!/bin/bash

######################### MAIN ###########################

# EXPORT_ARRAY:
# Canonical list of pipeline variables that define the execution ABI.
#
# Scope:
#   - Defines the complete set of variables exposed to downstream
#     execution scripts (pipeline modules).
#   - Used by preflight_exports.sh to construct an export snapshot
#     of the pipeline environment.
#
# Notes:
#   - This array represents the explicit variable contract between
#     pipeline layers (preflight → execution).
#   - Only variables required by downstream scripts should be included.
#   - Variables listed here must:
#       * be defined during CONFIG or PREFLIGHT stages
#       * be valid and non-empty before export
#
# Execution Model:
#   - In SLURM-based pipelines:
#       EXPORT_ARRAY is converted into SBATCH_EXPORTS and passed via:
#           sbatch --export=...
#   - In non-SLURM pipelines:
#       EXPORT_ARRAY may be used to validate and document the ABI,
#       even if variables are not explicitly passed via the scheduler.
#
# Design Principles:
#   - Defines the pipeline ABI explicitly
#   - Prevents reliance on implicit global variables
#   - Enables reproducibility and portability across environments
#   - Maintains strict separation between validation and execution

# Define export array (execution ABI)
EXPORT_ARRAY=(
    FUNCTIONS_DIR
    ACCESSION_FILE
    INPUT_DIR
    FASTQ_OUTDIR
    SRA_ENV
    PIPELINE_DIR
    SLURM_MAX_JOBS
    FASTERQ_CPUS
    FASTERQ_MEM_PER_CPU
)