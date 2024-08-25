#!/usr/bin/env bash

export __KCS_SETTING_PREFIX="__KCS_SETTING_"

export __KCS_SETTING_SPACE_TOKEN="[[:space:]]"
export __KCS_SETTING_COMMA_TOKEN="[[:comma:]]"
export __KCS_SETTING_ARRAY_SEPARATOR=","

## get setting value with default value
## usage: kcs_core_setting_get 'key'
## usage: kcs_core_setting_get 'key' 'default'
kcs_core_setting_get() {
  local key value="$2"
  key="$(__kcs_core_setting_key_sanitize "${1:?Setting key is missing}")"
  kcs_exec logger debug "getting setting key: %s" "$key"
  eval "__kcs_core_setting_value_decode \"\${${__KCS_SETTING_PREFIX}${key}:-$value}\""
}

__kcs_core_setting_set() {
  local key="${1:?Setting key is missing}" raw val value
  shift

  if [ $# -lt 1 ]; then
    kcs_exec logger throw "No value provided for setting: %s" "$key"
  fi

  for raw in "$@"; do
    val="$(__kcs_core_setting_value_sanitize "$raw")"
    if [ -z "$value" ]; then
      value="$val"
    else
      value="$value$__KCS_SETTING_ARRAY_SEPARATOR$val"
    fi
  done

  key="$(__kcs_core_setting_key_sanitize "$key")"
  kcs_exec logger debug \
    "export variable %s%s=%s" "$__KCS_SETTING_PREFIX" "$key" "$value"
  eval "export $__KCS_SETTING_PREFIX$key=$value"
}

__kcs_core_setting_key_sanitize() {
  local input="$1"
  input="${input//[&|$]/}"
  input="${input//[ ,.]/_}"

  printf '%s' "$input" | tr '[:lower:]' '[:upper:]'
}

__kcs_core_setting_value_sanitize() {
  local input="$1"
  input="${input//[&|$]/}"
  input="${input// /$__KCS_SETTING_SPACE_TOKEN}"
  input="${input//,/$__KCS_SETTING_COMMA_TOKEN}"
  printf '%s' "$input"
}

__kcs_core_setting_value_decode() {
  local input="$1"
  input="${input//$__KCS_SETTING_SPACE_TOKEN/ }"
  input="${input//$__KCS_SETTING_COMMA_TOKEN/ }"
  printf '%s' "$input"
}
