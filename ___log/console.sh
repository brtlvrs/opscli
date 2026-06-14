#!/bin/bash

function ops::console::write() {
#-- START CHEAT --
#  Function: ops::console::write
#    Alias:
#    Internal: true
#    Description: Write custom message with preformatted headers to stderr
#    Parameters:
#          $1  : message level, INFO, DEBUG, WARNING. ERROR, OK, FAIL, TODO
#          $2  | custom message
#-- END CHEAT --
  # save current xtrace state
  local xtrace_was_on=$([[ $- == *x* ]] && echo true || echo false) 
  # disable xtrace for this function
  set +x 

  local level=$1
  local message=$2

  # set maximum header length
  local maxHeaderLength=60
  # define colors
  local clr="\033[0m"
  local clr_reset="\033[0m"
  local cyan="\033[96m"
  local yellow="\033[93m"
  local green="\033[92m"
  local red="\033[91m"
  local magenta="\033[95m"
  local blue="\033[94m"
  local grey="\033[90m"
  local whiteOnBlue="\033[97;44m"
  local whiteOnGreen="\033[97;42m"
  local whiteOnRed="\033[97;41m"
  local blackOnGreen="\033[30;42m"
  local blackOnRed="\033[30;41m"

  # handle log level
  case $level in
    info|INFO|Info|INF|inf)
      clr="${cyan}" # cyan
      LEVEL="INFO" 
    ;;
    warning|WARNING|Warning|WARN|warn|WRN|wrn)
      clr="${yellow}" # yellow
      LEVEL="WARNING (line ${BASH_LINENO[1]} in ${BASH_SOURCE[2]})" 
    ;;
    error|ERROR|Error|Err|err|ERR)
      clr="${red}" # red
      LEVEL="ERROR  (line ${BASH_LINENO[1]} in ${BASH_SOURCE[2]})" 
    ;;
    debug|DEBUG|Debug|DBG|dbg|Dbg)
      clr="${yellow}"
      LEVEL="DEBUG"
      if [[ ! -v debug && ! -v DEBUG ]]; then
        # we don't want to know debug level
        return 0
      fi
    ;;
    note|NOTE)
      clr="${grey}"
      LEVEL="NOTE"
    ;;
    fail|FAIL|false|FALSE|False|Fail)
      clr="$blackOnRed"
      clr="${red}"
      LEVEL="FAIL" 
    ;;
    true|TRUE|True|OK|Ok|ok)
      clr="$blackOnGreen"
      clr="${green}"
      LEVEL="OK"
    ;;
    todo|TODO|Todo)
      clr="${yellow}"
      LEVEL="TODO at line ${BASH_LINENO[1]} in ${FUNCNAME[2]} in ${BASH_SOURCE[2]}"
      message="TODO: $message"
    ;;
    *)
      ops::console::write "error" "Unknown log level $level for msg: $msg"
      return 1
    ;;
  esac

  # format the firstline with a date and time stamp, level information and have it a consitent length of 40 characters
  local timeStamp="[`date '+%F %H:%M:%S %z'`] ${LEVEL}"
  local dash_length=$(($maxHeaderLength - ${#timeStamp}))
  local dashes=$(printf "%*s" $dash_length | tr ' ' '-') # dashes to add as postfix
  firstLine="\n${clr}${timeStamp}${dashes}${clr_reset}\n"
  # make the last line as long as the first line, only dashes
  local lastLine=$(printf "%*s"  ${#firstLine} | tr ' ' '-')
  lastLine="\n${lastLine}"
  # for Level FAIL and OK, replace the lastLine with firstLine and clear firstLine
  # for Level INFO and DEBUG don't print lastLine header
  if [[ "$LEVEL" =~ (INFO|DEBUG) ]]; then
    unset lastLine
  fi
  local printedMSG="${firstLine}\n${message}${clr}${lastLine}${clr_reset}"
  if [[ "$LEVEL" =~ (FAIL|OK|NOTE|INFO|DEBUG) ]];  then
      local final_msg="${clr_reset}${message}"
      if [[ "$LEVEL" =~ (NOTE) ]]; then
        local final_msg="${message}${clr_reset}"
      fi
    local printedMSG="\n${clr}[`date '+%F %H:%M:%S %z'`] ${clr}${level} ${final_msg}"
  fi
  # print formatted message
  echo -e "${printedMSG}" >&2
  # set xtrace to state before this function was called
  $xtrace_was_on && set -x
  return 0
}

writeINF() {
#-- START CHEAT --
#  Function: writeINF
#    Alias:
#    Description: Display single-line INFO message to stderr in cyan
#    Parameters:
#           $1 :  message
#-- END CHEAT --
  ops::console::write "info" "${cyan}→${clr_reset} $1"
}
writeERR() {
#-- START CHEAT --
#  Function: writeERR
#    Alias:
#    Description: Display ERROR header with custom message to stderr; includes source file and line number
#    Parameters:
#           $1 :  message
#-- END CHEAT --
  ops::console::write "error" "$1"
}
writeDBG() {
#-- START CHEAT --
#  Function: writeDBG
#    Alias:
#    Description: Display DEBUG message to stderr; yellow timestamp header, uncoloured message, yellow call location on last line; only printed when $DEBUG or $debug is set
#    Parameters:
#           $1 :  message
#-- END CHEAT --
  local _location="${yellow}(line ${BASH_LINENO[0]} in ${FUNCNAME[1]} in ${BASH_SOURCE[1]})${clr_reset}"
  ops::console::write "debug" "$1\n${_location}"
}
writeWRN() {
#-- START CHEAT --
#  Function: writeWRN
#    Alias:
#    Description: Display WARNING header with custom message to stderr; includes source file and line number
#    Parameters:
#           $1 :  message
#-- END CHEAT --
  ops::console::write "warning" "$1"
}
writeOK() {
#-- START CHEAT --
#  Function: writeOK
#    Alias:
#    Description: Display single-line OK result to stderr; use for pass/success outcomes in validation or healthcheck scripts
#    Parameters:
#           $1 :  message
#-- END CHEAT --
  ops::console::write "ok" "${green}✓${clr_reset} $1"
}
writeFAIL() {
#-- START CHEAT --
#  Function: writeFAIL
#    Alias:
#    Description: Display single-line FAIL result to stderr; use for fail/error outcomes in validation or healthcheck scripts
#    Parameters:
#           $1 :  message
#-- END CHEAT --
  ops::console::write "fail" "${red}✗${clr_reset} $1"
}
writeNOTE() {
#-- START CHEAT --
#  Function: writeNOTE
#    Alias:
#    Description: Display single-line NOTE annotation to stderr; use for subtle context messages that don't need the full INFO header
#    Parameters:
#           $1 :  message
#-- END CHEAT --
  ops::console::write "note" "$1"
}
writeTODO() {
#-- START CHEAT --
#  Function: writeTODO
#    Alias:
#    Description: Display TODO marker to stderr with function name, file and line number; use during development to flag incomplete code
#    Parameters:
#           $1 :  message
#-- END CHEAT --
  ops::console::write "todo" "$1"
}
