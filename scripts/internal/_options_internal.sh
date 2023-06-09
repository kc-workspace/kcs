#!/usr/bin/env bash

## Internal options:
##   an internal function for option parser

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

## Mark option as require argument
kcs_require_argument() {
  local name="$1"
  if [ ${#name} -gt 1 ]; then
    if test -z "$LONG_OPTVAL"; then
      kcs_throw "$KCS_EC_INVALID_OPTS" \
        "options" "%s require argument" "$LONG_OPTARG"
    fi
  fi
}

## Mark option as require no-argument
kcs_no_argument() {
  local name="$1"
  if [ ${#name} -gt 1 ]; then
    test -n "$LONG_OPTVAL" &&
      ! [[ "$LONG_OPTVAL" =~ "-" ]] &&
      kcs_throw "$KCS_EC_INVALID_OPTS" \
        "options" "%s don't needs argument"
    ((OPTIND--))
  fi
}

## @syscall parse long options
__kcs_parse_long_option() {
  if [[ $OPTARG =~ "=" ]]; then
    LONG_OPTVAL="${OPTARG#*=}"
    LONG_OPTARG="${OPTARG%%="$LONG_OPTVAL"}"
  else
    LONG_OPTARG="$OPTARG"
    LONG_OPTVAL="$1"
    ((OPTIND++))
  fi
}
