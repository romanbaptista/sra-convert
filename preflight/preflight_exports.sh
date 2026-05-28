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
source "${ARRAY_DIR}/array_exports.sh"

######################### CHECKS #########################

variable_check_nonempty EXPORT_ARRAY || fail_message "EXPORT_ARRAY is empty or is not set"
array_check_nonempty EXPORT_ARRAY || fail_message "EXPORT_ARRAY has no elements"

######################### MAIN ###########################

echo
echo "RUNNING ${SCRIPT_NAME} ..."
echo "  Generating export snapshot..."

# Export variables
for var in "${EXPORT_ARRAY[@]}"; do
    export "${var}"
done

# Generate snapshot
SBATCH_EXPORTS="$(IFS=,; echo "${EXPORT_ARRAY[*]}")"
export SBATCH_EXPORTS

echo "  Export snapshot generated"
echo "${SCRIPT_NAME} COMPLETE"