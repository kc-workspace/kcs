#!/usr/bin/env bash
# shellcheck source=/dev/null

# export KCS_PATH_ROOT="$PWD/.kcs"
KCS_PATH_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

export KCS_CORE_SETUP="src/setup.sh"
export KCS_CORE_VERSION="refactor/v2"
export KCS_CORE_REGISTRY="github.com/kc-workspace/kcs/raw/$KCS_CORE_VERSION"

# region - Script Loaders

## You can switch between load from github or local file system
__KCS_PATH_SETUP="${KCS_PATH_ROOT:?root path is missing}/$KCS_CORE_SETUP"
if ! [ -f "$__KCS_PATH_SETUP" ]; then
  curl -sSL -o "$__KCS_PATH_SETUP" "https://$KCS_CORE_REGISTRY/$KCS_CORE_SETUP"
fi
source "$__KCS_PATH_SETUP"

# endregion
# ---------------------------------------------------------------------------- #

# shellcheck disable=SC2034
KCS_CORE_OPTIONS=(
  @exec main
)

__kcs_default_main() {
  kcs_exec logger info default.main "hello %s" world
}

"$_KCS_CORE_START" "$@"
