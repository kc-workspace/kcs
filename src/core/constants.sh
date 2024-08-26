#!/usr/bin/env bash

## Defined in core/main.sh
export KCS_START='_kcs_core_main'

## Special variables for default value
export KCS_DEFAULT='<default>'

## System exit code
export KCS_ERR_CMD_NOT_FOUND=127
## fatal exit code
export KCS_ERR_PANIC=10
export KCS_ERR_SETUP=11
## generic exit code
export KCS_ERR_TIDY_FAILED=20
export KCS_ERR_LOAD_FAILED=21
export KCS_ERR_EVENT_FAILED=22
export KCS_ERR_PARSER_FAILED=23
