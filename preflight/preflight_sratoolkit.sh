#!/bin/bash
set -euo pipefail

######################### GUARDS ##########################

: "${UTILS_DIR:?UTILS_DIR not set (check PATHS section in run_pipeline.sh)}"
: "${ENV_DIR:?ENV_DIR not set (check PATHS section in run_pipeline.sh)}"

######################### SETUP ##########################

# Define script name
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}" .sh)
# Define toolname
TOOLNAME="sratoolkit"

# Define tool parameters
SRA_VERSION="2.10.9"
SRA_ARCHIVE="sratoolkit.${SRA_VERSION}-centos_linux64.tar.gz"
SRA_URL="https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/${SRA_VERSION}/${SRA_ARCHIVE}"

######################## SOURCE ##########################

# Source tool-specific functions
source "${UTILS_DIR}/functions_${TOOLNAME}.sh"

######################### PATHS ###########################

# Define tool extract directory path
EXTRACT_DIR="${HOME}/sratoolkit.${SRA_VERSION}-centos_linux64"
# Define environment file path
ENV_FILE="${ENV_DIR}/${TOOLNAME}.env"

######################### MAIN ############################

echo "  RUNNING ${SCRIPT_NAME} ..."
echo "  Checking for ${TOOLNAME} ${SRA_VERSION} install..."

# Check for sratoolkit
if ! check_sratoolkit; then
    install_sratoolkit "${SRA_ARCHIVE}" "${SRA_URL}" "${EXTRACT_DIR}"
fi

# Write environment file (SRA_DIR exported from check_sratoolkit)
write_env "${SRA_DIR}" "${ENV_FILE}" || fail "  Unable to write SRA Toolkit environment file"

echo "  Environment file written: ${ENV_FILE}"
echo "  Install confirmed: ${TOOLNAME}"
echo "  ${SCRIPT_NAME} COMPLETE"