#!/bin/bash
# ==============================================================================
#
# install - Install chess app and desk files in an Urbit pier.
#
# ==============================================================================

# Stop on error
set -e

# --------------------------------------
# Variables
# --------------------------------------

SCRIPT_NAME=$(basename $0 | cut -d '.' -f 1)

SCRIPT_DIR=$(dirname $0)
ROOT_DIR=$(dirname $SCRIPT_DIR)
DESK_DIR="$ROOT_DIR/build/desk"

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

INSTALL_DIR="$PIER/$SHIP/$DESK"
./chess-app/bin/install.sh -d $DESK -p $PIER -s $SHIP
cp -rfL ${DESK_DIR}/* ${INSTALL_DIR}/
