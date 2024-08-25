#!/usr/bin/env bash

export __KCS_LOADER_SETUP_FILE=index.sh

__KCS_LOADER_MODULES=()

kcs_core_load() {
  return 0
}

__kcs_core_load() {
  local name="$1" file="${2:-$__KCS_LOADER_SETUP_FILE}"

  if [[ "$name" == "$KCS_DEFAULT" ]]; then
    __kcs_core_load loggers &&
      __kcs_core_load colors &&
      __kcs_core_load temporaries
    return $?
  fi

  echo "loading $name $file"
  return 0
}
