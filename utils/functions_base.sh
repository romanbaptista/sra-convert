#!/bin/bash

# check_file
# Verifies that a path exists as a regular file.
#
# Arguments:
#   $1 - Path to the file to check
#
# Operation:
#   - Checks that the path exists and is a regular file using [[ -f ]].
#   - Emits informational messages describing the result.
#
# Returns:
#   0 if the file exists and is a regular file
#   1 if the file does not exist or is not a regular file
#
# Example:
#   check_file "/path/to/file.txt"
check_file() {

    local path="$1"

    if [[ -f "${path}" ]]; then
        echo "  SUCCESS: File found: ${path}"
        return 0
    else
        echo "  ERROR: File not found: ${path}"
        return 1
    fi
}

# check_file_data
# Verifies that a file exists and contains data (non-zero size).
#
# Arguments:
#   $1 - Path to the file to check
#
# Operation:
#   - Checks that the file exists and has size greater than zero using [[ -s ]].
#   - Emits informational messages describing the result.
#
# Returns:
#   0 if the file exists and contains data
#   1 if the file is missing or empty
#
# Example:
#   check_file_data "results.txt"
check_file_data() {

    local path="$1"

    if [[ -s "${path}" ]]; then
        echo "  SUCCESS: File contains data: ${path}"
        return 0
    else
        echo "  ERROR: File does not contain data: ${path}"
        return 1
    fi
}

# make_executable
# Adds executable permissions to a file.
#
# Arguments:
#   $1 - Path to the file to modify
#
# Operation:
#   - Attempts to add the executable bit using chmod +x.
#   - Emits informational messages describing the result.
#
# Returns:
#   0 if permissions were successfully modified
#   1 if chmod fails
#
# Example:
#   make_executable "script.sh"
make_executable() {
    local path="$1"

    if chmod +x "${path}"; then
        echo "  SUCCESS: File is now executable: ${path}"
        return 0
    else
        echo "  ERROR: Failed to make file executable: ${path}"
        return 1
    fi
}


# check_executable
# Verifies that a path exists as a regular file and has the executable bit set.
#
# Arguments:
#   $1 - Path to the file to check
#
# Operation:
#   - Checks that the file exists as a regular file using [[ -f ]].
#   - Checks that the file is executable using [[ -x ]].
#   - Emits informational messages describing the result.
#
# Returns:
#   0 if the file exists and is executable
#   1 if the file does not exist or exists but is not executable
#
# Example:
#   check_executable "./run.sh"
check_executable() {
    local path="$1"

    if [[ ! -f "${path}" ]] || {
        echo "  ERROR: Please ensure file exists: ${path}"
        return 1
    }

    if [[ -x "${path}" ]]; then
        echo "  SUCCESS: File is executable: ${path}"
        return 0
    else
        echo "  ERROR: File is not executable: ${path}"
        return 1
    fi
}

# check_directory
# Verifies that a path exists as a directory.
#
# Arguments:
#   $1 - Path to the directory to check
#
# Operation:
#   - Checks that the path exists and is a directory using [[ -d ]].
#   - Emits informational messages describing the result.
#
# Returns:
#   0 if the directory exists
#   1 if the directory does not exist
#
# Example:
#   check_directory "/data/output"
check_directory() {
    local path="$1"

    if [[ -d "${path}" ]]; then
        echo "  SUCCESS: Directory found: ${path}"
        return 0
    else
        echo "  ERROR: Directory not found: ${path}"
        return 1
    fi
}

# check_string
# Verifies that a string value is non-empty.
#
# Arguments:
#   $1 - String value to check
#
# Operation:
#   - Checks that the string has non-zero length using [[ -n ]].
#   - Emits informational messages describing the result.
#
# Returns:
#   0 if the string is non-empty
#   1 if the string is empty or unset
#
# Example:
#   check_string "${SAMPLE_ID}"
check_string() {
    local string="$1"

    if [[ -n "${string}" ]]; then
        echo "  SUCCESS: String found: ${string}"
        return 0
    else
        echo "  ERROR: String empty or not set: ${string}"
        return 1
    fi
}

# check_variable
# Verifies that a named variable is set and non-empty.
#
# Arguments:
#   $1 - Variable name (string)
#
# Operation:
#   - Uses indirect expansion (${!name}) to read the variable value.
#   - Checks that the value is non-empty.
#   - Emits informational messages describing the result.
#
# Returns:
#   0 if the variable exists and is non-empty
#   1 if the variable is unset or empty
#
# Example:
#   check_variable "BIOPROJECT"
check_variable() {
    local name="$1"
    local value="${!name-}"

    if [[ -n "${value//[[:space:]]/}" ]]; then
        echo "  SUCCESS: Variable set: ${name}"
        return 0
    else
        echo "  ERROR: Variable not set or contains only whitespaces: ${name}"
        return 1
    fi
}

# check_command
# Verifies that a command is available in the PATH.
#
# Arguments:
#   $1 - Command name to check
#
# Operation:
#   - Uses command -v to test command availability.
#   - Emits informational messages describing the result.
#
# Returns:
#   0 if the command is found in PATH
#   1 if the command is not found
#
# Example:
#   check_command samtools

check_command() {
    local cmd="$1"

    if command -v "${cmd}" >/dev/null 2>&1; then
        echo "  SUCCESS: Command found: ${cmd}"
        return 0
    else
        echo "  ERROR: Command not found ${cmd}"
        return 1
    fi
}

# fail
# Prints an error message and terminates execution.
#
# Arguments:
#   All arguments are treated as an error message.
#
# Operation:
#   - Prints the message to stderr.
#   - Prints a generic exit notice.
#   - Exits the script with status 1.
#
# Returns:
#   Does not return.
#
# Example:
#   fail "Configuration file missing"
fail () {
    echo "  $*" >&2
    echo "  Exiting..." >&2
    exit 1
}

# check_arg
# Verifies that a required function argument is provided.
#
# Arguments:
#   $1 - Argument value to check
#
# Operation:
#   - Checks that the argument is non-empty.
#   - On failure, prints the calling function name.
#
# Returns:
#   0 if the argument is non-empty
#   2 if the argument is missing (programmer / usage error)
#
# Example:
#   check_arg "$DIR" || return $?
check_arg() {
    if [[ -n "$1" ]] || {
        echo "    ${FUNCNAME[1]}: required argument missing" >&2
        return 2
    }
}

# write_env
# Writes an environment file exporting a tool installation
# directory and updating PATH accordingly.
#
# Arguments:
#   $1 - Path to the tool installation directory
#   $2 - Destination environment file path
#
# Operation:
#   - Validates that both arguments are provided.
#   - Writes an environment file that exports:
#       * TOOL_DIR (installation root)
#       * PATH with ${TOOL_DIR}/bin prepended
#   - Overwrites the environment file if it already exists.
#
# Intended use:
#   The resulting environment file is sourced by downstream scripts
#   to ensure a consistent and reproducible tool configuration.
#
# Returns:
#   0 on success
#   2 if a required argument is missing (programmer / usage error)
#
# Example:
#   write_env "${SRA_DIR}" "${PIPELINE_DIR}/env/sratoolkit.env"
write_env() {
    local install_dir="$1"
    local env_file="$2"

    check_arg "${install_dir}" || return $?
    check_arg "${env_file}" || return $?

    cat > "${env_file}" << EOF
export TOOL_DIR="${install_dir}"
export PATH="\${TOOL_DIR}/bin:\${PATH}"
EOF
}

# get_directory
# Returns the directory containing the given file or directory path.
#
# Arguments:
#   $1 - File or directory path
#
# Operation:
#   - Validates that the argument is provided.
#   - Resolves the directory component of the path using dirname.
#   - Returns the absolute, canonical directory path.
#
# Notes:
#   - Relative paths are resolved to absolute paths.
#   - The caller's working directory is not modified.
#
# Returns:
#   Absolute path of the containing directory on success
#   1 if the argument is missing or resolution fails
#
# Example:
#   DIR="$(get_directory "/path/to/file.txt")"
#   DIR="$(get_directory "${BASH_SOURCE[0]}")"
get_directory() {
    local path="$1"

    check_arg "${path}" || return 1

    cd "$(dirname -- "${path}")" && pwd
}

# get_parent_directory
# Returns the parent directory of the directory containing
# the given file or directory path.
#
# Arguments:
#   $1 - File or directory path
#
# Operation:
#   - Validates that the argument is provided.
#   - Determines the directory containing the path.
#   - Returns the absolute, canonical parent directory.
#
# Notes:
#   - Equivalent to resolving dirname(path) and ascending one level.
#   - Relative paths are resolved to absolute paths.
#   - The caller's working directory is not modified.
#
# Returns:
#   Absolute path of the parent directory on success
#   1 if the argument is missing or resolution fails
#
# Example:
#   DIR="$(get_parent_directory "/path/to/file.txt")"
#   DIR="$(get_parent_directory "${BASH_SOURCE[0]}")"
get_parent_directory() {
    local path="$1"
    
    check_arg "${path}" || return 1

    cd "$(dirname -- "${path}")/.." && pwd
}