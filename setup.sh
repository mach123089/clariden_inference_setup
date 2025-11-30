#!/usr/bin/env bash
set -euo pipefail

readonly REPO_DIR="torrent_clariden_inference"
readonly REPO_LINK="git@github.com:mach123089/torrent_clariden_inference.git"
readonly TORRENT_ENV_FILE="./deployment.toml"
readonly SGLANG_ENV_FILE="./sglang_gb200.toml"
readonly EDF_DIR="$HOME/.edf"
readonly SGLANG_EDF_PATH="$EDF_DIR/sglang_gb200.toml"

# abort if scratch unset
if [ -z "${SCRATCH:-}" ]; then
  echo "SCRATCH is not set." >&2
  exit 1
fi

# Clone fork of torrent repo if missing

if [ ! -d "$REPO_DIR" ]; then
  echo "Cloning repository..."
  git clone "$REPO_LINK"
else
  echo "Repository directory already exists: $REPO_DIR"
fi

HF_HOME="$SCRATCH/huggingface"
mkdir -p "$HF_HOME"
export HF_HOME
echo "HF_HOME set to: $HF_HOME"

# set up default sglang env in .edf
if [ ! -r "$SGLANG_ENV_FILE" ]; then
  echo "ERROR: $SGLANG_ENV_FILE not found." >&2
  exit 1
fi

mkdir -p "$EDF_DIR"

if [ ! -r "$SGLANG_EDF_PATH" ]; then
  echo "COPYING $SGLANG_ENV_FILE to $SGLANG_EDF_PATH"
  cp "$SGLANG_ENV_FILE" "$SGLANG_EDF_PATH"
fi

# make sure env file is present
if [ ! -f "$TORRENT_ENV_FILE" ]; then
  echo "ERROR: $TORRENT_ENV_FILE not found." >&2
  exit 1
fi

# final message
printf "Set up done! To connect to the interactive node, use:\n%s\n" \
"srun -A infra01 -t 2:00:00 --export=HF_HOME=$HF_HOME --environment=$TORRENT_ENV_FILE --pty bash"


