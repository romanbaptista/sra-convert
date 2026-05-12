#!/bin/bash
set -euo pipefail

######################### GUARDS ##########################

# Define guard variables
GUARD_ARRAY=(
    PIPELINE_DIR
    MODULES_DIR
    LOG_DIR
    INPUT_DIR
    ACCESSION_FILE
    SLURM_MAX_JOBS
    FASTERQ_CPUS
    FASTERQ_MEM_PER_CPU
    SBATCH_EXPORTS
)

# Check guard variables
for var in "${GUARD_ARRAY[@]}"; do
    : "${!var:?${var} not set or not exported (check EXPORT_ARRAY in run_pipeline.sh)}"
done

######################### SETUP ##########################

# Define script name
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}" .sh)

######################### LOGS ############################

# Define log file for this script
LOG_FILE="${LOG_DIR}/${SCRIPT_NAME}.log"
# Redirect stdout/stderr to terminal and log file
exec > >(tee -a "${LOG_FILE}") 2>&1

######################### MAIN ############################

# Get non-empty accession count
SRR_COUNT=$(grep -cve '^\s*$' "${ACCESSION_FILE}")
# Check count
: "${SRR_COUNT:?Failed to determine SRR_COUNT from ACCESSION_FILE}"

echo
echo "RUNNING ${SCRIPT_NAME} ..."

echo
echo "  Info:"
echo "      Input directory:                ${INPUT_DIR}"
echo "      Number of accessions:           ${SRR_COUNT}"
echo "      Maximum concurrent tasks:       ${SLURM_MAX_JOBS}"
echo "      CPUs allocated per task:        ${FASTERQ_CPUS}"
echo "      Memory per CPU:                 ${FASTERQ_MEM_PER_CPU}"

echo
echo "  Submitting SLURM array..."

# Submit SLURM array
sbatch \
    --export="${SBATCH_EXPORTS}" \
    --job-name=convert_sra \
    --array=1-${SRR_COUNT}%${SLURM_MAX_JOBS} \
    --cpus-per-task="${FASTERQ_CPUS}" \
    --mem-per-cpu="${FASTERQ_MEM_PER_CPU}" \
    "${MODULES_DIR}/convert_sra.sh"

echo "  Array submitted"

echo
echo "${SCRIPT_NAME} COMPLETE"
echo