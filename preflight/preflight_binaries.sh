#!/bin/bash

######################### GUARDS #########################

GUARD_ARRAY=(
    ARRAY_DIR
)

for var in "${GUARD_ARRAY[@]}"; do
    variable_check_nonempty "${var}" || fail_message "Variable is empty or not defined: ${var}"
done

######################### SETUP ##########################

# Define script name
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}" .sh)"

######################### SOURCE #########################

# Source array
source "${ARRAY_DIR}/array_binaries.sh"

######################### CHECKS #########################

variable_check_nonempty BINARY_ARRAY || fail_message "BINARY_ARRAY is empty or is not set"
array_check_nonempty BINARY_ARRAY || fail_message "BINARY_ARRAY has no elements"

######################### MAIN ###########################

echo
echo "RUNNING ${SCRIPT_NAME} ..."
echo "  Checking required pipeline binaries..."

for cmd in "${BINARY_ARRAY[@]}"; do
    tool_check_binary "${cmd}" || fail_message "Binary not found: ${cmd}"
done

echo "  All required binaries confirmed"
echo "${SCRIPT_NAME} COMPLETE"