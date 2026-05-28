#!/bin/bash

######################### MAIN ###########################

# PIPELINE_ARRAY:
# Canonical list of pipeline execution modules.
#
# Scope:
#   - Provides the set of available execution scripts within the pipeline layer.
#   - Consumed by ./pipeline/pipeline.sh to define execution behaviour.
#
# Notes:
#   - This array does NOT enforce execution order.
#   - Modules may be:
#       * executed sequentially,
#       * conditionally selected,
#       * or dispatched based on user configuration or pipeline logic.
#   - Execution order, selection logic, and dependencies are defined solely
#     in ./pipeline/pipeline.sh.
#   - Do NOT include pipeline.sh (the orchestrator) in this array.
#   - All scripts listed here must exist in pipeline/ and pass preflight validation.

# Define pipeline module array
PIPELINE_ARRAY=(
    "submit-array.sh"
    "sra-fastq.sh"
)