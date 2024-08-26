#!/usr/bin/env bash
# shellcheck source=/dev/null

# region - Script variables and settings

: "${_KCS_CURR_PATH:=$(cd "$(dirname "$0")" && pwd)}"
: "${_KCS_ROOT_PATH:=$HOME/.kcs}"
: "${_KCS_CORE_PATH:=$_KCS_ROOT_PATH/src/core}"
: "${_KCS_PLUGIN_PATH:=$_KCS_ROOT_PATH/src/plugins}"
## KCS version to download if missing locally
: "${_KCS_VERSION:=main}"
## If true, never download source code from registries
: "${_KCS_LOCAL:=false}"
## IF true, all detail on log message
: "${_KCS_LOG_DETAIL:=false}"

## Alias:
: "${_KCS_TEST:=$TEST}"
: "${_KCS_DEBUG:=$DEBUG}"
: "${_KCS_SILENT:=$SILENT}"
: "${_KCS_LOG_LEVEL:=$LOG_LEVEL}"
## LOG_NS=<ns1>,<ns2>...
: "${_KCS_LOG_NS:=$LOG_NS}"

## Create core path
if ! [ -d "$_KCS_CORE_PATH" ]; then
  mkdir -p "$_KCS_CORE_PATH"
fi

__KCS_REGISTRIES=("github.com/kc-workspace/kcs/raw/$_KCS_VERSION")

# endregion
# ---------------------------------------------------------------------------- #

# region - Script setup functions

_kcs_setup() {
  local directory="$1" filename="$2.sh" debug="$3"
  local filepath="$directory/$filename"
  if ! [ -f "$filepath" ] && ! "$_KCS_LOCAL"; then
    if [ -n "$debug" ]; then
      echo "file is missing ($filepath), download from registries"
    fi

    local registry download_url
    for registry in "${__KCS_REGISTRIES[@]}"; do
      download_url="https://${registry}/${directory#*/src/}/${filename}"
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

      if [ "$status" -ge 400 ]; then
        rm "$filepath"
        continue
      fi
    done
  fi

  if ! [ -f "$filepath" ]; then
    echo "Cannot setup input file $filepath" >&2
    exit "${KCS_ERR_SETUP:-11}"
  fi

  if [ -n "$debug" ]; then
    echo "sourcing '$filepath'"
  fi
  source "$filepath"
}

# endregion
# ---------------------------------------------------------------------------- #

_kcs_setup "$_KCS_CORE_PATH" constants "$_KCS_DEBUG" #
_kcs_setup "$_KCS_CORE_PATH" simples "$_KCS_DEBUG"   # depends on [constants]
_kcs_setup "$_KCS_CORE_PATH" executors "$_KCS_DEBUG" # depends on [constants, simples]
_kcs_setup "$_KCS_CORE_PATH" configs "$_KCS_DEBUG"   # depends on [simples]
_kcs_setup "$_KCS_CORE_PATH" events "$_KCS_DEBUG"    # depends on [constants, executors, configs]
_kcs_setup "$_KCS_CORE_PATH" parsers "$_KCS_DEBUG"   # depends on [constants, executors, events]
_kcs_setup "$_KCS_CORE_PATH" tags "$_KCS_DEBUG"      # depends on [executors, configs, event, parsers]
_kcs_setup "$_KCS_CORE_PATH" loaders "$_KCS_DEBUG"   # depends on [constants, configs, events]
_kcs_setup "$_KCS_CORE_PATH" main "$_KCS_DEBUG"      # depends on [constants, executors, events]
