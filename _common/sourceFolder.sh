#!/bin/bash

ops::common::sourceFolder() {
#-- START CHEAT --
#  Function: ops::common::sourceFolder
#    Alias:  
#    Description: source all bash scripts from given folder and it's subfolders
#    Parameters:
#         $1  : Top folder for sourcing files
#         $2  : min folder depth relative to topfolder
#-- END CHEAT --

  # this function scans all subfolders of the given folder for .sh files and sources them
  local parent=$(readlink -f "${BASH_SOURCE[-1]}")
  local base_path="$1"
  declare -a files_array

  # make an array of all bash files that need to be sources
  if  [[ ! -d "$base_path" ]]; then
    echo "Invalid path $base_path">&2
    $exitErr_cmd
  fi

  # find all bash scripts in subfolders and sort them alphabeticly
  mapfile -t files_array < <(find "$base_path" -mindepth ${2:-2} -type f -name '*.sh' | sort )

  # source each file
  for file in "${files_array[@]}"; do
    if [[ "$file" != "$parent" ]]; then
      # only source siblings, not the caller/parrent
      source "$file"
    fi
  done
}

