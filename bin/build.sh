#!/bin/bash
# ==============================================================================
#
# build - Build the chess app, its frontend, and the desk files required to
#         install it in Landscape.
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
  echo -e "Usage:\t$SCRIPT_NAME [-h] [-k KELVIN] [-s SHIP_NAME] [-u URL] [-- <chess-ui options>]"
  echo -e ""
  echo -e "Build the app frontend and the desk files required to install %chess in Landscape"
  echo -e ""
  echo -e "Options:"
  echo -e "  -h\tPrint script usage info"
  echo -e "  -k\tSet alternative kelvin version to use (default: $DEFAULT_KELVIN)"
  echo -e "  -s\tSet ship name to use (default: $DEFAULT_SHIP)"
  echo -e "  -u\tUse given URL to distribute glob over HTTP instead of over Ames"
  echo -e ""
  ./chess-ui/bin/build.sh -h
  exit $1
}

#
# Build docket file
#
docket() {
  DOCKET_FILE=$DESK_DIR/desk.docket-0

  echo ":~" > $DOCKET_FILE
  echo "  title+'Chess'" >> $DOCKET_FILE
  echo "  info+'Fully peer-to-peer chess over Urbit'" >> $DOCKET_FILE
  echo "  color+0xff.ffff" >> $DOCKET_FILE
  echo "  image+'https://peekabooo.icu/images/finmep-chess.svg'" >> $DOCKET_FILE
  echo "  base+'chess'" >> $DOCKET_FILE
  echo "  version+[$VERSION_MAJOR $VERSION_MINOR $VERSION_PATCH]" >> $DOCKET_FILE
  echo "  license+'GPL3'" >> $DOCKET_FILE
  echo "  website+'https://github.com/thecommons-urbit/chess'" >> $DOCKET_FILE
  
  if [[ -z $URL ]]; then
    echo "  glob-ames+[~$SHIP 0v0]" >> $DOCKET_FILE
  else
    GLOB=$(echo ${URL} | grep -Eo '0v[0-9a-v]{1,5}(\.[0-9a-v]{5})+')
    echo "  glob-http+['$URL' $GLOB]" >> $DOCKET_FILE
  fi
  
  echo "==" >> $DOCKET_FILE
}

# --------------------------------------
# Variables
# --------------------------------------

SCRIPT_NAME=$(basename $0 | cut -d '.' -f 1)
SCRIPT_PATH=$(realpath $0)
SCRIPT_DIR=$(dirname $SCRIPT_PATH)

ROOT_DIR=$(dirname $SCRIPT_DIR)
BUILD_DIR="$ROOT_DIR/build"
DESK_DIR="$BUILD_DIR/desk"
FRONTEND_DIR="$BUILD_DIR/frontend"

DOCKER=1
DOCKER_IMAGE="urbit-chess"
LINT_FIX=0

VERSION_MAJOR=0
VERSION_MINOR=9
VERSION_PATCH=6
VERSION_FULL="$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH"

DEFAULT_KELVIN=411
DEFAULT_SHIP="finmep-lanteb"

KELVIN=$DEFAULT_KELVIN
SHIP=$DEFAULT_SHIP

# --------------------------------------
# MAIN
# --------------------------------------

# Parse arguments
OPTS=":hk:s:u:"
while getopts ${OPTS} opt; do
  case ${opt} in
    h)
      usage 0
      ;;
    s)
      SHIP=$OPTARG
      ;;
    u)
      URL=$OPTARG
      ;;
    k)
      KELVIN=$OPTARG
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

# All remaining arguments (if any) are for chess-ui
if [ "$1" = "--" ]; then
  shift
fi

# Clean up dirs before running
rm -rf $BUILD_DIR
mkdir -p $DESK_DIR
mkdir -p $FRONTEND_DIR

# Build desk.bill
echo ":~  %chess  ==" > $DESK_DIR/desk.bill

# Build desk.docket-0
docket

# Build desk.ship
echo "~$SHIP" > $DESK_DIR/desk.ship

# Build sys.kelvin
echo "[%zuse $KELVIN]" > $DESK_DIR/sys.kelvin

# Build frontend
./chess-ui/bin/build.sh $@ -v $VERSION_FULL
cp -rfL chess-ui/build/* ${FRONTEND_DIR}
