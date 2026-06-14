#! /bin/bash

## functions

  function _process-arguments() {
    # unset variables
    unset minVersion

    # process script arguments
    source $OPSCLI_PATH/_common/splitArgs.sh
    local arguments=($(ops::common::splitArgs "$@"))

    # now process all arguments
    for (( i = 0; i < ${#arguments[@]}; i++)); do
				local arg=${arguments[i]}
				local next_arg=""
				if (( i + 1 < ${#arguments[@]} )); then
						next_arg=${arguments[i + 1]}
				fi
        case $arg in
            -h | --help)
                # show help message
                _usage
                return 0 # exit parent function with return 0
                ;;
            -f | --force)
                unset ${stopBlock}
                ;;
            -v| --version)
                minVersion=${next_arg}
                ((i++)) # skip next argument
                ;;
            *)
                # unknown option
                writeWRN "Unknown option ${arguments[i]}"

                return 2 # exit parent function with return 1
                ;;
        esac
    done
  }


### MAIN code ###
# define colors
clr_reset="\033[0m"
cyan="\033[96m"
yellow="\033[93m"
green="\033[92m"
red="\033[91m"
magenta="\033[95m"
blue="\033[94m"
grey="\033[90m"
blackOnGreen="\033[30;42m"
blackOnRed="\033[30;41m"

# export location of this library and create stopblock name

OPSCLI_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")"&& pwd)"
stopBlock="$(basename $OPSCLI_PATH)"
stopBlock="${stopBlock%.dev}_loaded" # remove .dev suffix if present
stopBlock="${stopBlock//[.]/_}" # remove dashes
stopBlock=${stopBlock^^} # all uppercase
export OPSCLI_PATH="$OPSCLI_PATH"

_process-arguments "$@" || return 10

# set alias for reloading this library
#-- START CHEAT --
#  Function: 
#    Alias:  ops-reload
#    Description: Reload the opscli library under $OPSCLI_PATH
#    Parameters:
#-- END CHEAT --
alias ops-reload="unset ${stopBlock} && source ${OPSCLI_PATH}/library.sh"

# Detect stopblock
if [ -v "${stopBlock}" ]; then
  # Loop detected !!! library has already been sourced, so exit here
  if [[ ${BASH_SOURCE[0]} != "${0}" ]]; then return 0; else exit 0;fi
fi

# cleanup library functions before loading them (again)
for func in $(compgen -A function); do
	if [[ $func == ops::* || $func == write* || $func == log* ]]; then
			# skip functions currently on the call stack: unsetting a function
			# while it is executing and redefining it in the same source call
			# causes bash to silently drop the redefinition on return
			[[ " ${FUNCNAME[*]} " == *" $func "* ]] && continue
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

# Load user extensions if OPSCLI_EXTENSIONS_PATH is set
if [[ -n "${OPSCLI_EXTENSIONS_PATH:-}" && -d "${OPSCLI_EXTENSIONS_PATH}" ]]; then
  ops::common::sourceFolder "$OPSCLI_EXTENSIONS_PATH"
fi
if [[ -n "${minVersion+x}" ]]; then
  # check if current version is supported
  ops::version::isSupported -v "$minVersion" || {
    writeERR "Current version $(ops::info::get version) is not supported, please upgrade to at least version $minVersion"
    $exitErr_cmd
  }
fi
REPOVERSION="$(ops::info::get version)"

# start building welcome message
welcomeMSG="$(ops::info::get name) library (version ${magenta}$REPOVERSION${clr_reset}) is loaded."
if [[ -n "${OPSCLI_EXTENSIONS_PATH:-}" && -d "${OPSCLI_EXTENSIONS_PATH}" ]]; then
  welcomeMSG="${welcomeMSG} Extensions loaded from ${cyan}${OPSCLI_EXTENSIONS_PATH}${clr_reset}."
fi

# Detect if we are running in a Concourse Task
# if so, setup the BASH environment for the target foundation if ENV_TARGET is set
if [[ -v ATC_EXTERNAL_URL ]]; then
  welcomeMSG="$welcomeMSG\n\n${cyan}Concourse ATC${clr_reset} environment variable detected, we are running in a Concourse Task !!"
fi

# Detect if we are running in a dev folder and add warning to welcome message
rm "$HOME/.$(ops::info::get name).dev" > /dev/null 2>&1
if [[ "$OPSCLI_PATH" =~ .dev$ ]]; then
  welcomeMSG="${welcomeMSG}
  
  ${yellow}WARNING:${clr_reset} Running from a development folder $OPSCLI_PATH
  To switch to production run '${yellow}ops-prod${clr_reset}'"
  touch $HOME/.$(ops::info::get name).dev
fi

# Detect if we are sourced from an interactive BASH shell and add some hints to welcome message
if [[ $0 == bash || $0 == -bash || $0  == */bash ]]; then
  welcomeMSG="${welcomeMSG}

To ${cyan}reload${clr_reset} this library run '${yellow}ops-reload${clr_reset}'
To see which ${cyan}functions${clr_reset} are available and how they work use '${yellow}ops-functions${clr_reset}'
To see which ${cyan}aliases${clr_reset} are made available run '${yellow}ops-alias${clr_reset}'
For general ${cyan}info${clr_reset} about the library run '${yellow}ops-info${clr_reset}'"
  writeDBG "Sourced from an interactive BASH shell"
fi
# display welcome message
writeINF "$welcomeMSG"


if [[ $0 != bash ]] && [[ $0 != -bash ]] && [[ $0  != */bash ]]; then
  # we are sourced from a script
  writeDBG "Sourced from script: $(realpath $0)"
  return 0
fi

writeOK "Succesfully sourced the $(ops::info::get name) library (version ${magenta}$REPOVERSION${clr_reset})"
