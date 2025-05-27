#!/usr/bin/env bash

## execute tags with
## usage: _kcs_parser_exec hello [args...] => __kcs_core_tag_hello [args...]
## usage: _kcs_parser_exec option.use      => __kcs_option_tag_use
_kcs_parser_exec() {
  local raw="$1"
  shift

  local namespace="${raw%%.*}" name="${raw#*.}"
  if [[ "$namespace" == "$name" ]]; then
    namespace=core
  fi

  _kcs_exec "$namespace" "tag.$name" --callback --panic -- "$@"
}

## parsing $KCS_CORE_OPTIONS array with tags
## run on setup event, this should be the beginning of the setup event callbacks
__kcs_parser_on_setup() {
  local ns="core.parser.setup"
  if [ "${#KCS_CORE_OPTIONS[@]}" -lt 1 ]; then
    kcs_exec logger error "$ns" "\$KCS_CORE_OPTIONS must contains at least 1 option"
    return "$_KCS_ERR_PARSER_FAILED"
  fi

  local raw tag args=() code=0
  for raw in "${KCS_CORE_OPTIONS[@]}"; do
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
