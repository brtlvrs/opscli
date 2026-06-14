function ops::http::test_connection() {
#-- START CHEAT --
#  Function: ops::http::test_connection
#    Alias:
#    Description: Test if a URL is reachable; prints the HTTP status code or exits cleanly
#    Parameters:
#      -u | --url    URL to test (http:// or https://)
#      -q | --quit   Suppress status code output; only return exit code
#      -k            Skip SSL certificate validation
#      -h | --help   Show help
#-- END CHEAT --
  
   function ops::http::test_connection::_usage() {
    cat <<- EOF

    Test whether a URL is reachable by making an HTTP request and returning
    the HTTP status code. Exits 0 on a response, 1 on connection failure.

    Usage: ops::http::test_connection [options] <url>

    Options:
    -u | --url      URL to test (http:// or https://); can also be passed as positional arg
    -q | --quit     Suppress status code output; only return exit code
    -k              Skip SSL certificate validation
    -h | --help     Display this message

EOF
  }

  ops::http::test_connection::_guardrails() {

    if [[ "$url" != http://* && "$url" != https://* ]]; then
      writeWRN "url is not a valid http/https URL"
      return 1
    fi
}

  ops::http::test_connection::_process-arguments() {

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
              ops::http::test_connection::_usage
              return 0
              ;;
            -u | --url)
              url="$next_arg"
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
                ops::http::test_connection::_usage
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
  unset quit
  ops::http::test_connection::_process-arguments "$@" || return $?
  ops::http::test_connection::_guardrails "$@" || return $?
  local http_code
  http_code="$(curl --max-time 5 ${skip_ssl:-} -s -o /dev/null -w  "%{http_code}" "${url}")"
  if [ $? -ne 0 ]; then
    writeWRN "Failed to run curl against ${url}"
    return 1
  # Echo result
  else
  [ -z "${quit:-}" ] && echo "${http_code}"
  # check if we have the expected http response
    return 0
  fi
}
