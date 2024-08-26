#!/usr/bin/env bash

export __KCS_CONFIG_KEY="__KCS_CONFIG_DB_"
export __KCS_CONFIG_ARRAY_SEP=","

export __KCS_CONFIG_SPACE_TOKEN="__space__"
export __KCS_CONFIG_COMMA_TOKEN="__comma__"
export __KCS_CONFIG_AND_TOKEN="__and__"
export __KCS_CONFIG_DOLLAR_TOKEN="__dollar__"
export __KCS_CONFIG_SLASH_TOKEN="__slash__"
export __KCS_CONFIG_BACK_SLASH_TOKEN="__back_slash__"

## get config value (use default if not exist)
## usage: kcs_config_get '<key>' [default]
kcs_config_get() {
  local ns="core.config.get"
  local key value default="$2"
  key="$(_kcs_config_key_get "${1:?Config key is missing}")"
  eval "value=\"\${${key}:-$default}\""
  # kcs_simple_logger debug "$ns" "getting config value from '%s': %s" "$key" "$value"
  _kcs_config_value_decode "$value"
}

## get config values as array
## usage:
##     local raw line
##     while read -r raw; do
##       line="$(kcs_config_decode "$raw")"
##       echo "line: $line"
##     done <<<"$(kcs_config_get_array array)"
## usage:
##     # shellcheck disable=SC2207
##     local array=($(kcs_config_get_array array))
##     for raw in "${array[@]}"; do
##       line="$(kcs_config_decode "$raw")"
##       echo "line: $line"
##     done
kcs_config_get_array() {
  local ns="core.config.get"
  local key
  key="$(_kcs_config_key_get "${1:?Config key is missing}")"

  # kcs_simple_logger debug "$ns" "getting config value from key: %s" "$key"
  eval "printf '%s' \"\${${key}//$__KCS_CONFIG_ARRAY_SEP/$'\n'}\""
}

## append data to existed config key
## usage: kcs_config_append <key> <value>
kcs_config_append() {
  local ns="core.config.append"
  local key raw val value
  key="$(_kcs_config_key_get "${1:?Config key is missing}")"

  local previous
  eval "previous=\$$key"
  if [ -z "$previous" ]; then
    # kcs_simple_logger debug "$ns" "Use set(%s) instead because no previous data" "$1"
    kcs_config_set "$@"
    return $?
  fi

  shift
  if [ $# -lt 1 ]; then
    kcs_simple_logger throw "$ns" "Cannot set config key '%s' because no value provided" "$key"
  fi

  for raw in "$@"; do
    val="$(_kcs_config_value_encode "$raw")"
    if [ -z "$value" ]; then
      value="$val"
    elif [ -n "$val" ]; then
      value="$value$__KCS_CONFIG_ARRAY_SEP$val"
    fi
  done

  # kcs_simple_logger debug "$ns" "append value '%s' to '%s'" "$value" "$key"
  eval "$key+='$__KCS_CONFIG_ARRAY_SEP$value'"
}

## set config key by input value
## usage: kcs_config_set <key> <value>         | kcs_config_get <key>
## usage: kcs_config_set <key> <arg-1> <arg-2> | kcs_config_get_array <key>
kcs_config_set() {
  local ns="core.config.set"
  local key raw val value
  key="$(_kcs_config_key_get "${1:?Config key is missing}")"
  shift

  if [ $# -lt 1 ]; then
    kcs_simple_logger throw "$ns" "Cannot set config key '%s' because no value provided" "$key"
  fi

  for raw in "$@"; do
    val="$(_kcs_config_value_encode "$raw")"
    if [ -z "$value" ]; then
      value="$val"
    elif [ -n "$val" ]; then
      value="$value$__KCS_CONFIG_ARRAY_SEP$val"
    fi
  done

  # kcs_simple_logger debug "$ns" "export variable %s=%s" "$key" "$value"
  eval "export $key='$value'"
}

## reset config key to empty value
## usage: kcs_config_reset <key>
kcs_config_reset() {
  local ns="core.config.reset"
  local key
  key="$(_kcs_config_key_get "${1:?Config key is missing}")"

  # kcs_simple_logger debug "$ns" "reseting config key: %s" "$key"
  eval "unset $key"
}

## decode config value to origin data
## usage: kcs_config_decode '<value>'
kcs_config_decode() {
  _kcs_config_value_decode "$@"
}

## get config key variable name
## usage: _kcs_config_key_get '<name>'
_kcs_config_key_get() {
  local input="$1"
  input="${input//[&|$]/}"
  input="${input//[ ,.]/_}"
  printf '%s%s' "$__KCS_CONFIG_KEY" "$input" | tr '[:lower:]' '[:upper:]'
}

## encode value to tokenize form (replace problematic string)
## usage: _kcs_config_value_encode '<value>'
_kcs_config_value_encode() {
  local input="$1"
  input="${input// /$__KCS_CONFIG_SPACE_TOKEN}"
  input="${input//,/$__KCS_CONFIG_COMMA_TOKEN}"
  input="${input//&/$__KCS_CONFIG_AND_TOKEN}"
  input="${input//$/$__KCS_CONFIG_DOLLAR_TOKEN}"
  input="${input//\//$__KCS_CONFIG_SLASH_TOKEN}"
  input="${input//\\/$__KCS_CONFIG_BACK_SLASH_TOKEN}"
  printf '%s' "$input"
}

## decode value to original form (remove all token)
## usage: _kcs_config_value_decode '<value>'
_kcs_config_value_decode() {
  local input="$1"
  input="${input//$__KCS_CONFIG_SPACE_TOKEN/ }"
  input="${input//$__KCS_CONFIG_COMMA_TOKEN/,}"
  input="${input//$__KCS_CONFIG_AND_TOKEN/&}"
  input="${input//$__KCS_CONFIG_DOLLAR_TOKEN/$}"
  input="${input//$__KCS_CONFIG_SLASH_TOKEN/\/}"
  input="${input//$__KCS_CONFIG_BACK_SLASH_TOKEN/\\}"
  printf '%s' "$input"
}
