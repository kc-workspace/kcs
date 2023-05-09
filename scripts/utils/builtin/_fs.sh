#!/usr/bin/env bash
##example-utils:v1

## builtin/fs:
##   File system management
## Hook: <any>
## Public functions:
##   `kcs_create_dir <d>` - create directory if not exist
##   `kcs_create_file <f>` - create file if not exist

## NOTE: All utility files must formatted as `_<name>.sh`.

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Register loaded utilities
kcs_utils_register "builtin/fs"

## create new directory if not exist
## @param $1 - [required] base directory
##        $n - [optional] optional sub directory
## @return   - return non-zero if cannot create
##           - and print absolute filepath (only if input second arguments)
## @example  - kcs_create_dir "/tmp/test"
##           - kcs_create_dir "/tmp/test" "hello"
kcs_create_dir() {
  local dir
  dir="$(
    IFS=/
    echo "$*" | tr -s /
  )"

  if ! test -d "$dir"; then
    mkdir -p "$dir" 2>/dev/null ||
      sudo mkdir -p "$dir" 2>/dev/null ||
      return $?
    [ "$#" -gt 1 ] &&
      printf "%s" "$dir"
    return 0
  fi

  return 1
}

## create new file if not exist
## @param $1 - [required] base directory (or file)
##        $n - [optional] optional file path
## @return   - return non-zero if cannot create
##           - and print absolute filepath (only if input second arguments)
## @example  - kcs_create_file "/tmp/test.txt"
##           - kcs_create_file "/tmp" "test.txt"
kcs_create_file() {
  local file
  file="$(
    IFS=/
    echo "$*" | tr -s /
  )"

  if ! test -f "$file"; then
    kcs_create_dir "$(dirname "$file")"

    touch "$file" 2>/dev/null ||
      sudo touch "$file" 2>/dev/null ||
      return $?
    [ "$#" -gt 1 ] &&
      printf "%s" "$file"
    return 0
  fi

  return 1
}