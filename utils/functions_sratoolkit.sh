#!/bin/bash

# check_sratoolkit
# Verifies that a coherent SRA Toolkit installation is available on PATH.
#
# Arguments:
#   None
#
# Operation:
#   - Resolves the path to the 'prefetch' executable.
#   - Derives the SRA Toolkit root directory from the executable location.
#   - Confirms that required SRA Toolkit commands (prefetch, fasterq-dump,
check_sratoolkit() {
    local prefetch_path
    local sra_dir

    # Get prefecth path
    prefetch_path="$(command -v prefetch)" || return 1
    # Get parent directory
    sra_dir="$(get_parent_directory "${prefetch_path}")"

    # Check for all commands in directory
    if [[ -x "${sra_dir}/bin/prefetch" && -x "${sra_dir}/bin/fasterq-dump" && -x "${sra_dir}/bin/vdb-config" ]]; then
        # Export the relevant directory
        export SRA_DIR="${sra_dir}"
        echo "  SRA Toolkit already installed"
        return 0
    else
        return 1
    fi
}

# download_sratoolkit
# Downloads the SRA Toolkit archive to the user's home directory.
#
# Arguments:
#   $1 - Name of the SRA Toolkit archive file
#   $2 - URL from which to download the archive
#
# Operation:
#   - Validates that required arguments are provided.
#   - Checks for an existing archive in the user's home directory.
#   - Downloads the archive using wget if not already present.
#
# Notes:
#   - Does not perform extraction or installation.
#   - Network access and wget availability are assumed to have been
#     validated by earlier preflight checks.
#
# Returns:
#   0 if the archive already exists or is downloaded successfully
#   1 on download failure
#   2 if required arguments are missing
#
# Example:
#   download_sratoolkit "${SRA_ARCHIVE}" "${SRA_URL}"
download_sratoolkit() {
    local archive="$1"
    local url="$2"

    check_arg "${archive}" || return $?
    check_arg "${url}" || return $?

    echo "  Checking for existing SRA Toolkit archive: ${archive}..."

    # Check for existing archive
    [[ -f "${HOME}/${archive}" ]] && return 0

    echo "  Downloading SRA Toolkit archive..."

    # Download SRA Toolkit archive
    wget -q -O "${HOME}/${archive}" "${url}" || return 1

    echo "  Archive downloaded"
}

# extract_sratoolkit
# Extracts the SRA Toolkit archive to a specified directory.
#
# Arguments:
#   $1 - Name of the SRA Toolkit archive file
#   $2 - Target extraction directory
#
# Operation:
#   - Validates that required arguments are provided.
#   - Removes any existing extraction directory to ensure a clean install.
#   - Extracts the archive into the user's home directory.
#   - Updates PATH in the current shell to include the extracted binaries.
#
# Notes:
#   - PATH modification is temporary and scoped to the calling shell.
#   - Persistence of PATH updates is handled separately via environment files.
#
# Returns:
#   0 on successful extraction
#   1 on extraction failure
#   2 if required arguments are missing
#
# Example:
#   extract_sratoolkit "${SRA_ARCHIVE}" "${EXTRACT_DIR}"
extract_sratoolkit() {
    local archive="$1"
    local extract_dir="$2"

    check_arg "${archive}" || return $?
    check_arg "${extract_dir}" || return $?

    # Remove any existing extraction directory
    rm -rf "${extract_dir}"
    # Extract archive
    tar -xzf "${HOME}/${archive}" -C "${HOME}" || return 1
    # Export extract directory to PATH
    export PATH="${extract_dir}/bin:${PATH}"
}

# install_sratoolkit
# Installs the SRA Toolkit by downloading, extracting, and validating it.
#
# Arguments:
#   $1 - Name of the SRA Toolkit archive file
#   $2 - URL from which to download the archive
#   $3 - Target extraction directory
#   $4 - Path to the environment file (for documentation purposes)
#
# Operation:
#   - Validates that required arguments are provided.
#   - Downloads the SRA Toolkit archive if not already present.
#   - Extracts the archive into the specified directory.
#   - Verifies that the installed toolkit is available on PATH.
#
# Notes:
#   - Does not write the environment file; callers are responsible for
#     persistence via write_env().
#   - Intended to be used conditionally after a failed check_sratoolkit().
#
# Returns:
#   0 on successful installation and validation
#   Exits via fail() on installation or validation errors
#
# Example:
#   install_sratoolkit "${SRA_ARCHIVE}" "${SRA_URL}" "${EXTRACT_DIR}" "${SRA_ENV}"
install_sratoolkit() {
    local archive="$1"
    local url="$2"
    local extract_dir="$3"

    check_arg "${archive}" || return $?
    check_arg "${url}" || return $?
    check_arg "${extract_dir}" || return $?
    
    download_sratoolkit "${archive}" "${url}" || fail "  Unable to download SRA Toolkit using 'wget'"
    extract_sratoolkit "${archive}" "${extract_dir}" || fail "  Unable to extract SRA Toolkit archive using 'tar'"
    echo "  Confirming installation..."
    check_sratoolkit || fail "  SRA Toolkit install may have failed"

    return 0
}