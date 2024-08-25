#!/usr/bin/env bash
# shellcheck source=/dev/null

## name=index.sh
## version=v2.0.0-alpha.1

## Variables:
## $KCS_XXX     - Readonly variables (For getting information)
## $_KCS_XXX    - Configurable varibles (For setting configuration)
## $__KCS_XXX   - Internal variables (For internal usage)

## Functions:
## kcs_ns_xxx   - Public APIs for end user
## _kcs_ns_xxx  - End user callback
## __kcs_ns_xxx - Interval functions (For)

## Convension:
## Namespace (ns) key must be single form
## xxx on function must end with verb (e.g. get, set, list, delete)
## Plugin name must be plural form

# region - Script Settings

## The KCS version to set up (Allowed values: latest, branch name (e.g. main), version (e.g. v1.0.0))
# _KCS_VERSION=main
## Enabled debug mode
# _KCS_DEBUG=debug

# _KCS_ROOT_PATH="$HOME/.kcs"
_KCS_ROOT_PATH="$(cd "$(dirname "$0")/.." && pwd)"
_KCS_TEMP_PATH="$_KCS_ROOT_PATH/.temp"

# endregion
# ---------------------------------------------------------------------------- #

# region - Script Loaders

## You can switch between load from github or local file system
__KCS_SETUP_PATH="${_KCS_ROOT_PATH:?root path is missing}/src/setup.sh"
! [ -f "$__KCS_SETUP_PATH" ] &&
  curl -sSL -o "$__KCS_SETUP_PATH" "https://github.com/kc-workspace/kcs/raw/$_KCS_VERSION/src/setup.sh"
source "$__KCS_SETUP_PATH"

# endregion
# ---------------------------------------------------------------------------- #

# region - Script Callbacks

_kcs_main_hello() {
  if [ "$#" -gt 0 ]; then
    echo "$@"
  fi

  return 0
}

# endregion
# ---------------------------------------------------------------------------- #

# region - Script Runner Arguments

## Default tags @setting, @exec, and @load
## @version - set version all plugins should load from
_KCS_SCRIPT_ARGUMENTS=(
  @setting CACHE true     # set setting (__KCS_SETTINGS_CACHE=true)
  @setting MODE main      # support 'main' or 'command' mode
  @setting NAME hello     # set command name
  @setting VERSION v1.0.0 # set command version
  @load "$KCS_DEFAULT"    # add loggers, colors, temporaries support
  @exec main              # immediately execute _kcs_<$1>_<setting.name> command
  @load registry          # load registry support (load plugins from multiple registry)

  # @registry.add "kamontat/example-kcs" main # add kamontat/example-kcs registry
  # @load hook                                # hook names: setup main cleanup post_cleanup finish
  # @hook.use "$KCS_DEFAULT"                  # add _kcs_hook_<hook-name>_<command-name>
  # @hook.new setup custom_name               # add _kcs_hook_setup_custom_name function to setup hook
  # @load option                              # add option support
  # @option.use "$KCS_DEFAULT"
  # @option.new '-e,--example [str:hello]' 'EXAMPLE' 'show example message'
)

## Minimal argument
# _KCS_SCRIPT_ARGUMENTS=(
#   @version main
#   @main
# )

# endregion
# ---------------------------------------------------------------------------- #

"$KCS_START" "$@"
