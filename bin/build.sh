#!/bin/bash
# ==============================================================================
#
# build - Build the app frontend and the desk files required to install it in
#         Grid.
#
# ==============================================================================

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
  echo -e "Usage:\t$SCRIPT_NAME [-h] [-s SHIP_NAME] [-u URL]"
  echo -e ""
  echo -e "Build the app frontend and the desk files required to install it in Grid"
  echo -e ""
  echo -e "Options:"
  echo -e "  -h\tPrint script usage info"
  echo -e "  -s\tSet ship name to use (default: $DEFAULT_SHIP)"
  echo -e "  -u\tUse given URL to distribute glob over HTTP instead of over Ames"
  echo -e ""
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
  echo "  image+'https://static.sigryn-habrex.conormal.com/sigryn-habrex/2021.2.05..12.07.44-ponrep.svg'" >> $DOCKET_FILE
  echo "  base+'chess'" >> $DOCKET_FILE
  echo "  version+[$VERSION_MAJOR $VERSION_MINOR $VERSION_PATCH]" >> $DOCKET_FILE
  echo "  license+'ISC'" >> $DOCKET_FILE
  echo "  website+'https://git.sr.ht/~ray/urbit-chess'" >> $DOCKET_FILE
  
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

SCRIPT_DIR=$(dirname $0)
ROOT_DIR=$(dirname $SCRIPT_DIR)
DESK_DIR="$ROOT_DIR/desk"
FRONTEND_DIR="$ROOT_DIR/frontend"

VERSION_MAJOR=0
VERSION_MINOR=8
VERSION_PATCH=0
VERSION_FULL="$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH"

KELVIN=420

DEFAULT_SHIP=zod
SHIP=$DEFAULT_SHIP

# --------------------------------------
# MAIN
# --------------------------------------

# Stop on error
set -e

# Parse arguments
OPTS=":hs:u:"
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

# Clean up dirs before running
rm -rf $DESK_DIR $FRONTEND_DIR
mkdir $DESK_DIR

# Build desk.bill
echo ":~  %chess  ==" > $DESK_DIR/desk.bill

# Build desk.docket-0
docket

# Build desk.ship
echo "~$SHIP" > $DESK_DIR/desk.ship

# Build sys.kelvin
echo "[%zuse $KELVIN]" > $DESK_DIR/sys.kelvin

# Build frontend
sudo docker build --tag chess-image:$VERSION_FULL .
sudo docker run --name chess-container -v $PWD/frontend/:/app/frontend/ chess-image:$VERSION_FULL
sudo docker container rm chess-container

# Copy additional src files for frontend
sudo chown -R $USER:$USER $FRONTEND_DIR
cp $ROOT_DIR/src/frontend/index.html $FRONTEND_DIR
cp -r $ROOT_DIR/src/frontend/css $FRONTEND_DIR

