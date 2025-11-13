#!/bin/bash

ops::functions::show() {
#-- START CHEAT --
#  Function: ops::functions::show
#    Alias:
#    Description: show cheatsheet for ops-func library
#    Parameters:
#       -f | --full              (default) display each cheatcode block and an alias summary.
#       -h | --help              Display this message
#       --summary                Display only the alias summary.
#       --functions              Display only the functions 
#-- END CHEAT --
#-- START CHEAT --
#  Function: 
#    Alias:  ops-alias
#    Description: show alias summary of opscli library
#    Parameters:
#-- END CHEAT --

  ops::functions::show::_guardrails() {

    # We need to have the the library location
    LIBPATH_VAR="$(ops::info::get name | tr '[:lower:]' '[:upper:]')_PATH"
    if [[ ! -v ${LIBPATH_VAR} ]]; then
      writeWRN \
      "
      Cannot create cheatsheet, ${LIBPATH_VAR} is not defined. Please reload the $(ops::info::get name) library.
        cd ${!LIBPATH_VAR}
        unset $(ops::info::get name | tr '[:lower:]' '[:upper:]')_LIB
        source ./library.sh"
      return 1
    fi

  }
  ops::functions::show::_usage() {
    cat <<- EOF

    Parse all library functions and display the cheatcode textbloks.

    command options:

    -f | --full              (default) display each cheatcode block and an alias summary.
    -h | --help              Display this message
    --summary                Display only the alias summary.
    --functions              Display only the functions 

EOF
  }

  ops::functions::show::_process-arguments() {
    local arguments=($(ops::common::splitArgs "$@"))
    # set default argument if we have none
    if [[ ${#arguments[@]} -eq 0 ]]; then
      arguments=("-f")
    fi
    # now process all arguments
    for (( i = 0; i < ${#arguments[@]}; i++)); do
        case ${arguments[i]} in
            -h | --help)
                # show help message
                ops::fly::login::_usage
                return 1 # exit parent function with return 0
                ;;
            -f | --full)
                # The concourse team to request the token for
                ops::functions::show::_blocks
                ops::functions::show::_aliases
                ;;
            --summary)
                # The concourse team to request the token for
                ops::functions::show::_aliases
                ;;
            --functions)
                # The concourse team to request the token for
                ops::functions::show::_blocks
                ;;
            *)
                # unknown option
                writeWRN "    Unknown option ${arguments[i]}"
                ops::functions::show::_usage
                return 2 # exit parent function with return 1
                ;;
        esac
    done
  }

  ops::functions::show::_blocks() {
    
    # init vars
    declare -a files_array
    local cheatsheet=()
    # define start and end tag
    local start_tag="-- START CHEAT --"
    local end_tag="-- END CHEAT --"

    # find all bash scripts in subfolders and sort them alphabeticly
    # ignoring the top folder of the repo
    mapfile -t files_array < <(find "$OPSCLI_PATH" -mindepth 2 -type f -name '*.sh' | sort )

    # we expected files, so exit
    if [[ ${#files_array[@]} -eq 0 ]]; then
      writeWRN "No script files found under $OPSCLI_PATH and it's subfolders."
      return 1
    fi

    # proces the list of bash files
    writeDBG "We found ${#files_array[@]} to process."
    local summary=()
    for file in "${files_array[@]}"; do
      writeDBG "Processing file: $file"

      # guardrail, skipping the library.sh file (which we shouldn't have anyway in our list"
      if [[ "$file" == "$OPSCLI_PATH/library.sh" ]]; then
        writeDBG "skipping file $file"
        continue
      fi
      
      ## init var
      local txt_block=""
      # Find text blocks that are encapsuled with the start and end tag.
      txt_block=$(awk -v start="$start_tag" -v end="$end_tag" '
        {
        line = $0
        if (line !~ /^#/) next
        line = substr(line, 2)
        if ( line ~ start) { in_block=1; next}
        if (in_block && line ~ end)  { in_block=0; print "\n" ; next }
        if ( in_block ) {
          if ( /Function:/) { 
            print "\033[32m" line "\033[0m" 
            } else { print line }
          }
        }
      ' "$file")


      #-- write textblock to console
      if [[ -n "$txt_block" ]]; then
        echo -e "\n$txt_block\n"
      fi

    done
  }

  ops::functions::show::_aliases() {
    
    # init vars
    declare -a files_array
    local cheatsheet=()
    # define start and end tag
    local start_tag="-- START CHEAT --"
    local end_tag="-- END CHEAT --"

    # find all bash scripts in subfolders and sort them alphabeticly
    # ignoring the top folder of the repo
    mapfile -t files_array < <(find "$OPSCLI_PATH" -mindepth 2 -type f -name '*.sh' | sort )

    # we expected files, so exit
    if [[ ${#files_array[@]} -eq 0 ]]; then
      writeWRN "No script files found under $OPSCLI_PATH and it's subfolders."
      return 1
    fi

    # proces the list of bash files
    writeDBG "We found ${#files_array[@]} to process."
    local summary=()
    for file in "${files_array[@]}"; do
      writeDBG "Processing file: $file"

      # guardrail, skipping the library.sh file (which we shouldn't have anyway in our list"
      if [[ "$file" == "$OPSCLI_PATH/library.sh" ]]; then
        writeDBG "skipping file $file"
        continue
      fi
      
      # parse alias summary (alias : description)
      while IFS= read -r line; do
        summary+=("$line")
      done < <(awk -v start="$start_tag" -v end="$end_tag" '
        {

        line = $0
        if (line !~ /^#/) next
        line = substr(line, 2)
        if ( line ~ start) { in_block=1; alias=""; desc="";  next}
        if (in_block && line ~ end)  { 
          in_block=0
          if ( alias != "" ) { print "";  print alias ": " desc } 
          next }
        if ( in_block ) {
          if (line ~ /Alias:/) {
            gsub(/^[ \t]+/, "", line)
            gsub(/[ \t]+$/, "", line)
            sub(/Alias:[ \t]*/, "", line)
            alias=line
          } else if (line ~ /Description:/) {
            gsub(/^[ \t]+/, "", line)
            gsub(/[ \t\n]+$/, "", line)
            sub(/Description:[ \t]*/, "", line)
            desc=line
          } else if (line ~ /Function:/) {
            gsub(/^[ \t]+/, "", line)
            gsub(/[ \t]+$/, "", line)
            sub(/Function:[ \t]*/, "", line)
            fnc=line
            }
          }
        }
      ' "$file")
    done
    # print alias summary

    readarray -t sorted < <(printf '%s\n' "${summary[@]}" | sort)
    max_len=0
    aliases=()
    for line in "${sorted[@]}"; do
      alias="${line%%:*}"
      aliases+=("$alias")
      (( ${#alias} > max_len )) && max_len=${#alias}
    done
    # Print lines with explanations aligned at same column
    echo -e "\n--------- $(ops::info::get name) alias overview --------\n"
    for i in "${!sorted[@]}"; do
      alias="${aliases[i]}"
      explanation="${sorted[i]#*: }"
      [[ -n "$alias" ]] && printf "%-${max_len}s : %s\n" "$alias" "$explanation"
    done
  }

  #-- MAIN code 

  ops::functions::show::_guardrails "$@" || return $?
  ops::functions::show::_process-arguments "$@" || return $?
}

ops::functions::less() {
#-- START CHEAT --
#  Function: ops::functions::less
#    Alias:  ops-functions
#    Description: show the cheat block for this library piped through less -R
#    Parameters:
#       -f | --full              (default) display each cheatcode block and an alias summary.
#       -h | --help              Display this message
#       --summary                Display only the alias summary.
#       --functions              Display only the functions 
#-- END CHEAT --
    ops::functions::show "$@" | less -R
  }

alias ops-functions="ops::functions::less"
alias ops-alias="ops::functions::show --summary"
