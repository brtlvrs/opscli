#!/bin/bash
# Initialize BASH environment 
# when library.sh is called the code below is executed


# the cleanup function will do a rm -rf on all the subfolders starting with this PID
#-- START CHEAT --
#  Function:
#    Alias: shellTMPdir
#    Description: Create a hidden temp folder under $HOME prefixed with the current user id; cleaned up automatically on exit
#    Parameters:
#-- END CHEAT --
alias shellTMPdir='mktemp -d -p $HOME .$(id -u).XXXXX'
#-- START CHEAT --
#  Function:
#    Alias: shellTMP
#    Description: Create a temp file inside a shellTMPdir folder; cleaned up automatically on exit
#    Parameters:
#-- END CHEAT --
alias shellTMP='mktemp -p $(shellTMPdir)'

#-- START CHEAT --
#  Function:
#    Alias: ops-dev
#    Description: Switch the active library to the development clone (opscli.dev) and reload
#    Parameters:
#-- END CHEAT --
  alias ops-dev="unset ${stopBlock} && source \$(ops::info::get dev_path)/library.sh"
#-- START CHEAT --
#  Function:
#    Alias: ops-prod
#    Description: Switch the active library to the production clone and reload
#    Parameters:
#-- END CHEAT --
  alias ops-prod="unset ${stopBlock} && source \$(ops::info::get prod_path)/library.sh"
unset stopBlock