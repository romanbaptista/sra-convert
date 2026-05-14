#!/bin/bash
set -euo pipefail

######################### GUARDS ##########################

: "${INPUT_DIR:?INPUT_DIR not set (check config.sh)}"

######################### SETUP ##########################

# Define script name
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}" .sh)

######################### MAIN ############################

echo "  RUNNING ${SCRIPT_NAME} ..."
echo "  Checking input directory: ${INPUT_DIR}..."

# Check input directory
check_directory "${INPUT_DIR}" || fail "  Please provide an INPUT_DIR in config.sh that exists"

echo "  Input directory confirmed: ${INPUT_DIR}"
echo "  Checking for .sra files..."

# Check for at least one .sra file anywhere under INPUT_DIR
if ! find "${INPUT_DIR}" -type f -name "*.sra" | grep -q .; then
    fail "  ERROR: No .sra files found under INPUT_DIR=${INPUT_DIR}"
fi

echo "  .sra files found"
echo "  Checking accession file: ${ACCESSION_FILE}..."

check_file "${ACCESSION_FILE}" || fail "  Please ensure accession file exists: ${ACCESSION_FILE}"
check_file_data "${ACCESSION_FILE}" || fail "  Please ensure accession file contains data: ${ACCESSION_FILE}"

echo "  Accession file confirmed"
echo "  ${SCRIPT_NAME} COMPLETE"