#!/usr/bin/env bash
#
# Launches/updates a claude code instance

IMAGE_NAME="claude-code"
MODEL="gpt-oss-64k:20b"

# This gets the dir of the project
PROJ_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )


# Get Args
usage() {
  echo "Usage: ${0} [-m MODEL] [-h] [-r]"
  echo "  -m       The model to use"
  echo "  -r       Rebuild"
  echo "  -h       Display this message"
  exit 1
}
while getopts "m:rh" opt; do
  case ${opt} in
    m) MODEL=$OPTARG ;;
    r) REBUILD=true ;;
    h|?) usage ;;
  esac
done


if [[ "true" == "${REBUILD}" ]]; then
  podman image rm ${IMAGE_NAME}
fi
if ! podman image exists "$IMAGE_NAME"; then
    podman build -t ${IMAGE_NAME} "${PROJ_DIR}/${IMAGE_NAME}"
fi

podman run -it --rm -v ./:/app ${IMAGE_NAME} /root/.local/bin/claude --model "${MODEL}"

