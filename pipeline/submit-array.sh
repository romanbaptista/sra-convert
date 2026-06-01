#!/bin/bash
set -euo pipefail

######################### GUARDS #########################

GUARD_ARRAY=(
    ACCESSION_FILE
    SBATCH_EXPORTS
    SLURM_MAX_JOBS
    PIPELINE_DIR
)

for var in "${GUARD_ARRAY[@]}"; do
    variable_check_nonempty "${var}" || fail_message "Guard check failed: ${var}"
done

######################### SETUP ##########################

# Define script name
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}" .sh)"

######################### MAIN ###########################

# Get non-empty accession count
SRA_COUNT=$(grep -cve '^\s*$' "${ACCESSION_FILE}")
variable_check_nonempty SRA_COUNT || fail_message "SRA_COUNT is empty or not set"

echo
echo "RUNNING ${SCRIPT_NAME} ..."

echo "  Submitting array..."

# Submit array
sbatch \
    --export="${SBATCH_EXPORTS}" \
    --job-name=sra-fastq \
    --array=1-${SRA_COUNT}%${SLURM_MAX_JOBS} \
    --cpus-per-task="${FASTERQ_CPUS}" \
    --mem-per-cpu="${FASTERQ_MEM_PER_CPU}" \
    "${PIPELINE_DIR}/sra-fastq.sh"

echo "  Array submitted"
echo "${SCRIPT_NAME} COMPLETE"