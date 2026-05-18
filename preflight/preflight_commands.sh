#!/bin/bash
set -euo pipefail

######################### GUARDS ##########################

: "${COMMAND_ARRAY:?COMMAND_ARRAY not set (check arrays.sh)}"

######################### SETUP ##########################

# Define script name
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}" .sh)

######################### MAIN ############################

echo "  RUNNING ${SCRIPT_NAME} ..."
echo "  Checking all relevant pipeline commands..."

# Iterate over variables
for cmd in "${COMMAND_ARRAY[@]}"; do
    check_command "${cmd}" || fail "  Ensure relevant command or package is installed/available on the cluster: ${cmd}"
done

echo "  All commands confirmed"
echo "  ${SCRIPT_NAME} COMPLETE"