#!/usr/bin/env bash
##command-example:v1.0.0-beta.1

## <title>:
##   <description>
##
## > learn more at README.md

# set -x #DEBUG    - Display commands and their arguments as they are executed.
# set -v #VERBOSE  - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
# set -e #ERROR    - Force exit if error occurred.

####################################################
## User defined function
####################################################

export KCS_NAME="exec"
export KCS_VERSION="v0.0.0"
export KCS_DESCRIPTION="This command is extremely dangerous because
it will execute command arguments you sent
using 'eval' command. If you not sure what
are you doing, please do not use this command."
export KCS_HELP="
Example usage:
  KCS_UTILS=builtin/temp ./scripts/main.sh __exec kcs_temp_clean_all
    - this will setup temp directory to initiate state
"

__kcs_main() {
  eval "$*"
}

####################################################
## Internal function calls
####################################################

## original current directory
export _KCS_DIR_ORIG="${_KCS_DIR_ORIG:-$PWD}"

## move to script directory
## later, it will moved to root directory instead
if test -z "$_KCS_DIR_SCRIPT"; then
  cd "$(dirname "$0")/.." || exit 1
  export _KCS_DIR_SCRIPT="$PWD"
fi

# shellcheck disable=SC1091
source "$_KCS_DIR_SCRIPT/internal/command.sh" || exit 1

kcs_prepare
kcs_start "$@"