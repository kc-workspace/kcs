#!/usr/bin/env bash

## Defined in core/main.sh
export _KCS_CORE_START='_kcs_core_main'
## Special variables for default value
export _KCS_CORE_DEFAULT='<default>'

## System exit code
export _KCS_ERR_CMD_NOT_FOUND=127
## fatal exit code
export _KCS_ERR_PANIC=10
export _KCS_ERR_SETUP=11
## generic exit code
export _KCS_ERR_TIDY_FAILED=20
export _KCS_ERR_LOAD_FAILED=21
export _KCS_ERR_EVENT_FAILED=22
export _KCS_ERR_PARSER_FAILED=23
