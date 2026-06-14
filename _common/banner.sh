function ops::common::banner() {
#-- START CHEAT --
#  Function: ops::common::banner
#    Alias: ops-banner
#    Description: Display the opscli ASCII art banner
#    Parameters:
#-- END CHEAT --
    echo -e "${yellow:-}"
    cat <<- 'EOF'

__________          __  .__                           .__        ___.    
\______   \________/  |_|  |___  _________  ______    |  | _____ \_ |__  
 |    |  _/\_  __ \   __\  |\  \/ /\_  __ \/  ___/    |  | \__  \ | __ \ 
 |    |   \ |  | \/|  | |  |_\   /  |  | \/\___ \     |  |__/ __ \| \_\ \
 |______  / |__|   |__| |____/\_/   |__|  /____  > /\ |____(____  /___  /
        \/                                     \/  \/           \/    \/       

EOF
    echo -e "${clr_reset:-}"
}

alias ops-banner='ops::common::banner'