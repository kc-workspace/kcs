#!/usr/bin/env bash

__KCS_PARSER_MAPPING=(
  load=core.load
  exec=core.exec
  setting=core.setting.set
  main=core.main.run
)

## parse input arguments and call function by tags
## usage: __kcs_core_parser_parse '$ARGS' @a b c @d
__kcs_core_parser_parse() {
  local name="$1"
  shift

  if [ "$#" -lt 1 ]; then
    kcs_exec logger throw \
      "argument '%s' contains empty action" "$name"
  fi

  local element tag args=() code=0
  for element in "$@"; do
    if [[ "$element" =~ ^@ ]]; then
      if [ -n "$tag" ]; then
        __kcs_core_parser_exec "$tag" "${args[@]}"
        code=$?
        if [ $code -gt 0 ]; then
          return $code
        fi
      fi

      tag="${element:1}"
      args=()
    else
      args+=("$element")
    fi
  done

  if [ -n "$tag" ]; then
    __kcs_core_parser_exec "$tag" "${args[@]}"
    code=$?
    if [ $code -gt 0 ]; then
      return $code
    fi
  fi
}

## call tag function with input arguments
## usage: __kcs_core_parser_exec load a b c     => __kcs_core_load a b c
## usage: __kcs_core_parser_exec option.load a  => __kcs_option_load a
__kcs_core_parser_exec() {
  local action="$1"
  shift

  local raw key value
  for raw in "${__KCS_PARSER_MAPPING[@]}"; do
    key="${raw%%=*}"
    value="${raw##*=}"
    if [[ $action == "$key" ]]; then
      action="$value"
      break
    fi
  done

  action="__kcs_${action//\./_}"
  "$action" "$@"
}
