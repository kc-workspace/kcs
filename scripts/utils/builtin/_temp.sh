#!/usr/bin/env bash
##utils-example:v1.0.0-beta.1

## builtin/temp:
##   manage temp directory
## Requirement:
##   <none>
## Public functions:
##   `kcs_clean_temp` - clean temp directory to initiate state

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## create temp directory
## @param $1 - [optional] name (default random by date)
## @return   - single line fullpath string
kcs_temp_create() {
  local name="$1"
  test -z "$name" && name="_TMP$(date +"%Y%m%d%H%M%S")"

  local fullpath="$_KCS_DIR_TEMP/$name"
  ## create temporary directory
  mkdir -p "$fullpath"
  printf "%s" "$fullpath"
}

kcs_clean_temp() {
  local ns="temp-cleaner"

  if test -d "$_KCS_DIR_TEMP"; then
    rm -r "$_KCS_DIR_TEMP"
  fi

  mkdir -p "$_KCS_DIR_TEMP"
  touch "$_KCS_DIR_TEMP/.gitkeep"

  kcs_debug "$ns" "%s (temp dir) now cleaned" \
    "$_KCS_DIR_TEMP"
}
