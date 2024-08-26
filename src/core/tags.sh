#!/usr/bin/env bash

## @config <key> <arg> [args...]
__kcs_core_tags_config() {
  kcs_config_set "$@"
}

## @load <plugin> [args...]
__kcs_core_tags_load() {
  local name="$1"
  shift
  kcs_load_plugin "$name" "$@"
}

## @exec <name> [args...]
__kcs_core_tags_exec() {
  local name="$1"
  shift
  _kcs_exec "$(kcs_config_get "NAME" 'default')" "$name" --callback -- "$@"
}

## @listen <step=[setup|init|main|teardown]> [args...]
__kcs_core_tags_listen() {
  local event="$1"
  shift
  kcs_event_add "$event" "$(kcs_config_get "NAME" 'default')" "$@"
}
