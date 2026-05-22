#!/bin/bash

# PREFLIGHT_ARRAY:
# Ordered list of preflight scripts executed during pipeline validation.
# This array defines all preflight checks required to safely run the pipeline.
# Each script is sourced sequentially by preflight.sh before any pipeline
# modules are executed.
#
# Define preflight array (all preflight scripts, order is significant)
PREFLIGHT_ARRAY=(
    "preflight_variables.sh"
    "preflight_input.sh"
    "preflight_commands.sh"
    "preflight_scripts.sh"
    "preflight_sratoolkit.sh"
)

# SCRIPT_ARRAY:
# Ordered list of module scripts that comprise the sra-download pipeline.
#
# Scope:
#   - Used by preflight_scripts.sh to verify existence, content, and executability.
SCRIPT_ARRAY=(
    "submit_array.sh"
    "convert_sra.sh"
)

# EXPORT_ARRAY:
# Ordered list of pipeline-owned variables that define the execution ABI
# for all downstream pipeline components.
#
# Scope:
#   - Enumerates variables that must cross execution boundaries
#     (e.g. from run_pipeline.sh into SLURM-submitted scripts).
#   - Used by run_pipeline.sh to explicitly export required variables
#     into the environment snapshot passed to sbatch via --export.
#   - Guarded by downstream scripts to enforce deterministic inheritance
#     and prevent reliance on implicit or ambient state.
#
# Guarantees:
#   - All variables in this array are defined exactly once in run_pipeline.sh.
#   - No SLURM-injected variables (e.g. SLURM_ARRAY_TASK_ID) appear here.
#   - Any variable guarded in downstream scripts and not provided by SLURM
#     must be present in EXPORT_ARRAY.
#
# Design note:
#   EXPORT_ARRAY defines the pipeline’s execution ABI, not its logical
#   dependencies. Variables listed here are required for execution context
#   reconstruction in new shells, not for same-shell sourcing.
EXPORT_ARRAY=(
    PIPELINE_DIR
    MODULES_DIR
    UTILS_DIR
    PREFLIGHT_DIR
    OUTPUT_DIR
    SCRIPT_OUTDIR
    LOG_DIR
    ENV_DIR
    INPUT_DIR
    ACCESSION_FILE
    SLURM_MAX_JOBS
    FASTERQ_CPUS
    FASTERQ_MEM_PER_CPU
)

# COMMAND_ARRAY:
# Canonical list of generic external commands required by the sra-convert
# pipeline framework.
#
# Scope:
#   - Validated by preflight_commands.sh.
#   - Includes only framework-level commands used by run_pipeline.sh,
#     preflight scripts, pipeline.sh, or submit_array.sh.
#
# Notes:
#   - Tool-specific binaries (e.g. fasterq-dump) are intentionally excluded
#     and validated by dedicated tool preflight scripts.
COMMAND_ARRAY=(
    sbatch
    grep
    sed
    tr
    xargs
    tee
    mkdir
    gzip
    find
)

# VARIABLE_ARRAY:
# List of required user-defined configuration variables for the sra-download pipeline.
#
# Scope:
#   - Validated by preflight_variables.sh.
#   - Variables must be defined and non-empty in config.sh.
VARIABLE_ARRAY=(
    INPUT_DIR
    ACCESSION_FILE
    SLURM_MAX_JOBS
    FASTERQ_CPUS
    FASTERQ_MEM_PER_CPU
)