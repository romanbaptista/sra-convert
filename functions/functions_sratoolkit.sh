#!/bin/bash

# download_sratoolkit
download_sratoolkit() {
    local archive="${1-}"
    local url="${2-}"

    # VALIDATION
    local arg_array=(
        "${archive}"
        "${url}"
    )

    for arg in "${arg_array[@]}"; do
        arg_check_nonempty "${arg}" || return $?
    done

    # FUNCTION
    # Check for existing archive
    if file_check_exists "${HOME}/${archive}" && file_check_nonempty "${HOME}/${archive}"; then
        return 0
    fi

    # Download sratoolkit
    wget -q -O "${HOME}/${archive}" "${url}" || return 1
}

# extract_sratoolkit
extract_sratoolkit() {
    local archive="${1-}"
    local extract_dir="${2-}"

    # VALIDATION
    local arg_array=(
        "${archive}"
        "${extract_dir}"
    )

    for arg in "${arg_array[@]}"; do
        arg_check_nonempty "${arg}" || return $?
    done

    # FUNCTION
    # Remove any existing directory
    rm -rf "${extract_dir}" || return 1
    # Extract archive
    tar -xzf "${HOME}/${archive}" -C "${HOME}" || return 1
    # Ensure path can be seen by current shell
    export PATH="${extract_dir}/bin:${PATH}"
}