#!/bin/bash
set -euo pipefail

######################### SETUP ##########################

# Define script name
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}" .sh)

######################## SOURCE ##########################

# Source utils file
source "${UTILS_DIR}/arrays.sh"

######################### MAIN ############################

echo "  RUNNING ${SCRIPT_NAME} ..."
echo "  Checking for core user-defined variables..."

# Iterate over variables
for variable in "${VARIABLE_ARRAY[@]}"; do
    check_variable "${variable}" || fail "  Set variable in config.sh: '${variable}'"
done

echo "  All core user-defined variables confirmed"
echo "  ${SCRIPT_NAME} COMPLETE"