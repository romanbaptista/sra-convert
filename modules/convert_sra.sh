#!/bin/bash
#SBATCH --job-name=convert_sra
set -euo pipefail

######################### GUARDS ##########################

# Define guard variables
GUARD_ARRAY=(
    PIPELINE_DIR
    INPUT_DIR
    OUTPUT_DIR
    SCRIPT_OUTDIR
    ACCESSION_FILE
    ENV_DIR
    SLURM_CPUS_PER_TASK
    SLURM_ARRAY_TASK_ID
)

# Check guard variables
for var in "${GUARD_ARRAY[@]}"; do
    : "${!var:?${var} not set or not exported (check EXPORT_ARRAY in run_pipeline.sh)}"
done

######################### SETUP ###########################

# Define script name
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}" .sh)

######################### SOURCE ##########################

# Source SRA toolkit environment
source "${PIPELINE_DIR}/env/sratoolkit.env"

######################### PATHS ###########################

# Get SRR ID for task
SRR="$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${ACCESSION_FILE}" | tr -d '\r' | xargs)"
# Check for empty SRR
: "${SRR:?No accession for SLURM_ARRAY_TASK_ID=${SLURM_ARRAY_TASK_ID}}"

# Define input file
SRA_INFILE="${INPUT_DIR}/${SRR}/${SRR}.sra"

# Define output directory
SAMPLE_OUTDIR="${SCRIPT_OUTDIR}/${SRR}"

# Create directories
mkdir -p "${SAMPLE_OUTDIR}"

######################### LOGS ############################

# Define sample log
SAMPLE_LOG="${SAMPLE_OUTDIR}/${SRR}.log"
# Redirect all stdout/stderr to per-sample log
exec > >(tee -a "${SAMPLE_LOG}") 2>&1

######################### MAIN ############################

echo
echo "RUNNING ${SCRIPT_NAME} ..."

echo
echo "  Info:"
echo "      Input directory:            ${INPUT_DIR}"
echo "      Array task ID:              ${SLURM_ARRAY_TASK_ID}"
echo "      CPUs allocated per task:    ${SLURM_CPUS_PER_TASK}"
echo "      SRA to convert:             ${SRR}"
echo "      Output directory:           ${SAMPLE_OUTDIR}"

echo

# Check if FASTQ files already exist (restart-safe skip)
if compgen -G "${SAMPLE_OUTDIR}/*.fastq.gz" > /dev/null; then
    echo "  FASTQ files already exist; skipping conversion"
    exit 0
fi

# Cleanup partial FASTQs on error
trap 'rm -f "${SAMPLE_OUTDIR}"/*.fastq "${SAMPLE_OUTDIR}"/*.fastq.gz' ERR

echo "  Converting ${SRR} to FASTQ..."

# Convert SRA file
fasterq-dump \
    "${SRA_INFILE}" \
    --split-files \
    --threads "${SLURM_CPUS_PER_TASK}" \
    --outdir "${SAMPLE_OUTDIR}"

echo "  Conversion complete"
echo "  Compressing FASTQ files..."

# Compress and delete uncompressed files
gzip -f "${SAMPLE_OUTDIR}"/*.fastq

echo "  Compression complete"

echo
echo "${SCRIPT_NAME} COMPLETE"
echo