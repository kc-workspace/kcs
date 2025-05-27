# Kamontat's Shell

A shell collection with highly customizable.

## Get start

```bash
#!/usr/bin/env bash
# shellcheck source=/dev/null

export KCS_PATH_ROOT="$PWD/.kcs"
export KCS_CORE_SETUP="src/setup.sh"
export KCS_CORE_VERSION="main"
export KCS_CORE_REGISTRY="github.com/kc-workspace/kcs/raw/$KCS_CORE_VERSION"

# region - Script Loaders

## You can switch between load from github or local file system
__KCS_PATH_SETUP="${KCS_PATH_ROOT:?root path is missing}/$KCS_CORE_SETUP"
if ! [ -f "$__KCS_PATH_SETUP" ]; then
  mkdir -p "$(dirname "$__KCS_PATH_SETUP")"
  curl -sSL -o "$__KCS_PATH_SETUP" "https://$KCS_CORE_REGISTRY/$KCS_CORE_SETUP"
fi
source "$__KCS_PATH_SETUP"

# endregion
# ---------------------------------------------------------------------------- #

KCS_CORE_OPTIONS=(
  @load "$_KCS_CORE_DEFAULT"
  @listen main
)

__kcs_default_on_main() {
  kcs_exec logger info default.main "hello world"
  return 0
}

"$_KCS_CORE_START" "$@"
```

## KCS_CORE_OPTIONS

The core options use tags (<@tag>) with arguments to setting scripts.

### Possible Tags

1. `@config <key> [values...]` - set config key to values (core/configs.sh)
2. `@load <plugin> [args...]` - load plugin to current script (core/loaders.sh)
3. `@exec <name> [args...]` - execute callback function immediately (NOT recommended)
4. `@listen <step=[init|main|teardown]> [args...]` - execute callback when step start (core/events.sh)
