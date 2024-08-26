#!/usr/bin/env bash

__KCS_EVENT_NAMES=(
  setup    ## For core only, for plugin use init instead
  init     ## For plugin initiate before main executes
  main     ## main execution process
  teardown ## for teardown plugins and core
)

## add listen function to specific event (error if function is missing or fail)
kcs_event_add() {
  local event="$1" name="$2"
  shift 2
  _kcs_event_add "$event" "$name" -- "$@"
}

## add listen function to specific event (if function is missing, silently ignore)
## usage: kcs_event_optional_add setup name           => call __kcs_name_on_setup
## usage: kcs_event_optional_add setup name <args...> => call __kcs_name_on_setup <args...>
kcs_event_optional_add() {
  local event="$1" name="$2"
  shift 2
  _kcs_event_add "$event" "$name" --optional -- "$@"
}

## run all listeners on input event
## usage: kcs_event_run "<event>"
kcs_event_run() {
  local ns="core.event.run"
  local event="$1"

  local raw callbacks=()
  while read -r raw; do
    if [ -n "$raw" ]; then
      callbacks+=("$(kcs_config_decode "$raw")")
    fi
  done <<<"$(kcs_config_get_array "e.$event.cb")"

  if [ "${#callbacks[@]}" -lt 1 ]; then
    kcs_exec logger debug "$ns" "no callback for event: %s" "$event"
    return 0
  fi

  local callback
  kcs_exec logger debug "$ns" "event %s: run '%d' callbacks" "$event" "${#callbacks[@]}"
  for callback in "${callbacks[@]}"; do
    ## Too many output
    # kcs_exec logger debug "$ns" "starting on callback: %s" "$callback"
    local args=()
    while read -r raw; do
      if [ -n "$raw" ]; then
        args+=("$(kcs_config_decode "$raw")")
      fi
    done <<<"$(kcs_config_get_array "e.$event.$callback.args")"

    kcs_exec logger debug "$ns" "event %s: start callback '%s'" "$event" "$callback"
    _kcs_exec "$callback" "on.$event" --callback "${args[@]}" || return $?
  done
}

_kcs_event_add() {
  local ns="core.event.add"
  local event="$1" name="$2"
  shift 2

  if ! [[ "${__KCS_EVENT_NAMES[*]}" =~ $event ]]; then
    kcs_exec logger error "$ns" "Invalid event name: %s" "$event"
    return "$KCS_ERR_EVENT_FAILED"
  fi

  kcs_config_append "e.$event.cb" "$name"
  if [ $# -gt 0 ]; then
    kcs_config_set "e.$event.$name.args" "$@"
  fi
}
