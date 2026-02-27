#!/usr/bin/env bash
#
# Launches/updates an ${IMAGE_NAME} instance

IMAGE_NAME="opencode"

# This gets the dir of the project
PROJ_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )


# Get Args
usage() {
  echo "Usage: ${0} [-h] [-r] WORKING_DIR"
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


if [[ "true" == "${REBUILD}" ]]; then
  podman image rm ${IMAGE_NAME}
fi
if ! podman image exists "$IMAGE_NAME"; then
  curl -s http://localhost:11434/api/tags | jq '{
    "$schema": "https://opencode.ai/config.json",
    "provider": {
      "ollama": {
        "npm": "@ai-sdk/openai-compatible",
        "options": { "baseURL": "http://host.containers.internal:11434/v1" },
        "models": ([.models[] | {key: .name, value: {name: .name, tools: true}}] | from_entries)
      }
    }
  }' > "${PROJ_DIR}/opencode/opencode.json"
  podman build -t ${IMAGE_NAME} "${PROJ_DIR}/${IMAGE_NAME}"
fi

podman run -it --rm -v ./:/app ${IMAGE_NAME}

