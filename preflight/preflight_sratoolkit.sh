#!/bin/bash

######################### GUARDS #########################

GUARD_ARRAY=(
    UTILS_DIR
    FUNCTIONS_DIR
    ENV_DIR
)

for var in "${GUARD_ARRAY[@]}"; do
    variable_check_nonempty "${var}" || fail_message "Variable is empty or not defined: ${var}"
done

######################### SETUP ##########################

# Define script name
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}" .sh)"
# Define toolname
TOOLNAME="sratoolkit"

######################### SOURCE #########################

source "${UTILS_DIR}/utils_${TOOLNAME}.sh"
source "${FUNCTIONS_DIR}/functions_${TOOLNAME}.sh"
source "${FUNCTIONS_DIR}/functions_pipeline.sh"

######################### CHECKS #########################

CHECK_ARRAY=(
    SRA_VERSION
    SRA_ARCHIVE
    SRA_URL
    SRA_DIR
    SRA_ENV
)

for var in "${CHECK_ARRAY[@]}"; do
    variable_check_nonempty "${var}" || fail_message "Variable is empty or not defined: ${var}"
done

######################### MAIN ###########################

echo
echo "RUNNING ${SCRIPT_NAME} ..."
echo "  Checking for SRA Toolkit..."

# Check required functionality
if tool_check_binary fasterq-dump; then
    tool_check_runtime fasterq-dump || fail_message "fasterq-dump found but not functional"
    tool_check_subcommand fasterq-dump help || fail_message "fasterq-dump help not functional"
    echo "  SRA Toolkit already available"
else
    echo "  SRA Toolkit not found, installing..."
    download_sratoolkit "${SRA_ARCHIVE}" "${SRA_URL}" || fail_message "Failed to download SRA Toolkit"
    extract_sratoolkit "${SRA_ARCHIVE}" "${SRA_DIR}" || fail_message "Failed to extract SRA Toolkit"
    tool_check_binary fasterq-dump || fail_message "fasterq-dump not found after install"
    tool_check_runtime fasterq-dump || fail_message "fasterq-dump not functional after install"
    echo "  SRA Toolkit installed"

fi

# Get binary location
FASTERQ_PATH="$(command -v fasterq-dump)" || fail_message "Unable to resolve fasterq-dump path"
# Get toolkit directory
SRA_DIR="$(cd "$(dirname "${FASTERQ_PATH}")/.." && pwd)"
# Validate SRA_DIR
variable_check_nonempty SRA_DIR || fail_message "Failed to derive toolkit directory"

echo "  SRA Toolkit confirmed"
echo "  Writing SRA Toolkit .env file..."

write_env "${SRA_DIR}" "${SRA_ENV}" || fail_message "Failed to write SRA Toolkit environment file"
file_check_exists "${SRA_ENV}" || fail_message "File not found: ${SRA_ENV}"
file_check_nonempty "${SRA_ENV}" || fail_message "File is empty: ${SRA_ENV}"

echo "  Environment file written: ${SRA_ENV}"
echo "${SCRIPT_NAME} COMPLETE"