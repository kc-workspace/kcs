#!/usr/bin/env bash

## execute tags with
## usage: _kcs_parser_exec hello [args...] => __kcs_core_tags_hello [args...]
## usage: _kcs_parser_exec option.use      => __kcs_option_tags_use
_kcs_parser_exec() {
  local raw="$1"
  shift

  local namespace="${raw%%.*}" name="${raw#*.}"
  if [[ "$namespace" == "$name" ]]; then
    namespace=core
  fi

  _kcs_exec "$namespace" "tags.$name" --callback --panic -- "$@"
}

## parsing $_KCS_OPTIONS array
## run on setup event, this should be the beginning of the setup event callbacks
## usage: never manually call
__kcs_parser_on_setup() {
  local ns="core.parser.setup"
  if [ "${#_KCS_OPTIONS[@]}" -lt 1 ]; then
    kcs_exec logger error "$ns" "\$_KCS_OPTIONS must contains at least 1 option"
    return "$KCS_ERR_PARSER_FAILED"
  fi

  local raw tag args=() code=0
  for raw in "${_KCS_OPTIONS[@]}"; do
    if [[ "$raw" =~ ^@ ]]; then
      if [ -n "$tag" ]; then
        _kcs_parser_exec "$tag" "${args[@]}"
        code=$?
        if [ $code -gt 0 ]; then
          return $code
        fi
      fi

      tag="${raw:1}"
      args=()
    else
      args+=("$raw")
    fi
  done

  if [ -n "$tag" ]; then
    _kcs_parser_exec "$tag" "${args[@]}"
    code=$?
    if [ $code -gt 0 ]; then
      return $code
    fi
  fi
}

kcs_event_add setup parser
