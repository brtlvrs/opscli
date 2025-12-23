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
stopBlock="$(basename $OPSCLI_PATH)"
stopBlock="${stopBlock%.dev}_loaded" # remove .dev suffix if present
stopBlock="${stopBlock//[.]/_}" # remove dashes
stopBlock=${stopBlock^^} # all uppercase
export OPSCLI_PATH="$OPSCLI_PATH"
# set alias for reloading this library
#-- START CHEAT --
#  Function: 
#    Alias:  ops-reload
#    Description: Reload the opscli library under $OPSCLI_PATH
#    Parameters:
#-- END CHEAT --
if [[ "$1" == "-f" || "$1" == "--force" ]]; then
  # force reload even if already loaded
  unset ${stopBlock}
fi
alias ops-reload="unset ${stopBlock} && source ${OPSCLI_PATH}/library.sh"

# Detect stopblock
if [ -v "${stopBlock}" ]; then
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
REPOVERSION="$(ops::info::get version)"
welcomeMSG="$(ops::info::get name) library (version ${magenta}$REPOVERSION${clr_reset}) is loaded."

# Detect if we are running in a Concourse Task
# if so, setup the BASH environment for the target foundation if ENV_TARGET is set
if [[ -v ATC_EXTERNAL_URL ]]; then
  welcomeMSG="$welcomeMSG\n\n${cyan}Concourse ATC${clr_reset} environment variable detected, we are running in a Concourse Task !!"
fi

rm "$HOME/.$(ops::info::get name).dev" > /dev/null 2>&1
if [[ "$OPSCLI_PATH" =~ .dev$ ]]; then
  welcomeMSG="${welcomeMSG}
  
  ${yellow}WARNING:${clr_reset} Running from a development folder $OPSCLI_PATH
  To switch to production run '${yellow}ops-prod${clr_reset}'"
  touch $HOME/.$(ops::info::get name).dev
fi

if [[ $0 == bash || $0 == -bash || $0  == */bash ]]; then
  welcomeMSG="${welcomeMSG}

To ${cyan}reload${clr_reset} this library run '${yellow}ops-reload${clr_reset}'
To see which ${cyan}functions${clr_reset} are available and how they work use '${yellow}ops-functions${clr_reset}'
To see which ${cyan}aliases${clr_reset} are made available run '${yellow}ops-alias${clr_reset}'
For general ${cyan}info${clr_reset} about the library run '${yellow}ops-info${clr_reset}'"
  writeDBG "Sourced from an interactive BASH shell"
fi
writeINF "$welcomeMSG"

if [[ $0 != BASH ]] && [[ $0 != -bash ]] && [[ $0  != */bash ]]; then
  # we are sourced from a script
  writeDBG "Sourced from script: $(realpath $0)"
  return 0
fi

writeOK "Succesfully sourced the $(ops::info::get name) library (version ${magenta}$REPOVERSION${clr_reset})"
