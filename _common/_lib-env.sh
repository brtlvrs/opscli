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

#-- START CHEAT --
#  Function: 
#    Alias: ops-dev
#    Description: reload opslib from development path
#    Usage:
#    Parameters:
#-- END CHEAT --
  alias ops-dev="unset OPSLIB_LIB;source $HOME/repos/dev/opslib/library.sh"
#-- START CHEAT --
#  Function: 
#    Alias: ops-prod
#    Description: reload opslib from production path
#    Usage:
#    Parameters:
#-- END CHEAT --
  alias ops-prod="unset OPSLIB_LIB;source $HOME/repos/opslib/library.sh"