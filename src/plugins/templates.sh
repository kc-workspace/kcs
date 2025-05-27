#!/usr/bin/env bash

## parse template string with arguments
## usage: kcs_template_parse 'hello {name}' 'name=world'
kcs_template_parse() {
  local template="$1"
  shift

  local kv key value
  for kv in "$@"; do
    key="${kv%%=*}"
    value="${kv#*=}"
    template="${template//\{$key\}/$value}"
  done

  printf "%s" "$template"
}
