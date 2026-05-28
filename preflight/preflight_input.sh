#!/bin/bash

######################### GUARDS #########################

GUARD_ARRAY=(
    INPUT_DIR
    ACCESSION_FILE
)

for var in "${GUARD_ARRAY[@]}"; do
    variable_check_nonempty "${var}" || fail_message "Variable is empty or not defined: ${var}"
done

######################### SETUP ##########################

# Define script name
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}" .sh)"
# Define filetype pattern
FILE_PATTERN="*.sra"

######################### MAIN ###########################

echo
echo "RUNNING ${SCRIPT_NAME} ..."
echo "  Confirming input directory..."

directory_check_exists "${INPUT_DIR}" || fail_message "Input directory not found: ${INPUT_DIR}"
directory_check_nonempty "${INPUT_DIR}" || fail_message "Input directory is empty: ${INPUT_DIR}"

echo "  Input directory confirmed"
echo "  Confirming ${FILE_PATTERN} files..."

directory_check_filetype "${INPUT_DIR}" "${FILE_PATTERN}" || fail_message "No files matching pattern '${FILE_PATTERN}' found in '${INPUT_DIR}'"

echo "  ${FILE_PATTERN} files confirmed"
echo "  Checking accession file..."

file_check_exists "${ACCESSION_FILE}" || fail_message "Accession file not found: ${ACCESSION_FILE}"
file_check_nonempty "${ACCESSION_FILE}" || fail_message "Accession file is empty: ${ACCESSION_FILE}"

echo "  Accession file validated"
echo "${SCRIPT_NAME} COMPLETE"