#!/bin/bash

####################################################### FUNCTIONS

# arg_check_nonempty
arg_check_nonempty() {
    local arg="${1-}"

    if [[ -z "${arg//[[:space:]]/}" ]]; then
        echo "  ${FUNCNAME[1]}: required argument missing" >&2
        return 2
    fi
}

# array_check_nonempty
array_check_nonempty() {
    local name="${1-}"

    # VALIDATION
    arg_check_nonempty "${name}" || return $?

    # FUNCTION
    local -n arr="${name}"
    [[ "${#arr[@]}" -gt 0 ]]
}

# directory_check_nonempty
directory_check_nonempty() {
    local path="${1-}"

    # VALIDATION
    arg_check_nonempty "${path}" || return $?

    # FUNCTION
    find "${path}" -mindepth 1 -print -quit 2>/dev/null | grep -q .
}

# directory_check_exists
directory_check_exists() {
    local path="${1-}"

    # VALIDATION
    arg_check_nonempty "${path}" || return $?

    # FUNCTION
    [[ -d "${path}" ]]
}

# directory_check_filetype
# ext must include wildcard (e.g. "*.sra")
directory_check_filetype() {
    local path="${1-}"
    local ext="${2-}"

    # VALIDATION
    local arg_array=(
        "${path}"
        "${ext}"
    )

    for arg in "${arg_array[@]}"; do
        arg_check_nonempty "${arg}" || return $?
    done

    # FUNCTION
    find "${path}" -type f -name "${ext}" -print -quit 2>/dev/null | grep -q .
}

# directory_create
directory_create() {
    local path="${1-}"

    # VALIDATION
    arg_check_nonempty "${path}" || return $?

    # FUNCTION
    mkdir -p "${path}"
}

# fail_message
fail_message() {
    local msg="${1-}"

    # VALIDATION
    arg_check_nonempty "${msg}" || return $?

    # FUNCTION
    echo "  EXITING: ${msg}" >&2
    exit 1
}

# file_check_nonempty
file_check_nonempty() {
    local path="${1-}"

    # VALIDATION
    arg_check_nonempty "${path}" || return $?

    # FUNCTION
    [[ -s "${path}" ]]
}

# file_check_executable
file_check_executable() {
    local path="${1-}"

    # VALIDATION
    arg_check_nonempty "${path}" || return $?

    # FUNCTION
    [[ -x "${path}" ]]
}

# file_check_exists
file_check_exists() {
    local path="${1-}"

    # VALIDATION
    arg_check_nonempty "${path}" || return $?

    # FUNCTION
    [[ -f "${path}" ]]
}

# file_enforce_executable
file_enforce_executable() {
    local path="${1-}"

    # VALIDATION
    arg_check_nonempty "${path}" || return $?

    # FUNCTION
    file_check_executable "${path}" || file_make_executable "${path}" || return 1
}

# file_make_executable
file_make_executable() {
    local path="${1-}"

    # VALIDATION
    arg_check_nonempty "${path}" || return $?

    # FUNCTION
    chmod +x "${path}" || return 1
}

# tool_check_binary
tool_check_binary() {
    local tool="${1-}"

    # VALIDATION
    arg_check_nonempty "${tool}" || return $?

    # FUNCTION
    command -v "${tool}" >/dev/null 2>&1
}

# tool_check_runtime
tool_check_runtime() {
    local tool="${1-}"

    # VALIDATION
    arg_check_nonempty "${tool}" || return $?

    # FUNCTION
    "${tool}" -version    >/dev/null 2>&1 || \
    "${tool}" --version   >/dev/null 2>&1
}

# tool_check_subcommand
tool_check_subcommand() {
    local tool="${1-}"
    local cmd="${2-}"


    # VALIDATION
    local arg_array=(
        "${tool}"
        "${cmd}"
    )

    for arg in "${arg_array[@]}"; do
        arg_check_nonempty "${arg}" || return $?
    done

    # FUNCTION
    "${tool}" "${cmd}" -h 2>&1 | grep -q "Usage" || "${tool}" "${cmd}" --help 2>&1 | grep -q "Usage"
}

# variable_check_nonempty
variable_check_nonempty() {
    local name="${1-}"
    local value="${!name-}"

    # VALIDATION
    arg_check_nonempty "${name}" || return $?

    # FUNCTION
    [[ -n "${value//[[:space:]]/}" ]]
}