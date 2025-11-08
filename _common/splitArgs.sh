#!/bin/bash

ops::common::splitArgs(){
#-- START CHEAT --
#  Function: ops::common::splitArgs
#    Alias:  
#    Description: Process all arguments and return them in a default structure, arg=value ==> arg value
#    usage: newargs=($(ops::common::splitArgs "${args[@]")))
#-- END CHEAT --

  # input: [array][strings] ("$@") or "${args[@]}"
  # output: [array][strings]
  #
  #usage: newargs=($(ops::common::splitArgs "${args[@]}"))


  local args=("$@")
  local n_args=${#args[@]}
  unset i

  # loop through all arguments
  #for arg in "${args[@]}"; do
  for (( i = 0 ; i < ${#args[@]} ; i++ )); do
    local arg=${args[i]}
    if [[ "$arg" == *"="* ]]; then
      # split argument into two new arguments and add them to the new array
      local key="${arg%%=*}"
      local value="${arg#*=}"
      args[i]="$key"
      args=("${args[@]:0:i+1}" "$value" "${args[@]:i+1}")
      n_args=${args[@]}
    fi
  done

  #clean up
  unset arg
  # return the new array
  echo "${args[@]}"
}
