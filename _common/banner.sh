function ops::common::banner() {
#-- START CHEAT --
#  Function: ops::common::banner
#    Alias: 
#    Description: Display a banner with the provided text
#    Usage:
#    Parameters:
#      $1 : Text to display in banner
#-- END CHEAT --
    echo -e "${yellow}" 
    cat <<- 'EOF'

__________          __  .__                           .__        ___.    
\______   \________/  |_|  |___  _________  ______    |  | _____ \_ |__  
 |    |  _/\_  __ \   __\  |\  \/ /\_  __ \/  ___/    |  | \__  \ | __ \ 
 |    |   \ |  | \/|  | |  |_\   /  |  | \/\___ \     |  |__/ __ \| \_\ \
 |______  / |__|   |__| |____/\_/   |__|  /____  > /\ |____(____  /___  /
        \/                                     \/  \/           \/    \/       

EOF
    echo -e "${clr_reset}"      
}

alias ops-banner='ops::common::banner'