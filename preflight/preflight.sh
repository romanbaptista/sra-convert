#!/bin/bash
set -euo pipefail

######################### GUARDS #########################

GUARD_ARRAY=(
    ARRAY_DIR
    PREFLIGHT_DIR
)

for var in "${GUARD_ARRAY[@]}"; do
    variable_check_nonempty "${var}" || fail_message "Variable is empty or not defined: ${var}"
done

######################### SETUP ##########################

# Define script name
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}" .sh)"

######################### SOURCE #########################

# Source array
source "${ARRAY_DIR}/array_preflight.sh"

######################### CHECKS #########################

variable_check_nonempty PREFLIGHT_ARRAY || fail_message "PREFLIGHT_ARRAY is empty or is not set"
array_check_nonempty PREFLIGHT_ARRAY || fail_message "PREFLIGHT_ARRAY has no elements"

######################### MAIN ###########################

echo
echo "RUNNING ${SCRIPT_NAME} ..."
echo "  Running preflight scripts..."

for script in "${PREFLIGHT_ARRAY[@]}"; do
    file_check_exists "${PREFLIGHT_DIR}/${script}" || fail_message "Preflight script doesn't exist: ${script}"
    file_check_nonempty "${PREFLIGHT_DIR}/${script}" || fail_message "Preflight script is empty: ${script}"
    source "${PREFLIGHT_DIR}/${script}" || fail_message "Preflight script failed: ${script}"
done

echo "  Preflight scripts complete"
echo "${SCRIPT_NAME} COMPLETE"