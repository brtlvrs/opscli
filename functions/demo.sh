#!/bin/bash

function ops::functions::demo() {
#-- START CHEAT --
#  Function: ops::functions::demo
#    Alias:  ops-demo
#    Description: Demonstrate all write* console logging functions with example output
#    Parameters:
#      -h | --help   Show help
#-- END CHEAT --

  function ops::functions::demo::_usage() {
    cat <<- EOF

    Demonstrate all write* console logging functions available in the opscli library.

    Usage: ops-demo

    Options:
    -h | --help     Display this message

EOF
  }

  local arguments=($(ops::common::splitArgs "$@"))
  for (( i=0; i<${#arguments[@]}; i++ )); do
    case ${arguments[i]} in
      -h|--help) ops::functions::demo::_usage; return 0 ;;
      *) writeWRN "Unknown option ${arguments[i]}"; ops::functions::demo::_usage; return 2 ;;
    esac
  done

  writeINF  "writeINF  — informational message"
  writeOK   "writeOK   — pass or success result"
  writeFAIL "writeFAIL — fail or error result"
  writeNOTE "writeNOTE — subtle annotation or context"
  writeWRN  "writeWRN  — warning with call location"
  writeERR  "writeERR  — hard error with call location"
  writeTODO "writeTODO — marks incomplete code"
  local _prev_debug=${DEBUG:-}
  DEBUG=true
  writeDBG  "writeDBG  — debug message with call location (only shown when DEBUG is set)"
  if [[ -z "$_prev_debug" ]]; then unset DEBUG; else DEBUG="$_prev_debug"; fi
}

alias ops-demo=ops::functions::demo
