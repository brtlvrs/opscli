#!/bin/bash

ops::common::prereqVar() {
#-- START CHEAT --
#  Function: ops::common::prereqVar
#    Alias: prereqvar
#    Description: checks if given variable(s) exist and are not empty
#    Syntax:  prereqvar <var1> <var2> || return $?
#    Parameters:
#         $@  : one or more variable name(s), space separated
#-- END CHEAT --

  for var_name in "$@"; do
    if [[ ! -v "$var_name" ]]; then
      # Variable doesn't exist. Let's warn and exit
      writeWRN "WARNING $var_name is not set"
      return 1
    fi
    if [[ -z "${!var_name}" ]]; then
      # Variable is empty, let's warn and exit
      writeWRN "WARNING $var_name is empty"
      return 1
    fi
  done
  return 0
}

alias prereqvar='ops::common::prereqVar'