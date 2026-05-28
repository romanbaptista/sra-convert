#!/bin/bash

######################### MAIN ###########################

# Define tool parameters
SRA_VERSION="2.10.9"
SRA_ARCHIVE="sratoolkit.${SRA_VERSION}-centos_linux64.tar.gz"
SRA_URL="https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/${SRA_VERSION}/${SRA_ARCHIVE}"

# Define extract location for tool
SRA_DIR="${HOME}/sratoolkit.${SRA_VERSION}-centos_linux64"

# Define environment file path
SRA_ENV="${ENV_DIR}/sratoolkit.env"