#!/usr/bin/env bash
# shellcheck source=/dev/null

set -e

# region - Script variables and settings

## Current app directory
_KCS_PATH_ADIR="$(cd "$(dirname "$0")/.." && pwd)"

: "${_KCS_PATH_WDIR:=${KCS_PATH_CWD:-$PWD}}"                               ## Current working directory
: "${_KCS_PATH_ROOT:=${KCS_PATH_ROOT:-$_KCS_PATH_ADIR}}"                   ## Application root directory
: "${_KCS_PATH_CORE:=${KCS_PATH_CORE:-$_KCS_PATH_ROOT/src/core}}"          ## Application core directory
: "${_KCS_PATH_PLUGINS:=${KCS_PATH_PLUGINS:-$_KCS_PATH_ROOT/src/plugins}}" ## Application plugins directory

: "${_KCS_CORE_VERSION:=${KCS_CORE_VERSION:-main}}"           ## Application version
: "${_KCS_CORE_DEBUG:=${KCS_CORE_DEBUG:-${DEBUG:-false}}}"    ## Debug mode
: "${_KCS_CORE_SILENT:=${KCS_CORE_SILENT:-${SILENT:-false}}}" ## Silent mode
: "${_KCS_CORE_LOCAL:=${KCS_CORE_LOCAL:-false}}"              ## Local mode (never download from registry)

: "${_KCS_CORE_REGISTRY:=${KCS_CORE_REGISTRY:-github.com/kc-workspace/kcs/raw/$_KCS_CORE_VERSION}}"
__KCS_CORE_REGISTRIES=("$_KCS_CORE_REGISTRY")

# endregion
# ---------------------------------------------------------------------------- #

# region - Script setup functions

_kcs_setup() {
  local directory="$1" filename="$2.sh" debug="$3"
  local filepath="$directory/$filename"
  if ! [ -d "$directory" ]; then
    mkdir -p "$directory"
  fi

  if ! [ -f "$filepath" ] && ! "$_KCS_CORE_LOCAL"; then
    if [ -n "$debug" ]; then
      echo "file is missing ($filepath), download from registries"
    fi

    local registry download_url
    for registry in "${__KCS_CORE_REGISTRIES[@]}"; do
      download_url="https://${registry}/${directory#*"$_KCS_PATH_ROOT"/}/${filename}"
      if [ -n "$debug" ]; then
        echo "downloading from $download_url"
      fi

      local temp
      temp="$(mktemp)" ## Cannot use kcs_exec as setup call every beginning
      if ! curl -sSL -w "%{http_code}" -o "$filepath" "$download_url" >"$temp"; then
        rm "$temp"
        continue
      fi
      local status
      status="$(head -n1 "$temp")"
      rm "$temp"

      if [ "$status" -ne 200 ]; then
        rm "$filepath"
        continue
      fi
    done
  fi

  if ! [ -f "$filepath" ]; then
    echo "Cannot setup input file $filepath" >&2
    exit "${_KCS_ERR_SETUP:-11}"
  fi

  if [ -n "$debug" ]; then
    echo "sourcing '$filepath'"
  fi
  source "$filepath"
}

# endregion
# ---------------------------------------------------------------------------- #

_kcs_setup "$_KCS_PATH_CORE" constants "$_KCS_CORE_DEBUG" #
