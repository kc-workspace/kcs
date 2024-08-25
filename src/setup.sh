#!/usr/bin/env bash
# shellcheck source=/dev/null

# region - Script default variables

KCS_REGISTRIES=("github.com/kc-workspace/kcs")

# endregion
# ---------------------------------------------------------------------------- #

# region - Script configuration

: "${_KCS_ROOT_PATH:=$HOME/.kcs}"
: "${_KCS_CORE_PATH:=$_KCS_ROOT_PATH/src/core}"
: "${_KCS_PLUGIN_PATH:=$_KCS_ROOT_PATH/src/plugins}"
## KCS version to download if missing locally
: "${_KCS_VERSION:=main}"
## If true, never download source code from registries
: "${_KCS_LOCAL:=false}"

## Alias; meaning DEBUG is alias of _KCS_DEBUG
: "${_KCS_DEBUG:=$DEBUG}"

## Create core path
if ! [ -d "$_KCS_CORE_PATH" ]; then
  mkdir -p "$_KCS_CORE_PATH"
fi

# endregion
# ---------------------------------------------------------------------------- #

# region - Script setup functions

## kcs_setup should be use only for loading important file
## for loading other file, use `kcs_core_load`; for loading function, use `kcs_exec`
## usage: kcs_setup $directory $file [debug]
kcs_setup() {
  local directory="$1" filename="$2" debug="$3"
  local filepath="$directory/$filename"
  if ! [ -f "$filepath" ] && ! "$_KCS_LOCAL"; then
    if [ -n "$debug" ]; then
      echo "file is missing ($filepath), download from registries"
    fi

    local registry download_url
    for registry in "${KCS_REGISTRIES[@]}"; do
      download_url="https://${registry}/raw/${_KCS_VERSION}/${directory#*/src/}/${filename}"
      if [ -n "$debug" ]; then
        echo "downloading from $download_url"
      fi

      local temp
      temp="$(mktemp)"
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

## kcs entrypoint
__kcs_start() {
  ## Special variable for getting command argument. This is for internal usage only
  ## For end users, please use callback argument instead ($@)
  __KCS_ARGUMENTS=("$@")

  __kcs_core_parser_parse "\$_KCS_SCRIPT_ARGUMENTS" "${_KCS_SCRIPT_ARGUMENTS[@]}"
}
export KCS_START='__kcs_start'

# endregion
# ---------------------------------------------------------------------------- #

kcs_setup "$_KCS_CORE_PATH" "constants.sh" "$_KCS_DEBUG"
kcs_setup "$_KCS_CORE_PATH" "simple.sh" "$_KCS_DEBUG"
kcs_setup "$_KCS_CORE_PATH" "executor.sh" "$_KCS_DEBUG" # depends on simple.sh
kcs_setup "$_KCS_CORE_PATH" "loader.sh" "$_KCS_DEBUG"   # depends on executor.sh
kcs_setup "$_KCS_CORE_PATH" "parser.sh" "$_KCS_DEBUG"   # depends on executor.sh
kcs_setup "$_KCS_CORE_PATH" "setting.sh" "$_KCS_DEBUG"  # depends on executor.sh
