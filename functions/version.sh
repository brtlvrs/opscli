#!/bin/bash

function ops::version::isSupported() {
#-- START CHEAT --
#  Function: ops::version::isSupported
#    Alias:  
#    Description: Validate if product version is supported
#    Parameters:
#      -h | --help             Show help message
#      -s | --silent           Silent mode, no output only return code
#      $1 | -v | --version     minimum version to check against
#    Returns:
#      0 if version is supported
#      1 if version is not supported

#-- END CHEAT --

    function ops::version::isSupported::_guardrails() {
        # place guardrail code here
        return 0
    }

    function ops::version::isSupported::_usage() {
        cat <<-EOF

        Function too be used in guardrails to check if current product version of opscli is supported.
        Usage: ops::version::isSupported [options]

        Options:
          -h, --help               Show this help message and exit
          -v, --version <version>  The minimum version to check against
          -s, --silent             Silent mode, no output only return code

        Arguments: (when not using options)
          $1     minimum version to check against

EOF
    }

  function ops::version::isSupported::_process-arguments() {

    # process script arguments
    local arguments=($(ops::common::splitArgs "$@"))
    unset MINVERSION
    unset SILENT
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
              ops::version::isSupported::_usage
              return 1 # exit parent function with return 0
              ;;
          -v | --version)
              MINVERSION=${next_arg}
              i=$((i + 1)) # skip next argument as we already processed it
              ;;
          -s | --silent)
              # silent mode, do nothing
              SILENT=true
              ;;
          -*) 
              # unknown option
              writeWRN "Unknown option ${arguments[i]}"
              ops::version::isSupported::_usage
              return 2 # exit parent function with return 1
              ;;
          *)
              if echo "$arg" | grep -Pqe '^v[0-9]+.[0-9]+.[0-9]+$'; then
                # positional argument is version
                MINVERSION=${arguments[i]}
                continue
              fi
              ops::version::isSupported::_usage
              return 2 # exit parent function with return 1
              ;;
      esac
    done
  }


    function ops::version::isSupported::_versionCheck() {
        # main code here
        if [[ "$(ops::info::get env)" == "dev" ]]; then
            [[ -v SILENT ]] || writeINF "Development version detected, skipping version check."
            return 0
        fi
        local actVersion=$(ops::info::get version)
        local minVersion="$1"
        actVersion="${actVersion#v}"
        minVersion="${MINVERSION#v}"

        IFS="." read -r -a actVerParts <<< "$actVersion"
        IFS="." read -r -a minVerParts <<< "$minVersion"

        local minLength=${#minVerParts[@]}
        local actLength=${#actVerParts[@]}
        local maxLength=$(( minLength < actLength ? minLength : actLength ))
        for (( i=0; i<maxLength; i++ )); do
            local actPart=${actVerParts[i]:-0}
            local minPart=${minVerParts[i]:-0}
            if [[ $i == 0 ]]; then
                # Major version must match exactly
              if (( actPart > minPart )); then
                  [[ -v SILENT ]] || writeINF "Current version v${actVersion} is supported, beware of breaking changes in major version change."
                  return 0 # version is supported
              fi
              if (( actPart < minPart )); then
                  [[ -v SILENT ]] || writeERR "Current version v${actVersion} is not supported. Major version must be v${minVersion}."
                  return 1 # version is not supported
              fi 
              # major versions match, continue to next part
              continue # proceed to next part
            fi
            if (( actPart < minPart )); then
                [[ -v SILENT ]] || writeERR "Current version v${actVersion} is not supported. Minimum required version is v${minVersion}."
                return 1
            fi
            if (( actPart > minPart )); then
                [[ -v SILENT ]] || writeINF "Current version v${actVersion} is supported."
                return 0
            fi
            # if we reach here, parts are equal, continue to next part
        done
            [[ -v SILENT ]] || writeINF "Current version v${actVersion} is supported."
            return 0
    }

    #-- main function code starts here --
    [[ $0 == bash && $0 == -bash ]] && ops::common::banner
    ops::version::isSupported::_guardrails "$@" || return $?
    ops::version::isSupported::_process-arguments "$@" || return $?
    ops::version::isSupported::_versionCheck "${minVersion}"
    return $?
}

