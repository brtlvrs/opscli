#!/bin/bash
# Initialize BASH environment 
# when library.sh is called the code below is executed


# the cleanup function will do a rm -rf on all the subfolders starting with this PID
#-- START CHEAT --
#  Function: 
#    Alias: shellTMPdir
#    Description: Creates a hidden temp folder under your $HOME folder prefixed with the user id
#    Usage:
#    Parameters:
#-- END CHEAT --
alias shellTMPdir='mktemp -d -p $HOME .$(id -u).XXXXX'
#-- START CHEAT --
#  Function: 
#    Alias: shellTMP
#    Description: Create a tempfile under a hidden tempfolder in $HOME
#    Usage:
#    Parameters:
#-- END CHEAT --
alias shellTMP='mktemp -p $(shellTMPdir)'

# set stopblock variable name
stopBlock="$((basename $OPSCLI_PATH))_loaded"
stopBlock="${stopBlock//[.]/_}" # remove dashes
stopBlock=${stopBlock^^} # all uppercase
#-- START CHEAT --
#  Function: 
#    Alias: ops-dev
#    Description: reload opscli from development path
#    Usage:
#    Parameters:
#-- END CHEAT --
  alias ops-dev='unset ${stopBlock};source $(ops::info::get dev_path)/library.sh'
#-- START CHEAT --
#  Function: 
#    Alias: ops-prod
#    Description: reload opscli from production path
#    Usage:
#    Parameters:
#-- END CHEAT --
  alias ops-prod='unset ${stopBlock};source $(ops::info::get prod_path)/library.sh'
unset stopBlock