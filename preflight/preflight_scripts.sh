#!/bin/bash
set -euo pipefail

######################### GUARDS ##########################

: "${MODULES_DIR:?MODULES_DIR not set (check PATHS section in run_pipeline.sh)}"
: "${UTILS_DIR:?UTILS_DIR not set (check PATHS section in run_pipeline.sh)}"
: "${SCRIPT_ARRAY:?SCRIPT_ARRAY not set (check arrays.sh)}"

######################### SETUP ##########################

# Define script name
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}" .sh)

######################### MAIN ############################

echo "  RUNNING ${SCRIPT_NAME} ..."
echo "  Checking for module scripts..."

# Iterate through scripts
for script in "${SCRIPT_ARRAY[@]}"; do
    check_file "${MODULES_DIR}/${script}" || fail "    Please ensure file exists: ${script}"
    check_file_data "${MODULES_DIR}/${script}" || fail "   Please ensure file contains data: ${script}"
done

echo "  All module scripts confirmed"
echo "  Checking for pipeline.sh ..."

# Check for pipeline.sh
check_file "${MODULES_DIR}/pipeline.sh" || fail "   Please ensure pipeline.sh exists"
check_file_data "${MODULES_DIR}/pipeline.sh" || fail "   Please ensure pipeline.sh contains data"

echo "  pipeline.sh confirmed"
echo "  ${SCRIPT_NAME} COMPLETE"