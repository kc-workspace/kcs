#!/usr/bin/env bash
# shellcheck disable=SC2059

export __KCS_LOG_PRINT="PRT"
export __KCS_LOG_DEBUG="DBG"
export __KCS_LOG_INFO="INF"
export __KCS_LOG_WARN="WRN"
export __KCS_LOG_ERROR="ERR"

export __KCS_LOG_NS_ENABLED=''
export __KCS_LOG_DEBUG_ENABLED=false
export __KCS_LOG_INFO_ENABLED=true
export __KCS_LOG_WARN_ENABLED=true
export __KCS_LOG_ERROR_ENABLED=true
export __KCS_LOG_PRINT_ENABLED=true

## Printf debug message with log format
## usage: kcs_logger_debug 'hello %s' world
kcs_logger_debug() {
  _kcs_logger "$__KCS_LOG_DEBUG" "$@"
}

## Printf info message with log format
## usage: kcs_logger_info 'hello %s' world
kcs_logger_info() {
  _kcs_logger "$__KCS_LOG_INFO" "$@"
}

## Printf warning message with log format
## usage: kcs_logger_warn 'hello %s' world
kcs_logger_warn() {
  _kcs_logger "$__KCS_LOG_WARN" "$@"
}

## Printf error message with log format
## usage: kcs_logger_error 'hello %s' world
kcs_logger_error() {
  _kcs_logger "$__KCS_LOG_ERROR" "$@"
}

## Printf normal message with log format
## usage: kcs_logger_printf 'hello %s' world
kcs_logger_printf() {
  _kcs_logger "$__KCS_LOG_PRINT" "$@"
}

_kcs_logger() {
  local lvl="$1" ns="$2" format="$3"
  shift 3

  if ! _kcs_logger_lvl_enabled "$lvl"; then
    return 0
  fi
  if ! _kcs_logger_ns_enabled "$ns"; then
    return 0
  fi

  local template="{t} [{clvl}] {cns} : {msg}"
  local variables=(
    "lvl=$lvl"
    "clvl=$(_kcs_logger_lvl_color "$lvl")"
    "ns=$ns"
    "cns=$(kcs_exec color print "$ns" PINK)"
    "msg=$(printf "$format" "$@")"
    "fmt=$format"
    "args=${args[*]}"
  )
  if test -n "$KCT_ENABLED"; then
    variables+=(
      "dt=2000/12/31 00:10:45"
      "d=2000/12/31"
      "t=00:10:45"
    )
  else
    variables+=(
      "dt=$(date +"%Y/%m/%d %H:%M:%S")"
      "d=$(date +"%Y/%m/%d")"
      "t=$(date +"%H:%M:%S")"
    )
  fi

  local output
  output="$(kcs_template_parse "${KCS_LOGFMT:-$template}" "${variables[@]}")"
  output="$(_kcs_logger_normalize "$output")"

  case "$lvl" in
  "$__KCS_LOG_DEBUG") echo "$output" >&2 ;;
  "$__KCS_LOG_INFO") echo "$output" ;;
  "$__KCS_LOG_WARN") echo "$output" >&2 ;;
  "$__KCS_LOG_ERROR") echo "$output" >&2 ;;
  esac
}

_kcs_logger_normalize() {
  if "$_KCS_LOG_DETAIL"; then
    printf '%s' "$1"
    return 0
  fi

  local input="$1"
  input="${input//$_KCS_PATH_WDIR/\$PWD}"
  input="${input//$_KCS_PATH_CORE/\$KCS_PATH_CORE}"
  input="${input//$_KCS_PATH_PLUGINS/\$KCS_PATH_PLUGINS}"
  input="${input//$_KCS_PATH_ROOT/\$KCS_PATH_ROOT}"
  input="${input//$HOME/\$HOME}"

  printf '%s' "$input"
}

_kcs_logger_ns_enabled() {
  [ -z "$_KCS_LOG_NS" ] || [[ "$_KCS_LOG_NS" =~ $1 ]]
}
_kcs_logger_lvl_enabled() {
  if ! $__KCS_LOG_PRINT_ENABLED; then
    return 1
  fi

  case "$1" in
  "$__KCS_LOG_DEBUG") $__KCS_LOG_DEBUG_ENABLED ;;
  "$__KCS_LOG_INFO") $__KCS_LOG_INFO_ENABLED ;;
  "$__KCS_LOG_WARN") $__KCS_LOG_WARN_ENABLED ;;
  "$__KCS_LOG_ERROR") $__KCS_LOG_ERROR_ENABLED ;;
  esac
}

_kcs_logger_lvl_color() {
  case "$1" in
  "$__KCS_LOG_DEBUG") kcs_exec color print "$1" BLACK ;;
  "$__KCS_LOG_INFO") kcs_exec color print "$1" CYAN ;;
  "$__KCS_LOG_WARN") kcs_exec color print "$1" YELLOW ;;
  "$__KCS_LOG_ERROR") kcs_exec color print "$1" RED ;;
  *) kcs_exec color print "$1" DEFAULT ;;
  esac
}

_kcs_logger_is_debug() {
  [[ "$1" == "debug" ]] ||
    [[ "$1" == "DEBUG" ]] ||
    [[ "$1" == "dbg" ]] ||
    [[ "$1" == "DBG" ]] ||
    [[ "$1" == "d" ]] ||
    [[ "$1" == "D" ]]
}
_kcs_logger_is_info() {
  [[ "$1" == "info" ]] ||
    [[ "$1" == "INFO" ]] ||
    [[ "$1" == "inf" ]] ||
    [[ "$1" == "INF" ]] ||
    [[ "$1" == "i" ]] ||
    [[ "$1" == "I" ]]
}
_kcs_logger_is_warn() {
  [[ "$1" == "warn" ]] ||
    [[ "$1" == "WARN" ]] ||
    [[ "$1" == "wrn" ]] ||
    [[ "$1" == "WRN" ]] ||
    [[ "$1" == "w" ]] ||
    [[ "$1" == "W" ]]
}
_kcs_logger_is_error() {
  [[ "$1" == "error" ]] ||
    [[ "$1" == "ERROR" ]] ||
    [[ "$1" == "err" ]] ||
    [[ "$1" == "ERR" ]] ||
    [[ "$1" == "e" ]] ||
    [[ "$1" == "E" ]]
}
_kcs_logger_is_silent() {
  [[ "$1" == "silent" ]] ||
    [[ "$1" == "SILENT" ]] ||
    [[ "$1" == "slt" ]] ||
    [[ "$1" == "SLT" ]] ||
    [[ "$1" == "s" ]] ||
    [[ "$1" == "S" ]]
}

__kcs_loggers_on_init() {
  kcs_load_plugin templates
  if _kcs_logger_is_debug "$_KCS_LOG_LEVEL"; then
    __KCS_LOG_DEBUG_ENABLED=true
  fi
  if _kcs_logger_is_info "$_KCS_LOG_LEVEL"; then
    __KCS_LOG_INFO_ENABLED=true
  fi
  if _kcs_logger_is_warn "$_KCS_LOG_LEVEL"; then
    __KCS_LOG_WARN_ENABLED=true
  fi
  if _kcs_logger_is_error "$_KCS_LOG_LEVEL"; then
    __KCS_LOG_ERROR_ENABLED=true
  fi
  if _kcs_logger_is_silent "$_KCS_LOG_LEVEL"; then
    __KCS_LOG_PRINT_ENABLED=false
  fi

  if "$_KCS_CORE_DEBUG"; then
    __KCS_LOG_DEBUG_ENABLED=true
    __KCS_LOG_INFO_ENABLED=true
    __KCS_LOG_WARN_ENABLED=true
    __KCS_LOG_ERROR_ENABLED=true
    __KCS_LOG_PRINT_ENABLED=true
  elif [ -n "$_KCS_CORE_SILENT" ]; then
    __KCS_LOG_PRINT_ENABLED=false
  fi
}
