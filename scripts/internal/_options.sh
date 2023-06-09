#!/usr/bin/env bash

## Options parser:
##   parsing options with some default configuration

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

__kcs_parse_options() {
  while getopts "$__KCS_GLOBAL_OPTS$KCS_OPTIONS" flag; do
    case "${flag}" in
    h) kcs_get_help ;;
    H) kcs_get_help_all ;;
    v) kcs_get_info ;;
    z) kcs_get_errcode_help ;;
    Q) __kcs_set_silent_mode ;;
    D) __kcs_set_debug_mode ;;
    R) __kcs_set_dry_run ;;
    L) __kcs_set_log_level "$OPTARG" ;;
    F) __kcs_set_log_file "$OPTARG" ;;
    K) kcs_disable_hook "$OPTARG" ;;
    -)
      NEXT="${!OPTIND}"
      __kcs_parse_long_option "$NEXT"
      case "${OPTARG}" in
      help)
        kcs_no_argument "$LONG_OPTARG"
        kcs_get_help
        ;;
      help-all)
        kcs_no_argument "$LONG_OPTARG"
        kcs_get_help_all
        ;;
      version)
        kcs_no_argument "$LONG_OPTARG"
        kcs_get_info
        ;;
      error)
        kcs_no_argument "$LONG_OPTARG"
        kcs_get_errcode_help
        ;;
      dry-run)
        kcs_no_argument "$LONG_OPTARG"
        __kcs_set_dry_run
        ;;
      silent)
        kcs_no_argument "$LONG_OPTARG"
        __kcs_set_silent_mode
        ;;
      debug)
        kcs_no_argument "$LONG_OPTARG"
        __kcs_set_debug_mode
        ;;
      log-level)
        kcs_require_argument "$LONG_OPTARG"
        __kcs_set_log_level "$LONG_OPTVAL"
        ;;
      log-file)
        kcs_require_argument "$LONG_OPTARG"
        __kcs_set_log_file "$LONG_OPTVAL"
        ;;
      disable-hook)
        kcs_require_argument "$LONG_OPTARG"
        kcs_disable_hook "$LONG_OPTVAL"
        ;;
      *)
        __kcs_parse_addition_options "$LONG_OPTARG" "$LONG_OPTVAL"
        ;;
      esac
      ;;
    ?)
      __kcs_parse_addition_options "$flag" "$OPTARG"
      ;;
    *)
      __kcs_parse_addition_options "$flag" "$OPTARG"
      ;;
    esac
  done

  shift $((OPTIND - 1))
  KCS_COMMANDS=("$@")
  export KCS_COMMANDS
}

__kcs_parse_addition_options() {
  local ns="option-parser"
  local flag="$1" value="$2"

  local default_cb="__kcs_default_option"
  local main_cb="__kcs_main_option"

  if command -v "$default_cb" >/dev/null; then
    kcs_debug "$ns" \
      "parsing options from 'default' callback"
    if "$default_cb" "$flag" "$value"; then
      return 0
    fi
  fi

  if command -v "$main_cb" >/dev/null; then
    kcs_debug "$ns" \
      "parsing options from 'main' callback"
    if "$main_cb" "$flag" "$value"; then
      return 0
    fi
  fi

  # because optspec is assigned by 'getopts' command
  # shellcheck disable=SC2154
  if [ "$OPTERR" == 1 ] && [ "${optspec:0:1}" != ":" ]; then
    kcs_throw "$KCS_EC_OPT_NOT_FOUND" \
      "$ns" "Unexpected option '%s', run --help for more information" \
      "$flag"
  fi
}

__KCS_GLOBAL_OPTS="hHvzQDRL:F:K:?-:"
## Short global options for help command
__KCS_GLOBAL_HELP_SHORT="
Global options:
  [--help,-h]
      - show command specific help message
  [--help-all,-H]
      - show full help message
"
## Fully global options for help-all command
__KCS_GLOBAL_HELP="
Global options:
  [--help,-h]
      - show command specific help message
  [--help-all,-H]
      - show full help message
  [--version,-v]
      - show script version
  [--error,-z]
      - show error code description
  [--dry-run,-R]
      - dry run mode will print only hook action
      - this for debugging only
  [--silent,-Q]
      - set log level to silent
  [--debug,-D]
      - set log level to debug
  [--log-level,-L] <0-5>
      - set log level (0=silent, 5=debug)
      - this handle on init hook
  [--log-file,-F] <filename>
      - log output file name
      - this handle on init hook
  [--disable-hook,-K] <name:callback>
      - disable input hook name (<name>:<callback>)
        - post_options:temp - temp setup before used
        - pre_clean:temp - temp cleanup after used
  [--] <args>
      - pass additional arguments to scripts
"
## Environment options for help-all command
__KCS_GLOBAL_HELP_ENV="
Environments:
  \$DEBUG=<any>
      - set to non-empty string will enabled debug mode
      - debug mode will print more detail than debug log.
  \$DEBUG_ONLY=<namespaces...>
      - string separated by comma (,)
      - to enabled only namespaced debug logging
      - works only if DEBUG is enabled
  \$DEBUG_DISABLED=<namespaces...>
      - string separated by comma (,) 
      - to disable namespaced debug logging
      - works only if DEBUG is enabled
      - below are verbosed namespaces:
        - hook-adder,core-wrapper,hook-runner,file-loader
  \$LOG_LEVEL=<0-5>
      - set to 0 - 5 same as --log-level option.
      - this handle on pre_init hook
  \$LOG_FILE=<name>
      - filename for logging
      - file will create at \$KCS_DIR_LOG directory
  \$DRY_RUN=<any>
      - set to non-empty string will enabled dry-run mode
  \$DRY_HOOK=<any>
      - set to non-empty string will never execute any hooks action
  \$KCS_DIR_UTILS=<path>
      - override 'utils' directory
  \$KCS_DIR_COMMANDS=<path>
      - override 'commands' directory
  \$KCS_DIR_TEMP=<path>
      - override 'temp' directory
  \$KCS_DIR_LOG=<path>
      - override 'log' directory
"

__kcs_options_clean() {
  unset __KCS_GLOBAL_OPTS \
    __KCS_GLOBAL_HELP \
    __KCS_GLOBAL_HELP_ENV
}
