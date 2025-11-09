#!/bin/bash

# This script sets up the development environment for the project.
function ops::functions::init_dev() {
#-- START CHEAT --
#  Function: ops::functions::init_dev
#    Alias:  ops-init-dev
#    Description: Initialize the development environment for opslib
#    Parameters:
#-- END CHEAT --
    if ops::info::get env | grep -q "dev"; then
        writeINF "Already in development environment."
        return 0
    fi

    if ! -d "$(ops::info::get dev_path)"; then
        writeINF "Development path does not exist: $(ops::info::get dev_path), let's create it"
        mkdir ../dev
        git clone "$(ops::info::get git_url)" "$(ops::info::get dev_path)"
        if [[$? -ne 0]]; then
            writeERR "Failed to clone repository to development path."
            return 1
        fi
        cd "$(ops::info::get dev_path)"
        local branch="dev"
        local remote="origin"
        if git ! git ls-remote --exit-code --heads "$remote" "$branch" >/dev/null 2>&1; then
            writeINF "dev branch not found on remote, creating it."
            git checkout -b "$branch"
            git push -u "$remote" "$branch"
        fi
        git checkout "$branch"

    fi
}

alias ops-init-dev="ops::functions::init_dev"