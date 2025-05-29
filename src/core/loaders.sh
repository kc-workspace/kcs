#!/usr/bin/env bash
# shellcheck disable=SC1090

export __KCS_LOADER_PLUGINS_CONF="loader.plugins"
__KCS_LOADER_DEFAULT_PLUGINS=(
  colors loggers temporaries
)

## Load plugin
## usage: kcs_load_plugin <name> [args...]
## usage: kcs_load_plugin logger [args...]
kcs_load_plugin() {
  local ns="core.loader.plugin.load"
  local name="${1:?Plugin name is required}"
  local filename="$name.sh"
  shift

  if [[ "$name" == "$_KCS_CORE_DEFAULT" ]]; then
    local plugin
    for plugin in "${__KCS_LOADER_DEFAULT_PLUGINS[@]}"; do
      kcs_load_plugin "$plugin" "$@" || return $?
    done
    return 0
  fi

  if [[ "$(kcs_config_get "$__KCS_LOADER_PLUGINS_CONF")" =~ $name ]]; then
    kcs_exec logger debug "$ns" "skipped loaded plugin: %s" "$name"
    return 0
  fi

  local locations=(
    "$_KCS_PATH_WDIR/src/plugins"
    "$_KCS_PATH_PLUGINS"
  )

  kcs_exec logger debug "$ns" \
    "checking '%s' plugin from: #%d locations" "$name" "${#locations[@]}"

  local dir target="$_KCS_PATH_PLUGINS"
  for dir in "${locations[@]}"; do
    if [ -f "$dir/$filename" ]; then
      target="$dir"
      break
    fi
  done

  if ! [ -d "$target" ]; then
    kcs_exec logger debug "$ns" "creating missing target directory: %s" "$target"
    mkdir -p "$target" || return "$_KCS_ERR_TIDY_FAILED"
  fi

  local filepath="$target/$filename"
  if ! [ -f "$filepath" ] && ! "$_KCS_CORE_LOCAL"; then
    local registry download_url http_status_file http_status
    for registry in "${__KCS_CORE_REGISTRIES[@]}"; do
      http_status_file="$(kcs_exec temp file)"
      download_url="https://${registry}/${filepath#*"$_KCS_PATH_ROOT"/}"
      kcs_exec logger debug "$ns" "downloading '%s' to '%s'" "$download_url" "$filepath"

      if ! curl -sSL -w "%{http_code}" -o "$filepath" "$download_url" >"$http_status_file"; then
        kcs_exec logger debug "$ns" "curl command return non-zero code"
        rm "$http_status_file" || return "$_KCS_ERR_TIDY_FAILED"
        continue
      fi

      http_status="$(head -n1 "$http_status_file")"
      rm "$http_status_file" || return "$_KCS_ERR_TIDY_FAILED"

      if [ "$http_status" -ne 200 ]; then
        kcs_exec logger debug "$ns" "http response status is %d" "$http_status"
        rm "$filepath" || return "$_KCS_ERR_TIDY_FAILED"
        continue
      fi
    done
  fi

  if ! [ -f "$filepath" ]; then
    kcs_exec logger error "$ns" "Missing target file to load: %s" "$filepath"
    return "$_KCS_ERR_LOAD_FAILED"
  fi

  local code=0
  kcs_exec logger debug "$ns" "loading '%s' #%d [%s]" "$filepath" "$#" "$*"
  source "$filepath" "$@"
  code=$?

  if [ $code -gt 0 ]; then
    kcs_exec logger error "$ns" "Non-zero exit code when loading file: %s" "$filepath"
    return "$code"
  fi

  kcs_config_append "$__KCS_LOADER_PLUGINS_CONF" "$name"
  kcs_event_optional_add init "$name" "$@"
  kcs_event_optional_add teardown "$name" "$@"
}
