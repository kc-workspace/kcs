#!/usr/bin/env bash
## Commands utilities for main entry

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

export __KCS_COMMAND_SEPARATOR="__"
export __KCS_COMMAND_DEFAULT_NAME="_default.sh"

_kcs_find_command() {
  local ns="command finder"
  local index="$#" args=("$@") _args=()

  local base_path="$_KCS_DIR_COMMANDS"
  local file_name="${args[*]}"
  file_name="${file_name// /$__KCS_COMMAND_SEPARATOR}.sh"
  local file_path="$base_path/$file_name"

  while true; do
    if [ $index -le 0 ]; then
      break
    fi

    _args=("${args[@]:$index}")

    kcs_debug "$ns" "index %d | testing file %s with '%s'" \
      "$index" "$file_name" "${_args[*]}"

    if test -f "$file_path"; then
      kcs_must_load "$base_path" "$file_name" "${_args[@]}"
      return $?
    fi

    file_name="${file_name%"$__KCS_COMMAND_SEPARATOR"*}.sh"
    file_path="$base_path/$file_name"

    ((index--))
  done

  kcs_debug "$ns" "loading default command with '%s'" \
    "${args[*]}"

  kcs_must_load \
    "$base_path" "$__KCS_COMMAND_DEFAULT_NAME" "${args[@]}"
}
