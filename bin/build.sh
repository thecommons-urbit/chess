#!/bin/bash
# ==============================================================================
#
# build - Build the app frontend and the desk files required to install it in
#         Grid.
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
  echo -e "Usage:\t$SCRIPT_NAME [-h] [-k KELVIN] [-n] [-s SHIP_NAME] [-u URL]"
  echo -e ""
  echo -e "Build the app frontend and the desk files required to install it in Grid"
  echo -e ""
  echo -e "Options:"
  echo -e "  -h\tPrint script usage info"
  echo -e "  -k\tSet alternative kelvin version to use (default: $DEFAULT_KELVIN)"
  echo -e "  -n\tUse npm natively instead of through Docker"
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
  echo "  color+0xea.e4d5" >> $DOCKET_FILE
  echo "  image+'https://raw.githubusercontent.com/thecommons-urbit/chess/develop/images/tile.svg'" >> $DOCKET_FILE
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

VERSION_MAJOR=0
VERSION_MINOR=9
VERSION_PATCH=4
VERSION_FULL="$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH"

DEFAULT_KELVIN=413
DEFAULT_SHIP="finmep-lanteb"

KELVIN=$DEFAULT_KELVIN
SHIP=$DEFAULT_SHIP

# --------------------------------------
# MAIN
# --------------------------------------

# Parse arguments
OPTS=":hns:u:k:"
while getopts ${OPTS} opt; do
  case ${opt} in
    h)
      usage 0
      ;;
    n)
      DOCKER=0
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

# Clean up dirs before running
rm -rf $BUILD_DIR
mkdir -p $DESK_DIR

# Build desk.bill
echo ":~  %chess  ==" > $DESK_DIR/desk.bill

# Build desk.docket-0
docket

# Build desk.ship
echo "~$SHIP" > $DESK_DIR/desk.ship

# Build sys.kelvin
echo "[%zuse $KELVIN]" > $DESK_DIR/sys.kelvin

# Build frontend
if [ $DOCKER -eq 1 ]; then
  # Need to use legacy builder ( DOCKER_BUILDKIT=0) so that MacOS builds work until this issue is resolved:
  #   https://github.com/moby/buildkit/issues/1271
  # sudo docker build --tag ${DOCKER_IMAGE}:${VERSION_FULL} .
  sudo DOCKER_BUILDKIT=0 docker build --tag ${DOCKER_IMAGE}:${VERSION_FULL} .
  sudo docker run --rm -v ${FRONTEND_DIR}:/app/output/ ${DOCKER_IMAGE}:${VERSION_FULL}

  # Copy additional src files for frontend
  sudo chown -R ${USER}:${USER} ${FRONTEND_DIR}
else
  (cd "$ROOT_DIR/src/frontend"; npm run build-no-docker)
fi
