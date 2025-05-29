#!/usr/bin/env bash

# @registry.add <registry-url>
__kcs_registry_tag_add() {
  local input="$1" ns="registry.tag.add"
  local registry repository="" version=""

  case "$input" in
  gh:*)
    repository="${input%@*}"
    version="${input##*@}"

    if [[ "$repository" == "$version" ]]; then
      version="$_KCS_CORE_VERSION"
    fi

    repository="${repository/gh:/}"
    registry="github.com/$repository/raw/$version"
    ;;
  *)
    kcs_exec logger throw "Invalid registry syntax"
    ;;
  esac

  kcs_exec logger debug "$ns" "adding new registry: %s" "$registry"
  __KCS_CORE_REGISTRIES+=("$registry")
}
