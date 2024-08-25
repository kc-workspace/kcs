#!/usr/bin/env bash

kcs_simple_logger() {
  local action="$1" format="$2"
  shift 2

  case "$action" in
  debug)
    if [ -n "$_KCS_DEBUG" ]; then
      # shellcheck disable=SC2059
      printf "[DBG] $format\n" "$@" >&2
    fi
    ;;
  info)
    # shellcheck disable=SC2059
    printf "$format\n" "$@"
    ;;
  warn | error)
    # shellcheck disable=SC2059
    printf "$format\n" "$@" >&2
    ;;
  throw)
    # shellcheck disable=SC2059
    printf "$format\n" "$@" >&2
    exit "$KCS_ERR_PANIC"
    ;;
  esac
}
