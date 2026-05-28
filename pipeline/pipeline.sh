#!/bin/bash
set -euo pipefail

######################### GUARDS #########################

GUARD_ARRAY=(
    LOG_DIR
    PIPELINE_DIR
    SBATCH_EXPORTS
)

for var in "${GUARD_ARRAY[@]}"; do
    variable_check_nonempty "${var}" || fail_message "Guard check failed: ${var}"
done

######################### SETUP ###########################

SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}" .sh)"

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
        --job-name=submit_array \
        --export="${SBATCH_EXPORTS}" \
        --output="${LOG_DIR}/submit_array.%j.log" \
        "${PIPELINE_DIR}/submit_array.sh"
) || fail_message "Failed to submit submit_array.sh"

echo "SLURM Job ID: ${SUBMIT_ID}"
echo "${SCRIPT_NAME} COMPLETE"