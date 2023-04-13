#!/usr/bin/env bash
## Default commands: v0.1.0
## Special command run if finder cannot map input arguments with any commands

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

####################################################
## User defined function
####################################################

__kcs_main_name() {
  printf "default"
}

__kcs_main_version() {
  printf "v0.1.0"
}

__kcs_main_option_keys() {
  printf "abcd"
}
__kcs_main_option() {
  local flag="$1" value="$2"
  echo "$flag" "$value"
}

__kcs_main_description() {
  printf "description"
}

__kcs_main_help() {
  echo "Commands:"
  echo "  [example] <options...>"
  echo "    - get example command"
  echo "Options:"
  echo "  [--help,-h]"
  echo "    - show help message;"
  echo "    - add after command to get specific command help"
  echo "  [--version,-v]"
  echo "    - show script version;"
  echo "    - add after command to get specific command version"
}

## Main entry of command
## visit README.md for more information
__kcs_main() {
  echo "arguments: $*"
  kcs_clean_temp
}

####################################################
## Internal function calls
####################################################

## original current directory
export _KCS_DIR_ORIG="${_KCS_DIR_ORIG:-$PWD}"

## move to script directory
## later, it will moved to root directory instead
if test -z "$_KCS_DIR_SCRIPT"; then
  cd "$(dirname "$0")/.." || exit 1
  export _KCS_DIR_SCRIPT="$PWD"
fi

# shellcheck disable=SC1091
source "$_KCS_DIR_SCRIPT/internal/command.sh" || exit 1

kcs_prepare
kcs_start "$@"
