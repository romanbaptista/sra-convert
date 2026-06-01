#!/bin/bash
set -euo pipefail

######################### GUARDS #########################

GUARD_ARRAY=(
    SLURM_ARRAY_TASK_ID
    ACCESSION_FILE
    INPUT_DIR
    FASTQ_OUTDIR
    SRA_ENV
    SLURM_CPUS_PER_TASK
)

for var in "${GUARD_ARRAY[@]}"; do
    variable_check_nonempty "${var}" || fail_message "Guard check failed: ${var}"
done

######################### SETUP ##########################

# Define script name
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}" .sh)"

######################### SOURCE ##########################

# Source SRA-Toolkit environment file
source "${SRA_ENV}"

######################### INPUT ##########################

# Define sample ID
SAMPLE_ID="$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${ACCESSION_FILE}" | tr -d '\r' | xargs)"
# Define sample file
SAMPLE_FILE="${INPUT_DIR}/${SAMPLE_ID}/${SAMPLE_ID}.sra"

######################### OUTPUT #########################

# Define output directory
SAMPLE_OUTDIR="${FASTQ_OUTDIR}/${SAMPLE_ID}"
directory_create "${SAMPLE_OUTDIR}" || fail_message "Failed to create directory: ${SAMPLE_OUTDIR}"

######################### LOGS ###########################

# Define sample log
SAMPLE_LOG="${SAMPLE_OUTDIR}/${SAMPLE_ID}.log"
# Redirect all stdout/stderr to per-sample log
exec > >(tee -a "${SAMPLE_LOG}") 2>&1

######################### CHECKS #########################

variable_check_nonempty SAMPLE_ID || fail_message "No accession for SLURM array task ID: ${SLURM_ARRAY_TASK_ID}"
file_check_exists "${SAMPLE_FILE}" || fail_message "File not found: ${SAMPLE_FILE}"
file_check_nonempty "${SAMPLE_FILE}" || fail_message "File is empty: ${SAMPLE_FILE}"


# Check if FASTQ files already exist (restart-safe skip)
if compgen -G "${SAMPLE_OUTDIR}/*.fastq.gz" > /dev/null; then
    echo "  FASTQ files already exist in directory: ${SAMPLE_OUTDIR}"
    echo "  Skipping conversion"
    exit 0
fi

######################### MAIN ###########################

echo
echo "RUNNING ${SCRIPT_NAME} ..."

echo
echo "  Info"
echo "    Array task ID:        ${SLURM_ARRAY_TASK_ID}"
echo "    Sample ID:            ${SAMPLE_ID}"
echo "    Output directory:     ${SAMPLE_OUTDIR}"

# Cleanup partial FASTQs on error
trap 'rm -f "${SAMPLE_OUTDIR}"/*.fastq "${SAMPLE_OUTDIR}"/*.fastq.gz' ERR

echo
echo "  Converting SRA file to FASTQ: ${SAMPLE_ID}.sra ..."

# Convert SRA file
fasterq-dump \
    "${SAMPLE_FILE}" \
    --split-files \
    --threads "${SLURM_CPUS_PER_TASK}" \
    --outdir "${SAMPLE_OUTDIR}"

echo "  Conversion complete"
echo "  Compressing FASTQ files..."

# Compress and delete uncompressed files
gzip -f "${SAMPLE_OUTDIR}"/*.fastq

echo "  Compression complete"
echo "${SCRIPT_NAME} COMPLETE"