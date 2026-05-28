#!/bin/bash

######################### GUARDS #########################

GUARD_ARRAY=(
    ARRAY_DIR
    PIPELINE_DIR
)

for var in "${GUARD_ARRAY[@]}"; do
    variable_check_nonempty "${var}" || fail_message "Variable is empty or not defined: ${var}"
done

######################### SETUP ##########################

# Define script name
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}" .sh)"

######################### SOURCE #########################

# Source array
source "${ARRAY_DIR}/array_pipeline.sh"

######################### CHECKS #########################

variable_check_nonempty PIPELINE_ARRAY || fail_message "PIPELINE_ARRAY is empty or is not set"
array_check_nonempty PIPELINE_ARRAY || fail_message "PIPELINE_ARRAY has no elements"

######################### MAIN ###########################

echo
echo "RUNNING ${SCRIPT_NAME} ..."
echo "  Validating pipeline scripts..."

for script in "${PIPELINE_ARRAY[@]}"; do  
    file_check_exists "${PIPELINE_DIR}/${script}" || fail_message "Pipeline script not found: ${script}"
    file_check_nonempty "${PIPELINE_DIR}/${script}" || fail_message "Pipeline script is empty: ${script}"
    file_enforce_executable "${PIPELINE_DIR}/${script}" || fail_message "Failed to make pipeline script executable: ${script}"
done

echo "  Scripts validated"
echo "  Checking for pipeline.sh orchestrator..."

file_check_exists "${PIPELINE_DIR}/pipeline.sh" || fail_message "pipeline.sh not found"
file_check_nonempty "${PIPELINE_DIR}/pipeline.sh" || fail_message "pipeline.sh is empty"
file_enforce_executable "${PIPELINE_DIR}/pipeline.sh" || fail_message "Failed to make pipeline.sh executable"

echo "  Orchestrator confirmed"
echo "${SCRIPT_NAME} COMPLETE"