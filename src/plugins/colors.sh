#!/usr/bin/env bash
# shellcheck disable=SC2154

kcs_color_default() {
  kcs_color_print "$1" DEFAULT
}
kcs_color_black() {
  kcs_color_print "$1" BLACK
}
kcs_color_info() {
  kcs_color_print "$1" CYAN
}
kcs_color_warn() {
  kcs_color_print "$1" YELLOW
}
kcs_color_error() {
  kcs_color_print "$1" RED
}

## add color to input message
## usage: kcs_color_print 'hello' RED
kcs_color_print() {
  local msg="$1" color reset raw
  shift

  reset="$(kcs_config_get "COLOR_RESET")"
  for raw in "$@"; do
    color+="$(kcs_config_get "COLOR_$raw")"
  done

  printf "$color%s$reset" "$msg"
}

__kcs_colors_on_init() {
  kcs_config_set COLOR_RESET '\033[0m'

  kcs_config_set COLOR_DEFAULT '\033[0;29m'
  kcs_config_set COLOR_BLACK '\033[0;30m'
  kcs_config_set COLOR_RED '\033[0;31m'
  kcs_config_set COLOR_GREEN '\033[0;32m'
  kcs_config_set COLOR_YELLOW '\033[0;33m'
  kcs_config_set COLOR_BLUE '\033[0;34m'
  kcs_config_set COLOR_PINK '\033[0;35m'
  kcs_config_set COLOR_CYAN '\033[0;36m'
  kcs_config_set COLOR_WHITE '\033[0;37m'

  kcs_config_set COLOR_BG_BLACK '\033[40m'
  kcs_config_set COLOR_BG_RED '\033[41m'
  kcs_config_set COLOR_BG_GREEN '\033[42m'
  kcs_config_set COLOR_BG_YELLOW '\033[43m'
  kcs_config_set COLOR_BG_BLUE '\033[44m'
  kcs_config_set COLOR_BG_PINK '\033[45m'
  kcs_config_set COLOR_BG_CYAN '\033[46m'
  kcs_config_set COLOR_BG_WHITE '\033[47m'
}
