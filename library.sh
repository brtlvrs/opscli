#! /bin/bash

### MAIN code ###
# define colors
clr_reset="\033[0m"
cyan="\033[96m"
yellow="\033[93m"
green="\033[92m"
red="\033[91m"
magenta="\033[95m"
blue="\033[94m"

# export location of this library and create stopblock name
OPSCLI_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")"&& pwd)"
libname="$(basename $OPSCLI_PATH)"
stopBlock="$(basename $OPSCLI_PATH)_lib"
stopBlock="${stopBlock//[-]/_}" # remove dashes
stopBlock=${stopBlock^^} # all uppercase
export OPSCLI_PATH="$OPSCLI_PATH"

# set alias for reloading this library
#-- START CHEAT --
#  Function: 
#    Alias:  ops-reload
#    Description: Reload the opscli library under $OPSCLI_PATH
#    Parameters:
#-- END CHEAT --
alias ops-reload="unset ${stopBlock} && source ${OPSCLI_PATH}/library.sh"

# Detect stopblock
if [ -v "$stopBlock" ]; then
  # Loop detected !!! library has already been sourced, so exit here
  if [[ ${BASH_SOURCE[0]} != "${0}" ]]; then return 0; else exit 0;fi
fi

# cleanup library functions before loading them (again)
for func in $(compgen -A function); do
	if [[ $func == ops::* || $func == write* || $func == log* ]]; then
			# removing all functions starting with ops:: write or log
			unset -f "$func"
	fi
done

# set stopblock
eval "$stopBlock"="true"
export $stopBlock # mark that the library has been loaded

# create helper to determine how to exit
# detect if we are sourced or running directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  exitErr_cmd="exit 1"
  echo -e "\nWe don't want to be run library.sh directly, please source it from your .bashrc or run ops-reload\n"
  exit 0
else
  exitErr_cmd="return 1"
fi

# load function(s) that we need in this script
source $OPSCLI_PATH/_common/sourceFolder.sh
# load the opscli library by sourcing all bash (.sh) files in the subfolders.
#   from this point on all opscli functions are available and can be used
ops::common::sourceFolder "$OPSCLI_PATH" || exit_with_error=true
[[ -n ${exit_with_error+x} ]] && $exitErr_cmd

if [[ $0 == bash || $0 == -bash ]]; then
  # we are sourced from an interactive shell
  writeDBG "
  Sourced from interactive shell"
else
  # we are sourced from a script
  writeINF "Sourced from script: $0"
  # let's exit here to avoid running code below when sourced from a script
  return 0
fi

# Detect if we are running in a Concourse Task
# if so, setup the BASH environment for the target foundation if ENV_TARGET is set
if [[ -v ATC_EXTERNAL_URL ]]; then
  writeINF "
  ${cyan}Concourse ATC${clr_reset} environment variable detected, we are running in a Concourse Task !!
  $(ops::info::get name) function library ( version: \e[0;35m$(ops::info::get version)\e[0m ) is loaded."
  if prereqVar ENV_TARGET; then
    # so we are running in a concourse task, let's also setup the BASH environment."
    ops::foundation::selector $ENV_TARGET
    if [[ $? -ne 0 ]]; then
      writeWRN "Failed to automatically setup BASH environment for $ENV_TARGET"
      $exitErr_cmd
    fi
    writeOK "BASH environment setup for foundation $ENV_TARGET"
  fi
else
  ops::common::banner
  writeINF \
  "
  $(ops::info::get name) library ( version: \e[0;35m$(ops::info::get version)\e[0m ) is loaded.
  
  To ${cyan}reload${clr_reset} this library run '${yellow}ops-reload${clr_reset}'
  To see which ${cyan}functions${clr_reset} are available and how they work use '${yellow}ops-functions${clr_reset}'
  To see which ${cyan}aliases${clr_reset} are made available run '${yellow}ops-alias${clr_reset}'
  For general ${cyan}info${clr_reset} about the library run '${yellow}ops-info${clr_reset}'
  "

fi

# Warn if we are running from a development repo
if  [[ "$OPSCLI_PATH" =~ dev/$libname ]]; then
  # we are running from a dev environment, set the file so .bashrc creates a warning about running with dev
  writeWRN \
  "
  $(ops::info::get name) is running from a development folder $OPSCLI_PATH
  To switch to production run ${yellow}ops-prod${clr_reset}
  "
  touch $HOME/.${libname}.dev # so .bashrc knows which library.sh to source
else
  # we are NOT running from dev environment, so cleanup file
  rm -f $HOME/.${libname}.dev
fi

