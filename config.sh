#!/bin/bash

################################# INPUT #################################

# INPUT_DIR:
# Absolute or relative path to the directory containing input SRA files
# to be processed by the pipeline.
#
# Expected layout:
#   INPUT_DIR/
#     └── <SRR_ACCESSION>/
#           └── <SRR_ACCESSION>.sra
#
# Where <SRR_ACCESSION> corresponds to entries listed in ACCESSION_FILE.
# This directory is typically produced by an upstream pipeline
# (e.g. sra-download) and is treated as read-only by sra-convert.
INPUT_DIR=""

# ACCESSION_FILE:
# Path to a plain-text file containing one SRR accession ID per line.
#
# This file defines the authoritative list of accessions to be processed
# and is used to map SLURM array task IDs to specific samples during
# conversion.
#
# Ordering is significant:
#   - Line N corresponds to SLURM_ARRAY_TASK_ID=N
#   - Blank lines are ignored
ACCESSION_FILE=""

######################### SUBMIT-ARRAY.SH ###########################

# SLURM_MAX_JOBS:
# Maximum number of concurrent SLURM array tasks.
# This value limits how many SRA downloads or conversions are run in
# parallel to avoid overwhelming cluster resources or job limits.
SLURM_MAX_JOBS=20

######################### SRA-FASTQ.SH ##############################

# FASTERQ_CPUS:
# Number of CPU threads allocated per fasterq-dump task.
# Increasing this value can improve conversion speed but will increase
# per-job CPU usage.
FASTERQ_CPUS=8

# FASTERQ_MEM_PER_CPU:
# Amount of memory allocated per CPU thread for fasterq-dump.
# This value is typically passed to the scheduler as memory-per-CPU
# and should be adjusted based on dataset size and cluster policy.
FASTERQ_MEM_PER_CPU=16G