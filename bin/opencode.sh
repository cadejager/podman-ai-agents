#!/usr/bin/env bash
#
# Launches/updates an ${IMAGE_NAME} instance

IMAGE_NAME="opencode"


# This gets the dir of the project
PROJ_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )


# Get Args
usage() {
  echo "Usage: ${0} [-h] [-r] WORKING_DIR"
  echo "  CODE_DIR [REQUIRED] The working dir for ${IMAGE_NAME}"
  echo
  echo "  -r       Rebuild"
  echo "  -h       Display this message"
  exit 1
}
while getopts "rh" opt; do
  case ${opt} in
    r) REBUILD=true ;;
    h|?) usage ;;
  esac
done
shift $((OPTIND-1)) # Shift away the options processed by getopts
if [[ -z "${1}" ]]; then
  echo "Error: Missing workding dir."
  usage
fi
WORKING_DIR="${1}"


if [[ "true" == "${REBUILD}" ]]; then
  podman image rm ${IMAGE_NAME}
fi

if ! podman image exists "$IMAGE_NAME"; then
    podman build -t ${IMAGE_NAME} "${PROJ_DIR}/${IMAGE_NAME}"
fi

podman run -it --rm -v "$(realpath "${WORKING_DIR}"):/app" ${IMAGE_NAME}

