#!/usr/bin/env bash

__KCS_EXEC_NAME_BLACKLIST="[ -.\/\\\]"

## exec public apis (error when command not found and command fail)
## usage: kcs_exec '<namespace>' '<function>'
kcs_exec() {
  local namespace="$1" name="$2"
  shift 2
  _kcs_exec "$namespace" "$name" --public -- "$@"
}

## execute callback function (error only when command fail)
## usage: kcs_exec_cb '<namespace>' '<function>'
kcs_exec_cb() {
  local namespace="$1" name="$2"
  shift 2
  _kcs_exec "$namespace" "$name" --callback --optional -- "$@"
}

## execute input command based on setting options
## usage: _kcs_exec <ns> <name> [--callback|--public|--private] [--optional] [--ignore] [--panic] -- [args...]
##        _kcs_exec logger info             => [kcs_logger_info, kcs_logger, _kcs_logger_info, _kcs_logger]
##        _kcs_exec logger info --callback  => [__kcs_logger_info]
##        _kcs_exec logger info --public    => [kcs_logger_info, kcs_logger]
##        _kcs_exec logger info --private   => [_kcs_logger_info, _kcs_logger]
##        _kcs_exec logger info --optional  => return 0 if command is missing
##        _kcs_exec logger info --ignore    => always return 0 (even command missing or failed)
##        _kcs_exec logger info --panic     => panic exit if command is missing or failed
_kcs_exec() {
  local ns="core.exec"
  local namespace="${1//$__KCS_EXEC_NAME_BLACKLIST/_}"
  local name="${2//$__KCS_EXEC_NAME_BLACKLIST/_}"
  shift 2

  : "${namespace:?Function namespace is required}"
  : "${name:?Function name is required}"

  local callbacks=()
  local optional=false ignore=false panic=false
  while true; do
    if [[ $# -eq 0 ]]; then
      break
    fi
    if [[ "$1" == -- ]]; then
      shift 1
      break
    fi

    case "$1" in
    --callback) callbacks+=(
      "__kcs_${namespace}_${name}"
    ) ;;
    --public) callbacks+=(
      "kcs_${namespace}_${name}"
      "kcs_${namespace}/${name}"
      "kcs_simple_${namespace}_${name}"
      "kcs_simple_${namespace}/${name}"
    ) ;;
    --private) callbacks+=(
      "_kcs_${namespace}_${name}"
      "_kcs_${namespace}/${name}"
      "_kcs_simple_${namespace}_${name}"
      "_kcs_simple_${namespace}/${name}"
    ) ;;
    --optional) optional=true ;;
    --ignore) ignore=true ;;
    --panic) panic=true ;;
    *) break ;;
    esac
    shift 1
  done

  if [ "${#callbacks[@]}" -lt 1 ]; then
    kcs_simple_logger debug "$ns" 'no access modifier, try all'
    callbacks=(
      "kcs_${namespace}_${name}"
      "kcs_${namespace}/${name}"
      "_kcs_${namespace}_${name}"
      "_kcs_${namespace}/${name}"
      "kcs_simple_${namespace}_${name}"
      "kcs_simple_${namespace}/${name}"
      "_kcs_simple_${namespace}_${name}"
      "_kcs_simple_${namespace}/${name}"
    )
  fi

  local raw callback args=() code
  for raw in "${callbacks[@]}"; do
    callback="${raw%%/*}"

    if [[ "$callback" == "${raw#*/}" ]]; then
      args=("$@")
    else
      args=("${raw#*/}" "$@")
    fi

    ## Too many output
    # kcs_simple_logger debug "$ns" "checking '%s' => '%s'" "$raw" "$callback"
    if command -v "$callback" >/dev/null; then
      ## Too many output
      # kcs_simple_logger debug "$ns" "executing '%s' #%d [%s]" "$callback" "${#args[@]}" "${args[*]}"

      code=0
      "$callback" "${args[@]}"
      code=$?

      ## Only print debug message when it not logger namespace
      if [[ $namespace != logger ]]; then
        kcs_simple_logger debug "$ns" \
          "executed '%s' #%d [%s] return code: %d" "$callback" "${#args[@]}" "${args[*]}" "$code"
      fi
      if $panic && [ $code -gt 0 ]; then
        kcs_simple_logger throw "$ns" "Error %s: command failed (%d)" "$callback" "$code"
      fi
      if $ignore; then
        kcs_simple_logger debug "$ns" "ignored failing command: %s (code=%d)" "$callback" "$code"
        return 0
      fi

      return $code
    fi
  done

  ## If command not found
  if $optional || $ignore; then
    kcs_simple_logger debug "$ns" "ignored missing command: [%s]" "${callbacks[*]}"
    return 0
  elif $panic; then
    kcs_simple_logger throw "$ns" "Error: command not found [%s]" "${callbacks[*]}"
  fi

  kcs_simple_logger warn "$ns" "Warn: command not found [%s]" "${callbacks[*]}"
  return "$KCS_ERR_CMD_NOT_FOUND"
}
