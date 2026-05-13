#!/bin/bash
set -euo pipefail

######################### GUARDS ##########################

: "${UTILS_DIR:?UTILS_DIR not set (check PATHS section in run_pipeline.sh)}"

######################### SETUP ##########################

# Define script name
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}" .sh)

######################## SOURCE ##########################

# Source utils file
source "${UTILS_DIR}/arrays.sh"

######################### MAIN ############################

echo "  RUNNING ${SCRIPT_NAME} ..."
echo "  Checking all relevant pipeline commands..."

# Iterate over variables
for cmd in "${COMMAND_ARRAY[@]}"; do
    check_command "${cmd}" || fail "  Ensure relevant command or package is installed/available on the cluster: ${cmd}"
done

echo "  All commands confirmed"
echo "  ${SCRIPT_NAME} COMPLETE"