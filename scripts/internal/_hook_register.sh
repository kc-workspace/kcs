#!/usr/bin/env bash
## Hooks:

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

_kcs_register_hooks() {
  kcs_add_hook pre_init \
    __kcs_set_name:@optional,@cb=__kcs_main_name
  kcs_add_hook pre_init \
    __kcs_set_version:@optional,@cb=__kcs_main_version
  kcs_add_hook pre_init \
    __kcs_set_options:@optional,@cb=__kcs_main_option_keys
  kcs_add_hook pre_init \
    __kcs_set_description:@optional,@cb=__kcs_main_description
  kcs_add_hook pre_init \
    __kcs_set_help:@optional,@cb=__kcs_main_help
  kcs_add_hook pre_init \
    __kcs_logger_pre_init
  kcs_add_hook pre_init \
    __kcs_debug_pre_init:@optional,@raw
  kcs_add_hook pre_init \
    __kcs_pre_init:@optional

  kcs_add_hook init \
    __kcs_init:@optional

  kcs_add_hook post_init \
    __kcs_parse_options:@optional,@raw
  kcs_add_hook post_init \
    __kcs_load_utils:@optional,@cb=__kcs_main_utils
  kcs_add_hook post_init \
    __kcs_main_hook:@optional
  kcs_add_hook post_init \
    __kcs_post_init:@optional

  kcs_add_hook pre_validate \
    __kcs_pre_validate:@optional

  kcs_add_hook validate \
    __kcs_validate:@optional

  kcs_add_hook post_validate \
    __kcs_post_validate:@optional

  kcs_add_hook pre_main \
    __kcs_debug_pre_main:@optional
  kcs_add_hook pre_main \
    __kcs_pre_main:@optional

  kcs_add_hook main \
    __kcs_main:@raw

  kcs_add_hook post_main \
    __kcs_post_main:@optional

  kcs_add_hook pre_clean \
    __kcs_pre_clean:@optional

  kcs_add_hook clean \
    __kcs_error_clean
  kcs_add_hook clean \
    __kcs_clean:@optional

  kcs_add_hook post_clean \
    __kcs_logger_clean
  kcs_add_hook post_clean \
    __kcs_post_clean:@optional
}

__kcs_required_hook() {
  kcs_throw "$@"
}

__kcs_optional_hook() {
  shift 1
  kcs_debug "$@"

  return 0
}

__kcs_register() {
  local ns="register hook"
  local callback="$1" name="$2" raw="$3"
  local cb="${raw%%:*}"

  if test -z "$raw"; then
    ## same syntax with kcs_throw
    "$callback" "$KCS_ERRCODE_MISSING_REQUIRED_ARGUMENT" \
      "$ns" "cannot register %s hook because missing callback" \
      "$name"
    return $?
  fi

  if ! command -v "$cb" >/dev/null; then
    ## same syntax with kcs_throw
    "$callback" "$KCS_ERRCODE_CMD_NOT_FOUND" \
      "$ns" "%s hook failed, callback '%s' missing" \
      "$name" "$cb"
    return $?
  fi

  kcs_add_hook "$name" "$raw"
}
