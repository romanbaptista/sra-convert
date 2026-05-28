#!/bin/bash

# NOTE:
# Defines base directory variables derived from ROOT_DIR.
# Also initialises DIR_ARRAY with core directories required by all pipelines.
# DIR_ARRAY contains variable names, not literal paths.
# Values are resolved via indirect expansion downstream.

######################### MAIN ###########################

# Define base directories
ARRAY_DIR="${ROOT_DIR}/arrays"
FUNCTIONS_DIR="${ROOT_DIR}/functions"
PIPELINE_DIR="${ROOT_DIR}/pipeline"
PREFLIGHT_DIR="${ROOT_DIR}/preflight"
UTILS_DIR="${ROOT_DIR}/utils"
OUTPUT_DIR="${ROOT_DIR}/output"

# Define DIR_ARRAY
# Only pipeline-owned writable directories belong in DIR_ARRAY
DIR_ARRAY=(
    OUTPUT_DIR
)