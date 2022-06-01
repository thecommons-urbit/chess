#!/bin/bash
# ==============================================================================
#
# install - Install app files in Urbit pier.
#
# ==============================================================================

# --------------------------------------
# Functions
# --------------------------------------

#
# Print script usage
#
usage() { printf "Usage:\t$(basename $0 | cut -d '.' -f 1)\n\nInstall app files in Urbit pier\n" 1>&2; exit 2; }

# --------------------------------------
# MAIN
# --------------------------------------

# Stop on error
set -e

# Take no arguments
if [[ $# -gt 0 ]]; then
  usage
fi

# Set env var for Urbit pier directory, if not set
if [[ -z $URBIT_PIER ]]; then
  echo "Env variable '\$URBIT_PIER' not set; set variable now:"
  echo "(e.g. /home/user/Urbit/piers/zod)"
  read URBIT_PIER
fi

# Copy files
cp desk/* ${URBIT_PIER}/chess/
cp -r src/urbit/* ${URBIT_PIER}/chess/
