#!/bin/bash
# ==============================================================================
#
# install - Install app files in Urbit pier.
#
# ==============================================================================

# Stop on error
set -e

# --------------------------------------
# Functions
# --------------------------------------

#
# Print script usage
#
usage() {
  if [[ $1 -ne 0 ]]; then
    exec 1>&2
  fi

  echo -e ""
  echo -e "Usage:\t$SCRIPT_NAME [-h] [-d DESK_NAME] [-p PATH_TO_PIER] [-s SHIP_NAME]"
  echo -e ""
  echo -e "Install app files to a desk in an Urbit pier"
  echo -e "Default install location: $DEFAULT_PIER/$DEFAULT_SHIP/$DEFAULT_DESK"
  echo -e ""
  echo -e "Options:"
  echo -e "  -h\tPrint script usage info"
  echo -e "  -d\tName of desk to which to install (default: $DEFAULT_DESK)"
  echo -e "  -p\tPath to root pier directory (default: $DEFAULT_PIER)"
  echo -e "  -s\tName of ship to install to (default: $DEFAULT_SHIP)"
  echo -e ""
  exit $1
}

# --------------------------------------
# Variables
# --------------------------------------

SCRIPT_NAME=$(basename $0 | cut -d '.' -f 1)

SCRIPT_DIR=$(dirname $0)
ROOT_DIR=$(dirname $SCRIPT_DIR)
DESK_DIR="$ROOT_DIR/build/desk"
CHESS_DIR="$ROOT_DIR/src/backend/chess"
DEPS_DIR="$ROOT_DIR/src/backend/dependencies"

DEFAULT_DESK="chess"
DEFAULT_PIER="/home/$USER/Urbit/piers"
DEFAULT_SHIP="finmep-lanteb"
DESK=$DEFAULT_DESK
PIER=$DEFAULT_PIER
SHIP=$DEFAULT_SHIP

# --------------------------------------
# MAIN
# --------------------------------------

# Parse arguments
OPTS=":hd:p:s:"
while getopts ${OPTS} opt; do
  case ${opt} in
    h)
      usage 0
      ;;
    d)
      DESK=$OPTARG
      ;;
    p)
      PIER=$OPTARG
      ;;
    s)
      SHIP=$OPTARG
      ;;
    :)
      echo "$SCRIPT_NAME: Missing argument for '-${OPTARG}'" >&2
      usage 2
      ;;
    ?)
      echo "$SCRIPT_NAME: Invalid option '-${OPTARG}'" >&2
      usage 2
      ;;
  esac
done

# Copy files
INSTALL_DIR="$PIER/$SHIP/$DESK"
echo "Attempting to install to path '$INSTALL_DIR'"

cp ${DESK_DIR}/* ${INSTALL_DIR}/
cp -rfL ${CHESS_DIR}/* ${INSTALL_DIR}/
cp -rfL ${DEPS_DIR}/* ${INSTALL_DIR}/

echo "Successfully installed to path '$INSTALL_DIR'"
