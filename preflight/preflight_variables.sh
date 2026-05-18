#!/bin/bash
set -euo pipefail

######################### GUARDS ##########################

: "${VARIABLE_ARRAY:?VARIABLE_ARRAY not set (check arrays.sh)}"

######################### SETUP ##########################

# Define script name
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}" .sh)

######################### MAIN ############################

echo "  RUNNING ${SCRIPT_NAME} ..."
echo "  Checking for core user-defined variables..."

# Iterate over variables
for variable in "${VARIABLE_ARRAY[@]}"; do
    check_variable "${variable}" || fail "  Set variable in config.sh: '${variable}'"
done

echo "  All core user-defined variables confirmed"
echo "  ${SCRIPT_NAME} COMPLETE"