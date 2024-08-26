#!/usr/bin/env bash

## Entrypoint
## usage: "$KCS_START" "$@"
_kcs_core_main() {
  local ns="core.main"
  local event code
  for event in "${__KCS_EVENT_NAMES[@]}"; do
    kcs_event_run "$event" "$@"
    code=$?
    if [ $code -gt 0 ]; then
      kcs_exec logger error "$ns" "Event '%s' return error (%d)" "$event" "$code"
      return $code
    fi
  done
}
