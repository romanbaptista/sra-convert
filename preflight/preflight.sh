#!/bin/bash
set -euo pipefail

######################### GUARDS ##########################

: "${PREFLIGHT_DIR:?PREFLIGHT_DIR not set (check PATHS section in run_pipeline.sh)}"
: "${PREFLIGHT_ARRAY:?PREFLIGHT_ARRAY not set (check arrays.sh)}"
: "${UTILS_DIR:?UTILS_DIR not set (check PATHS section in run_pipeline.sh)}"

######################### SETUP ##########################

# Define script name
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}" .sh)

######################## SOURCE ##########################

# Source utils file
source "${UTILS_DIR}/arrays.sh"

######################### MAIN ############################

echo "  RUNNING ${SCRIPT_NAME} ..."

# Iterate through preflight checks
for file in "${PREFLIGHT_ARRAY[@]}"; do
    check_file "${PREFLIGHT_DIR}/${file}" || fail "  Please ensure that preflight script exists: ${file}"
    check_file_data "${PREFLIGHT_DIR}/${file}" || fail "  Please ensure that preflight script contains data: ${file}"
    source "${PREFLIGHT_DIR}/${file}"
done

echo
echo "  ${SCRIPT_NAME} COMPLETE"