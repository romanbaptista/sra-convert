#!/bin/bash

######################### MAIN ###########################

# VARIABLE_ARRAY:
# Canonical list of required user-defined configuration variables.
#
# Scope:
#   - Used by preflight_variables.sh for validation.
#   - Variables must be defined in config.sh and non-empty.
#
# Notes:
#   - Only include variables required by THIS pipeline.
#   - Tool-specific or downstream pipeline variables must NOT be listed here.

# Define variable array (config contract)
VARIABLE_ARRAY=(
    INPUT_DIR
    ACCESSION_FILE
    SLURM_MAX_JOBS
    FASTERQ_CPUS
    FASTERQ_MEM_PER_CPU
)