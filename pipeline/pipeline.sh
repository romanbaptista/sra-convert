#!/bin/bash
set -euo pipefail

######################### GUARDS #########################

GUARD_ARRAY=(
    LOG_DIR
    PIPELINE_DIR
    SBATCH_EXPORTS
    FUNCTIONS_DIR
)

for var in "${GUARD_ARRAY[@]}"; do
    : "${!var:?${var} not set or empty}"
done

######################### SETUP ###########################

SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}" .sh)"

######################### SOURCE ##########################

source "${FUNCTIONS_DIR}/functions_base.sh"

######################### LOGS ###########################

LOG_FILE="${LOG_DIR}/${SCRIPT_NAME}.log"
exec > >(tee -a "${LOG_FILE}") 2>&1

######################### MAIN ###########################

echo
echo "RUNNING ${SCRIPT_NAME} ..."
echo "  Submitting submit_array.sh ..."

SUBMIT_ID=$(
    sbatch \
        --parsable \
        --job-name=sra-convert-array \
        --export="${SBATCH_EXPORTS}" \
        --output="${LOG_DIR}/submit_array.%j.log" \
        "${PIPELINE_DIR}/submit_array.sh"
) || fail_message "Failed to submit submit_array.sh"

echo "SLURM Job ID: ${SUBMIT_ID}"
echo "${SCRIPT_NAME} COMPLETE"