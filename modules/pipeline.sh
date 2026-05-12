#!/bin/bash
set -euo pipefail

######################### GUARDS ##########################

# Define guard variables
GUARD_ARRAY=(
    PIPELINE_DIR
    MODULES_DIR
    UTILS_DIR
    OUTPUT_DIR
    LOG_DIR
    SBATCH_EXPORTS
)

# Check guard variables
for var in "${GUARD_ARRAY[@]}"; do
    : "${!var:?${var} not set or not exported (check EXPORT_ARRAY in run_pipeline.sh)}"
done

######################### SETUP ##########################

# Define script name
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}" .sh)

######################### SOURCE ##########################

# Source base functions
source "${UTILS_DIR}/functions_base.sh"

######################### LOGS ############################

# Define log file for pipeline.sh
LOG_FILE="${LOG_DIR}/${SCRIPT_NAME}.log"
# Redirect stdout/stderr to terminal and log file
exec > >(tee -a "${LOG_FILE}") 2>&1

######################### MAIN ############################

echo
echo "RUNNING ${SCRIPT_NAME} ..."

echo
echo "  Pipeline starting..."
echo "  Submitting submit_array.sh ..."

SUBMIT_ID=$(
    sbatch \
        --parsable \
        --job-name=submit_array \
        --export="${SBATCH_EXPORTS}" \
        --output="${LOG_DIR}/submit_array.%j.log" \
        "${MODULES_DIR}/submit_array.sh"
) || fail "  ERROR: Failed to submit submit_array.sh"

echo
echo "SLURM Job ID: ${SUBMIT_ID}"
echo "${SCRIPT_NAME} SUBMITTED"
echo