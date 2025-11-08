#!/bin/bash
# handle traps for cleanup on exit, CTRL-C and errors
# handle PROMPT_COMMAND to reset DEBUG and trap variables before each prompt
# is called when library.sh is sourced

# function to be called by trap on CTRL-C or error codes
function ops::trap::cleanupTMP() {
#-- START CHEAT --
#  Function: ops::trap::cleanupTMP
#    Alias: 
#    Description: a cleanup function that removes temporary folders created by shellTMPdir and shellTMP
#    Usage:
#    Parameters:
#-- END CHEAT --  
  if [[ -v DEBUG ]]; then
    echo "DEBUG is set, not cleaning up subfolders starting with .$$ under $HOME"
    return 0
  fi
  rm -rf "$HOME/.$$.**"
}

function ops::trap::Exit() {
#-- START CHEAT --
#  Function: ops::trap::Exit
#    Alias: 
#    Description: a function to be called on script exit
#    Usage:
#    Parameters:
#-- END CHEAT --  
  ops::trap::cleanupTMP
}
function ops::trap::CTRLC() {
#-- START CHEAT --
#  Function: ops::trap::CTRLC
#    Alias:
#    Description: a function to be called on CTRLC or error
#    Usage:
#    Parameters:
#-- END CHEAT --  
  # avoid multiple executions

  if [[ $trapCTRLC_ran -gt 0 ]]; then
    return
  fi
  export trapCTRLC_ran=1
  # perform cleanup
  ops::trap::cleanupTMP
  writeWRN "Script interrupted by user (CTRLC) or error $? occurred."
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        exit 1
    else
        return 1
    fi
}

function ops::common::appendPromptCommand() {
#-- START CHEAT --
#  Function: ops::common::appendPromptCommand
#    Alias: 
#    Description: appends extra commands to PROMPT_COMMAND to reset set -x and trapCTRLC_ran before each prompt
#    Usage:
#    Parameters:
#-- END CHEAT -- 
  local err=$?   
  set +x
  trapCTRLC_ran=0
return $err
}

# set trap(s)
export trapCTRLC_ran=1
trap - EXIT INT ERR
trap ops::trap::Exit EXIT
trap ops::trap::CTRLC INT

# Check if PROMPT_COMMAND already contains the commands (naive substring check)
if [[ "$PROMPT_COMMAND" != *"ops::common::appendPromptCommand"* ]]; then
  # Append with semicolon separator if PROMPT_COMMAND is non-empty, else just assign
  if [[ -n "$PROMPT_COMMAND" ]]; then
    PROMPT_COMMAND="ops::common::appendPromptCommand; ${PROMPT_COMMAND}"
  else
    PROMPT_COMMAND="ops::common::appendPromptCommand"
  fi
fi
export PROMPT_COMMAND

