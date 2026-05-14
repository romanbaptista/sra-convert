#!/bin/bash
set -euo pipefail

######################### SETUP ##########################

# Define pipeline name
PIPELINE_NAME="sra-convert"
# Define script name
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}" .sh)

######################### PATHS ##########################

# Define directory paths
PIPELINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="${PIPELINE_DIR}/modules"
PREFLIGHT_DIR="${PIPELINE_DIR}/preflight"
UTILS_DIR="${PIPELINE_DIR}/utils"
LOG_DIR="${PIPELINE_DIR}/logs"
ENV_DIR="${PIPELINE_DIR}/env"
OUTPUT_DIR="${PIPELINE_DIR}/output"
SCRIPT_OUTDIR="${OUTPUT_DIR}/convert_sra"

# Define directories to create
DIR_ARRAY=(
    OUTPUT_DIR
    SCRIPT_OUTDIR
    LOG_DIR
    ENV_DIR
)

# Create directories
for dir in "${DIR_ARRAY[@]}"; do
    mkdir -p "${!dir}"
done

######################### SOURCE ##########################

# Source scripts
source "${PIPELINE_DIR}/config.sh"
source "${UTILS_DIR}/functions_base.sh"
source "${UTILS_DIR}/arrays.sh"

######################### LOGS ############################

# Define log file for this script
LOG_FILE="${LOG_DIR}/${SCRIPT_NAME}.log"
# Redirect stdout/stderr to terminal and log file
exec > >(tee -a "${LOG_FILE}") 2>&1

######################### EXPORT ##########################

# Iterate over items to export
for var in "${EXPORT_ARRAY[@]}"; do
    export "${var}"
done

# Snapshot EXPORT_ARRAY
SBATCH_EXPORTS="$(IFS=,; echo "${EXPORT_ARRAY[*]}")"
export SBATCH_EXPORTS

######################### CHECKS ##########################

echo
echo "PREFLIGHT for ${PIPELINE_NAME} ..."

source "${PREFLIGHT_DIR}/preflight.sh"

echo
echo "Preflight COMPLETE"
echo "Moving to main execution"

######################### MAIN ############################

echo
echo "RUNNING ${PIPELINE_NAME} ${SCRIPT_NAME} ..."

echo
echo "  User configuration:"
echo "      Max SLURM array jobs:       ${SLURM_MAX_JOBS}"
echo "      CPUs allocated per task:    ${FASTERQ_CPUS}"
echo "      Memory per CPU:             ${FASTERQ_MEM_PER_CPU}"
echo "      Output directory:           ${OUTPUT_DIR}"

# Submit pipeline.sh
PIPELINE_JOB_ID=$(
    sbatch \
        --parsable \
        --export="${SBATCH_EXPORTS}" \
        --output="${LOG_DIR}/pipeline.%j.log" \
        "${MODULES_DIR}/pipeline.sh"
) || fail "  ERROR: Failed to submit pipeline.sh"

echo
echo "Pipeline Job ID: ${PIPELINE_JOB_ID}"
echo "${PIPELINE_NAME} ${SCRIPT_NAME} COMPLETE"
echo 