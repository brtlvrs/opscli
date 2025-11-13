#!/bin/bash

function ops::functions::update() {
#-- START CHEAT --
#  Function: ops::functions::update
#    Alias:  ops-update <version>
#    Description: Update the opscli repo under $OPSCLI_PATH location
#    Parameters:
#          $1  : (optional) git branch/tag to update to
#                 when not used, it will update to the latest version
#-- END CHEAT --
  local LIBNAME=$(ops::info::get name | tr '[:lower:]' '[:upper:]')
  local LIBPATH_VAR="${LIBNAME}_PATH"
  if [[ ! -v "$LIBPATH_VAR" ]];  then
      writeWRN "Couldn't find environment var $LIBPATH_VAR. Cannot update"
      return 1
  fi
  local DEV_PATH="$(ops::info::get dev_path)"
  if  [[ "$DEV_PATH" == "${!LIBPATH_VAR}" ]]; then
      writeWRN "$LIB_PATH environment variable points to a dev(elopment) folder, cowardly ignoring update."
      return 1
  fi

  local tag=$1
  local currentPath=$(pwd)
  cd "${!LIBPATH_VAR}"
  git fetch --all
  if [[ -z "$tag" ]]; then
    writeINF "No tag defined, looking for the newest version tag."
    tag=$(git tag -l 'v*.*.*' | sort -V | tail -1)
    if [[ $? -ne 0 || -z "$tag" ]]; then
      writeWRN "Failed to determine latest version tag."
      return 1
    fi
  fi
  git reset --hard $tag
  cd $currentPath
  if [[ $? -gt 0 ]]; then
    writeWRN \
    "
    Failed to update. Advise is to remove folder and clone the repo again, follow:

      ${cyan}rm -rf $OPSCLI_PATH
      cd $(dirname $OPSCLI_PATH)
      git clone -b <version tag> $(ops::info::get git_url) --no-checkout
      cd $(ops::info::get name)
      git checkout <version tag>${clr_reset}"
    return 1
  fi

  writeINF "Successfully changed $(ops::info::get name) to $tag"
  ops-reload
}

alias ops-update=ops::functions::update
