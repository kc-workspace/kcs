#!/usr/bin/env bash
# shellcheck disable=SC2059

kcs_simple_logger() {
  local action="$1" ns="$2" format="$3"
  shift 3

  case "$action" in
  debug)
    if "$_KCS_CORE_DEBUG"; then
      printf "[D] $ns $format\n" "$@" >&2
    fi
    ;;
  info)
    printf "[I] $ns $format\n" "$@"
    ;;
  warn | error)
    printf "[W] $ns $format\n" "$@" >&2
    ;;
  throw)
    printf "[E] $ns $format\n" "$@" >&2
    exit "$_KCS_ERR_PANIC"
    ;;
  esac
}

kcs_simple_color() {
  printf '%s' "$2"
}

kcs_simple_temp() {
  local type="$1"
  case "$type" in
  f | file) mktemp ;;
  d | dir | directory) mktemp -d ;;
  *) kcs_simple_logger throw "simple.temp" "Invalid temporary type %s" "$type" ;;
  esac
}
