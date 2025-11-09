function ops::info::get() {
#-- START CHEAT --
#  Function: ops::info::get
#    Alias:  ops-info
#    Description: Show current opslib parameters
#    Parameters:
#      -a, --all:    Show all available parameters
#      env:          Return the active environment of this library
#      running_repo: Return the path of the currently running repository
#      name:         Return the name of this library
#      prod_path:    Return the production path of this library
#      dev_path:     Return the development path of this library
#      version:      Return the current version of this library
#      git_url:      Return the git url of this library
#-- END CHEAT --
    function ops::info::get::_process-arguments() {
    local arguments=($(ops::common::splitArgs "$@"))
    
    if [[ ${#arguments[@]} -eq 0 ]]; then
        arguments+=("-a")
    fi
    # now process all arguments
    for (( i = 0; i < ${#arguments[@]}; i++)); do

        if [[ "${arguments[i]}" != "name" ]]; then
            local LIBNAME=$(ops::info::get name)
            local LIBPATH_VAR="$(echo "${LIBNAME}_PATH" | tr '[:lower:]' '[:upper:]')"
        fi

        case ${arguments[i]} in
            name)
                # return the name of this library
                echo "opslib"
                ;;
            env)
                # return the active environment of this library
                if grep -q "dev/$LIBNAME" <<<"${!LIBPATH_VAR}"; then
                    echo "dev"
                else
                    echo "prod"
                fi
                ;;
            running_repo)
                echo "${!LIBPATH_VAR}"
                ;;
            prod_path)
                # return the production path of this library
                if grep -q "dev/$LIBNAME" <<<"${!LIBPATH_VAR}"; then
                    # in dev path, no prod path available
                    local prod_path="${!LIBPATH_VAR}"
                    prod_path="${prod_path/dev\/$LIBNAME/$LIBNAME}" # convert to prod path
                    echo "$prod_path"
                    return 0
                fi
                echo "${!LIBPATH_VAR}"
                ;;
            dev_path)
                # return the development path of this library
                if [[ -v ATC_EXTERNAL_URL ]]; then
                    # in ATC environment, no dev path available
                    echo ""
                    return 0
                fi
                if grep -q "dev/$LIBNAME" <<<"${!LIBPATH_VAR}"; then
                    # in dev path, no prod path available
                    echo "${!LIBPATH_VAR}"
                    return 0
                fi
                local dev_path="${!LIBPATH_VAR}"
                dev_path="${dev_path/$LIBNAME/dev\/$LIBNAME}" # convert to dev path
                echo "$dev_path"
                ;;
            prod_version)
                # return the production version of this library
                local PRODVERSION="$(cd $(ops::info::get prod_path); git rev-parse --abbrev-ref HEAD )"
                if [[ "$PRODVERSION" =~ "HEAD" ]]; then
                    PRODVERSION="$(cd $(ops::info::get prod_path); git describe --tags --exact-match 2>/dev/null)"
                fi
                echo "$PRODVERSION"
                ;;
            dev_version)
                # return the production version of this library
                local DEVVERSION="$(cd $(ops::info::get dev_path); git rev-parse --abbrev-ref HEAD )"
                if [[ "$DEVVERSION" =~ "HEAD" ]]; then
                    DEVVERSION="$(cd $(ops::info::get dev_path); git describe --tags --exact-match 2>/dev/null)"
                fi
                echo "$DEVVERSION"
                ;;

            version)
                # return the current version of this library
                local REPOVERSION="$(cd ${!LIBPATH_VAR}; git rev-parse --abbrev-ref HEAD )"
                if [[ "$REPOVERSION" =~ "HEAD" ]]; then
                    REPOVERSION="$(cd ${!LIBPATH_VAR}; git describe --tags --exact-match 2>/dev/null)"
                fi
                echo "$REPOVERSION"
                ;;
            git_url)
                # return the git url of this library
                local GITURL="$(cd ${!LIBPATH_VAR}; git config --get remote.origin.url )"
                echo "$GITURL"
                ;;
            -a|--all)
                local devIsActive=""
                local prodIsActive=""
                if grep -q "dev/$LIBNAME" <<<"${!LIBPATH_VAR}"; then
                    local devIsActive=" (${green}active${clr_reset})"
                else
                    local prodIsActive=" (${green}active${clr_reset})"
                fi
                # return all available parameters
                echo "name: $(ops::info::get name)"
                echo "git_url: $(ops::info::get git_url)"
                echo -e "prod: ${prodIsActive}"
                echo -e "\tpath: $(ops::info::get prod_path)"
                echo -e "\tversion: $(ops::info::get prod_version)"
                echo -e "dev: ${devIsActive}"
                echo -e "\tpath: $(ops::info::get dev_path)"
                echo -e "\tbranch: $(ops::info::get dev_version)"
                ;;
            *)
                # unknown option
                writeWRN "Unknown parameter ${arguments[i]} for ops-info"
                return 2 # exit parent function with return 1
                ;;
        esac
    done
  }


    ops::info::get::_process-arguments "$@"
}
alias ops-info=ops::info::get