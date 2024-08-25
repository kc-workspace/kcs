#!/usr/bin/env bash

## execute public apis based on input data
## settings:
##   - OPTIONAL=true - return 0 code when command not exist
##   - IGNORE=true - always return 0 code even command return non-zero code
##   - PANIC=true  - exit program when error occurred
## usage: kcs_exec '<ns>' '<fn>' [args...]
## example: kcs_exec logger info 'hello world' => kcs_core_logger_info "hello world"
kcs_exec() {
  local namespace function
  namespace="$(__kcs_exec_sanitize "${1:?Function namespace is missing}")"
  function="$(__kcs_exec_sanitize "${2:?Function name is missing}")"
  shift 2

  if [ -z "$namespace" ] || [ -z "$function" ]; then
    kcs_simple_logger throw \
      "cannot find function name to execute (%s/%s)" "$namespace" "$function"
  fi

  local options=(
    "<OPTIONAL=${OPTIONAL:-false}>"
    "<IGNORE=${IGNORE:-false}>"
    "<PANIC=${PANIC:-false}>"
  )

  local callbacks=(
    "kcs_${namespace}_${function}"
    "kcs_${namespace}/${function}"
    "kcs_simple_${namespace}_${function}"
    "kcs_simple_${namespace}/${function}"
  )

  local raw callback args=() code
  for raw in "${callbacks[@]}"; do
    callback="${raw%%/*}"

    if [[ $callback == "${raw#*/}" ]]; then
      args=("$@")
    else
      args=("${raw#*/}" "$@")
    fi

    ## Too many output
    # kcs_simple_logger debug "checking command %s" "$callback"
    if command -v "$callback" >/dev/null; then
      kcs_simple_logger debug "executing command %s [%s] (%d)" "$callback" "${args[*]}" "${#args[@]}"
      code=0
      "$callback" "${args[@]}"
      code=$?
      kcs_simple_logger debug "command '%s' exit code is %d" "$callback" "$code"

      if [[ ${options[*]} =~ '<PANIC=true>' ]] && [ $code -gt 0 ]; then
        kcs_simple_logger throw \
          "Error %s: command failed (%d)" "$callback" "$code"
      fi

      if [[ ${options[*]} =~ '<IGNORE=true>' ]]; then
        return 0
      fi

      return $code
    fi
  done

  if [[ ${options[*]} =~ '<OPTIONAL=true>' ]] || [[ ${options[*]} =~ '<IGNORE=true>' ]]; then
    return 0
  elif [[ ${options[*]} =~ '<PANIC=true>' ]]; then
    kcs_simple_logger throw \
      "Error: command not found (%s)" "${callbacks[*]}"
  fi

  kcs_simple_logger warn \
    "Warn: command not found (%s)" "${callbacks[*]}"
  return "$KCS_ERR_CMD_NOT_FOUND"
}

kcs_exec_callback() {
  local namespace function
  namespace="$(__kcs_exec_sanitize "${1:?Callback namespace is missing}")"
  function="$(__kcs_exec_sanitize "${2:?Callback name is missing}")"
  shift 2

  if [ -z "$namespace" ] || [ -z "$function" ]; then
    kcs_exec logger throw \
      "cannot find callback name to execute (%s/%s)" "$namespace" "$function"
  fi

  local callback="_kcs_${namespace}_${function}"
  if ! command -v "$callback" >/dev/null; then
    kcs_exec logger throw \
      "Error: callback function is missing (%s)" "$callback"
  fi

  kcs_exec logger debug \
    "execute callback %s with [%s] (%d)" "$callback" "$*" "$#"
  "$callback" "$@"
}

__kcs_core_exec() {
  kcs_exec_callback "$1" "$(kcs_core_setting_get "NAME")" "${__KCS_ARGUMENTS[@]}"
}

__kcs_exec_sanitize() {
  local input="$1"
  input="${input//[. -]/_}"
  printf '%s' "$input"
}
