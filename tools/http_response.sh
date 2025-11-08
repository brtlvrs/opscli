function ops::http::status_code() {
  
  ops::http::status_code::_usage() {
    cat <<- EOF

    
    command options:

    -u | --url      url to check status code for
    -s | --status   (optional) regexp pattern to check HTTP status for, default is all 200 and 300 codes ^(2|3)[0-9][0-9]
    -q | --quit     Don't return status code, only succeed or fail
    -k              skip ssl validation
    -h | --help     Display this message

EOF
  }

  ops::http::status_code::_guardrails() {

    if [[ "$url" != http://* && "$url" != https://* ]]; then
      writeWRN "url is not a valid http/https URL"
      return 1
    fi
}

  ops::http::status_code::_process-arguments() {

      writeDBG "${FUNCNAME[0]}"
      # proces script arguments
      # split arguments
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
              ops::http::status_code::_usage
              return 0
              ;;
            -u | --url)
              url="$next_arg"
              ((i++))
              ;;
            -s | --status)
              status="$next_arg"
              ((i++))
              ;;
            -q | --quit)
              quit=true
              ;;
            -k)
              skip_ssl="-k"
              ;;
            *)
              # check if we have the last argument or not ?
              if [[ $i -ne  $((${#arguments[@]} - 1))  ]]; then
                writeWRN "Unknown option ${arg}, exiting script."
                ops::http::status_code::_usage
                return 1
              fi
              # argument is the last one, assuming it is the search pattern
              url="$arg"
							;;
          esac
          true # making sure $? = 0, $? =1 when i= 0 and you do ((i++))
      done
      return 0
  }

#===== MAIN
  local status='^(2|3)[0-9][0-9]'
  unset quit
  ops::http::status_code::_process-arguments "$@"  || return $?
  ops::http::status_code::_guardrails "$@" || return $?
  local http_code="$(curl --max-time 5 ${skip_ssl} -s -o /dev/null -w  "%{http_code}" "${url}")"
  if [ $? -ne 0 ]; then
    writeWRN "Failed to run curl against ${url}"
    return 1
  fi
  # Echo result
  [ -z "$quit" ] && echo "${http_code}"
  # check if we have the expected http response
  if [[ "${http_code}" =~ ${status} ]]; then
    return 0
  else
    return 1
  fi

}
