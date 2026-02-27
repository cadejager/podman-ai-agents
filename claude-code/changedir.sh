#!/usr/bin/env sh

export ANTHROPIC_AUTH_TOKEN=ollama
export ANTHROPIC_API_KEY=""
export ANTHROPIC_BASE_URL=http://host.containers.internal:11434

cd $1
$2 --model $3
