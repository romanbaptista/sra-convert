#!/bin/bash

####################################################### FUNCTIONS

# write_env
write_env() {
    local install_dir="${1-}"
    local env_file="${2-}"

    arg_check_nonempty "${install_dir}" || return $?
    arg_check_nonempty "${env_file}" || return $?

    cat > "${env_file}" <<EOF
export TOOL_DIR="${install_dir}"
export PATH="\${TOOL_DIR}/bin:\${PATH}"
EOF
}