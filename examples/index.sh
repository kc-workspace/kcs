#!/usr/bin/env bash
# shellcheck source=/dev/null

## name=index.sh
## version=v2.0.0-alpha.1

## Variables:
## $KCS_NS_XXX   - Readonly variables (for getting information)
## $_KCS_NS_XXX  - Configurable varibles (for setting information)
## $__KCS_NS_XXX - Private variables (for reference on same file only)
## $XXX          - Special variables alias $_KCS_XXX variables

## Functions:
## kcs_ns_xxx    - Public functions (can call by anyone)
## _kcs_ns_xxx   - Private functions (should call by same file or same directory)
## __kcs_ns_xxx  - Callback functions (will call by callback function)

## Convension:
## Function namespace must be single form; except callback function
## Plugin name (directory) must be plural form
## Core and plugins file must be plural form (except main.sh)
## Function must be end with verb (e.g. get, set, list, delete)
## Core and plugins functions should sorted as public -> private -> callback

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

## Call by @exec tag
__kcs_hello_main() {
  if [ "$#" -gt 0 ]; then
    echo "main arguments: $# '$*'"
  fi

  return 0
}

## Call by @listen tag
__kcs_hello_on_main() {
  kcs_exec logger info 'core.main' 'hello world'
}

# endregion
# ---------------------------------------------------------------------------- #

# region - Script Runner Arguments

## Default tags:
##   - @config <key> <arg> [args...]
##       -- set config key to value; if set more than 1 argument, config key will set value as array
##       -- reference: core/configs.sh
##   - @load <plugin> [args...]
##       -- load plugin to current script
##       -- reference: core/loaders.sh
##   - @exec <name> [args...]
##       -- execute __kcs_<config.name|default>_<name> immediately
##       -- reference: core/executors.sh
##   - @listen <step=[setup|init|main|teardown]> [args...]
##       -- execute __kcs_<config.name|default>_on_<step> when step start
##       -- reference: core/events.sh

_KCS_OPTIONS=(
  @config CACHE true
  @config MODE main
  @config NAME hello     # use to set callback function namespace
  @config VERSION v1.0.0 # use to print script version
  @load "$KCS_DEFAULT"   # extends loggers, add colors support, improve temporary file/folder support
  @load registries       # load registry plugin
  @exec main
  @listen main
  # @registry.add "kamontat/example-kcs" main # add kamontat/example-kcs registry
  # @load hook                                # load hook plugin: setup main teardown post_teardown finish
  # @hook.use "$KCS_DEFAULT"                  # add _kcs_<setting.name>_hook_<hook-name> for all hooks name
  # @hook.new setup custom_name               # add _kcs_<setting.name>_hook_<hook-name>_custom_name function to setup hook
  # @load option                              # add option support
  # @option.use "$KCS_DEFAULT"
  # @option.new '-e,--example [str:hello]' 'EXAMPLE' 'show example message'
)

## Minimal options
# _KCS_OPTIONS=(
#   @setting NAME hello
#   @exec main
# )

# endregion
# ---------------------------------------------------------------------------- #

"$KCS_START" "$@"
