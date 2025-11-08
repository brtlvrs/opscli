#!/bin/bash

function ops::console::write() {
#-- START CHEAT --
#  Function: ops::console::write
#    Alias:  
#    Description: Write custom message with preformatted headers
#    Parameters:
#          $1  : message level, INFO, DEBUG, WARNING. ERROR, OK, FAIL, TODO
#          $2  | custom message
#-- END CHEAT --
  local xtrace_was_on=$([[ $- == *x* ]] && echo true || echo false)  
  local level=$1
  local msg=$2
  local clr="\033[0m"
  local clr_reset="\033[0m"
  # handle log level
  case $level in
    info|INFO|Info|INF|inf)
      clr="\033[96m" # cyan
      LEVEL="INFO" 
    ;;
    warning|WARNING|Warning|WARN|warn|WRN|wrn)
      clr="\033[93m" # yellow
      LEVEL="WARNING (line ${BASH_LINENO[1]} in ${BASH_SOURCE[2]})" 
    ;;
    error|ERROR|Error|Err|err|ERR)
      clr="\033[91m"
      LEVEL="ERROR  (line ${BASH_LINENO[1]} in ${BASH_SOURCE[2]})" 
    ;;
    debug|DEBUG|Debug|DBG|dbg|Dbg)
      clr="\033[90m"
      LEVEL="DEBUG" 
      if [[ -z debug || $debug != "true" ]]; then
        # we don't want to know debug level
        return 0
      fi
    ;;
    fail|FAIL|false|FALSE|False|Fail)
      clr="\033[41m"
      LEVEL="FAIL" 
    ;;
    true|TRUE|True|OK|Ok|ok)
      clr="\033[42m"
      LEVEL="OK"
    ;;
    todo|TODO|Todo)
      clr="\033[93m"
      LEVEL="TODO at line ${BASH_LINENO[1]} in ${FUNCNAME[2]} in ${BASH_SOURCE[2]}"
      msg="TODO: $msg"
    ;;
    *)
      ops::console::write "error" "Unknown log level $level for msg: $msg"
    ;;
  esac

  # build log message
  local message=$2
  # format the firstline with a date and time stamp, level information and have it a consitent length of 40 characters
  local firstLine="[`date '+%F %H:%M:%S %z'`] $LEVEL "
  local dash_length=$((60 - ${#firstLine}))
  local dashes=$(printf "%*s" $dash_length | tr ' ' '-') # dashes to add as postfix
  firstLine="${firstLine}${dashes}"
  # make the last line as long as the first line, only dashes
  local lastLine=$(printf "%*s"  ${#firstLine} | tr ' ' '-')


  if [[ "$LEVEL" =~ (FAIL|OK) ]];  then
    lastLine=$firstLine
    unset firstLine
  fi
  echo -e "\n${clr}${firstLine}${clr_reset}\n\n${message}\n\n${clr}$lastLine${clr_reset}" >&2
  $xtrace_was_on && set -x
}

writeINF() {
#-- START CHEAT --
#  Function: writeINFO
#    Alias:  
#    Description: Display INFO header with custom message
#    Parameters:
#           $1 :  message
#-- END CHEAT --
  ops::console::write "info" "$1"
}
writeERR() {
#-- START CHEAT --
#  Function: writeERR
#    Alias:  
#    Description: Display ERROR header with custom message
#    Parameters:
#           $1 :  message
#-- END CHEAT --
  ops::console::write "error" "$1"
}
writeDBG() {
#-- START CHEAT --
#  Function: writeDBG
#    Alias:  
#    Description: When debug  variable is present, display DEBUG message with custom header
#    Parameters:
#           $1 :  message
#-- END CHEAT --
  ops::console::write "debug" "$1"
}
writeWRN() {
#-- START CHEAT --
#  Function: writeWRN
#    Alias: 
#    Description: Display WARNING header with custom message
#    Parameters:
#           $1 :  message
#-- END CHEAT --
  ops::console::write "warning" "$1"
}
writeOK() {
#-- START CHEAT --
#  Function: writeOK
#    Alias:  
#    Description: Display OK header with custom message. Usefull for validation / healthcheck tasks
#    Parameters:
#           $1 :  message
#-- END CHEAT --
  ops::console::write "ok" "$1"
}
writeFAIL() {
#-- START CHEAT --
#  Function: writeFAIL
#    Alias:  
#    Description: Displaying FAIL with custom message. Usefull for validation / healthcheck tasks
#    Parameters:
#           $1 :  message
#-- END CHEAT --
  ops::console::write "fail" "$1"
}
writeTODO() {
#-- START CHEAT --
#  Function: writeTODO
#    Alias:  
#    Description: Displaying TODO with file, functionname and linenr where this function is called.
#    Parameters:
#           $1 :  message
#-- END CHEAT --
  ops::console::write "todo" "$1"
}
