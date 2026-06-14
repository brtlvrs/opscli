#!/bin/bash

function ops::functions::update() {
#-- START CHEAT --
#  Function: ops::functions::update
#    Alias:  ops-update [--beta] [<version>]
#    Description: Update the opscli repo under $OPSCLI_PATH location
#    Parameters:
#          --beta : update to the latest beta release (v*.*.*-beta.*)
#          $1     : (optional) explicit git tag to update to
#                   when not used, updates to the latest stable release
#-- END CHEAT --
  local LIBNAME=$(ops::info::get name | tr '[:lower:]' '[:upper:]')
  local LIBPATH_VAR="${LIBNAME}_PATH"
  if [[ ! -v "$LIBPATH_VAR" ]];  then
      writeFAIL "Couldn't find environment var $LIBPATH_VAR. Cannot update"
      return 1
  fi
  local target_path="${!LIBPATH_VAR}"
  local DEV_PATH="$(ops::info::get dev_path)"
  if [[ "$DEV_PATH" == "${!LIBPATH_VAR}" ]]; then
      writeINF "Currently running from dev environment, will update and switch to production."
      target_path="$(ops::info::get prod_path)"
  fi

  local tag=""
  local beta=false
  local arguments=($(ops::common::splitArgs "$@"))
  for (( i=0; i<${#arguments[@]}; i++ )); do
    case ${arguments[i]} in
      --beta) beta=true ;;
      *)      tag="${arguments[i]}" ;;
    esac
  done

  local currentPath=$(pwd)
  cd "${target_path}"
  git fetch --all --tags
  if [[ -z "$tag" ]]; then
    if [[ "$beta" == true ]]; then
      writeINF "Looking for the latest beta release tag."
      tag=$(git tag -l 'v*.*.*' | grep -- '-beta\.' | sort -V | tail -1)
      if [[ -z "$tag" ]]; then
        writeFAIL "No beta release tags found."
        cd "$currentPath"
        return 1
      fi
    else
      writeINF "No tag defined, looking for the newest stable version tag."
      tag=$(git tag -l 'v*.*.*' | grep -v -- '-' | sort -V | tail -1)
      if [[ $? -ne 0 || -z "$tag" ]]; then
        writeFAIL "Failed to determine latest version tag."
        cd "$currentPath"
        return 1
      fi
    fi
  fi
  git reset --hard $tag
  local reset_exit=$?
  cd $currentPath
  if [[ $reset_exit -gt 0 ]]; then
    writeWRN \
    "
    Failed to update. Advise is to remove folder and clone the repo again, follow:

      ${cyan:-}rm -rf ${target_path}
      cd $(dirname ${target_path})
      git clone -b <version tag> $(ops::info::get git_url) --no-checkout
      cd $(ops::info::get name)
      git checkout <version tag>${clr_reset:-}"
    return 1
  fi

  writeOK "Successfully changed $(ops::info::get name) to $tag"
  # reload library from target (prod) path
  source "${target_path}/library.sh" -f
}

alias ops-update=ops::functions::update
