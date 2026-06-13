# opscli

| | |
|:---|:---|
| repository | opscli |
| version | [CHANGELOG.md](CHANGELOG.md) |
| owner | brtlvrs |
| license | [MIT](LICENSE.md) |

A BASH shell framework that is sourced into an interactive shell (via `.bashrc`) or into scripts. It is not a compiled program — it is a library of BASH functions loaded at shell startup. The entry point is `library.sh`.

> **Fork this repository** if you want to use it as the base for your own library. Extend it by adding `.sh` files to any subfolder; they are picked up automatically on the next reload.

## Table of contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Key aliases](#key-aliases)
- [Using the library in scripts](#using-the-library-in-scripts)
- [Console logging](#console-logging)
- [Writing new functions](#writing-new-functions)
- [Development environment](#development-environment)
- [Debugging](#debugging)

## Features

- Auto-loads every `.sh` file under any subfolder — add a file and it is available after `ops-reload`
- Stop-block prevents double-loading; `ops-reload` performs a clean slate reload (unsets all `ops::*`, `write*`, and `log*` functions before re-sourcing)
- `set +x` is appended to `PROMPT_COMMAND` so `set -x` debug traces are silenced automatically before each shell prompt
- Built-in cheatsheet: `ops-functions` and `ops-alias` parse `#-- START CHEAT --` blocks across all loaded files
- Version enforcement: scripts can require a minimum library version via `ops::version::isSupported`
- Structured console logging with colour-coded output levels
- Dev/prod switching: `ops-dev` / `ops-prod` reload the library from the matching clone

## Prerequisites

- `bash`
- `git`
- `jq` (optional)
- `yq` (optional)

## Installation

1. Fork this repository to your own account.
2. Clone it under `$HOME/repos/`:

   ```bash
   git clone <your-fork-url> $HOME/repos/opscli
   cd $HOME/repos/opscli
   git checkout <version-tag>
   ```

3. Add the following to your `~/.bashrc`:

   ```bash
   # load opscli framework
   if [[ -f $HOME/.opscli.dev ]]; then
       source $HOME/repos/opscli.dev/library.sh
   else
       source $HOME/repos/opscli/library.sh
   fi
   ```

   The marker file `~/.opscli.dev` is created automatically when the dev clone is active and removed when you switch back to prod.

4. Reload your shell:

   ```bash
   source ~/.bashrc
   ```

5. Update to the latest tagged version:

   ```bash
   ops-update
   ```

## Key aliases

| Alias | Description |
|:---|:---|
| `ops-reload` | Unload and re-source the library from `$OPSCLI_PATH` |
| `ops-functions` | Browse the full function cheatsheet (piped through `less -R`) |
| `ops-alias` | Show alias summary only |
| `ops-info [key]` | Show library metadata (path, version, git url, env, …) |
| `ops-update [tag]` | Fetch tags and reset to a version; switches to prod automatically when run from dev |
| `ops-dev` | Reload from the development clone (`opscli.dev`) |
| `ops-prod` | Reload from the production clone (`opscli`) |
| `ops-init-dev` | Clone the repo into the `.dev` path and create the `dev` branch |
| `shellTMPdir` | Create a hidden temp directory under `$HOME` |
| `shellTMP` | Create a temp file inside a `shellTMPdir` directory |

`ops-info` accepts a key argument to return a single value:

```bash
ops-info version      # current version tag or branch
ops-info git_url      # remote origin URL
ops-info prod_path    # path to the production clone
ops-info dev_path     # path to the development clone
ops-info env          # "prod" or "dev"
ops-info --all        # print all of the above
```

## Using the library in scripts

When the library is sourced, `library.sh` exports `$OPSCLI_PATH`. Scripts can use this to reload the library and enforce a minimum version:

```bash
#!/bin/bash

[[ ! -d ${OPSCLI_PATH} ]] && { echo "WARNING: opscli not loaded."; exit 1; }

unset OPSCLI_LOADED
source ${OPSCLI_PATH}/library.sh
ops::version::isSupported v2.0.0 || exit 1

# ... rest of the script
```

Pass `-v <version>` directly to `library.sh` to combine the source and version check in one step:

```bash
source ${OPSCLI_PATH}/library.sh -v v2.0.0 || exit 1
```

## Console logging

Use these functions instead of raw `echo`. All output goes to stderr.

| Function | Colour | Notes |
|:---|:---|:---|
| `writeINF` | cyan | General informational message |
| `writeDBG` | grey | Only printed when `$DEBUG` or `$debug` is set |
| `writeWRN` | yellow | Includes source file and line number |
| `writeERR` | red | Includes source file and line number |
| `writeOK` | green | Single-line pass / success result |
| `writeFAIL` | red | Single-line fail / validation result |
| `writeNOTE` | grey | Single-line subtle annotation |
| `writeTODO` | yellow | Includes function name, file, and line number |

All functions accept a single string argument and support multi-line messages via here-doc or escaped newlines:

```bash
writeINF "Library loaded successfully."

writeINF \
"
Multi-line message:
  line one
  line two
"

writeWRN "Something unexpected happened."
writeERR "Fatal: could not connect."
```

## Writing new functions

Use `templates/function.tmpl` as a starting point. Every function must include a **cheat block** so it appears in `ops-functions` and `ops-alias`:

```bash
#-- START CHEAT --
#  Function: ops::namespace::functionname
#    Alias:  ops-myalias
#    Description: One-line description
#    Parameters:
#      -h | --help   Show help
#      $1            Some positional argument
#-- END CHEAT --
```

Standard function structure:

```bash
function ops::namespace::name() {
    function ops::namespace::name::_usage() { cat <<-EOF
        usage: ops-myalias [-h] <arg>
    EOF
    }
    function ops::namespace::name::_guardrails() { … }
    function ops::namespace::name::_process-arguments() {
        local arguments=($(ops::common::splitArgs "$@"))
        for (( i=0; i<${#arguments[@]}; i++ )); do
            case ${arguments[i]} in
                -h|--help) ops::namespace::name::_usage; return 1 ;;
            esac
        done
    }
    function ops::namespace::name::_main() { … }

    ops::namespace::name::_guardrails "$@" || return $?
    ops::namespace::name::_process-arguments "$@" || return $?
    ops::namespace::name::_main || return $?
}
alias ops-myalias='ops::namespace::name'
```

`ops::common::splitArgs` normalises `--key=value` into `--key value` pairs before the `case` loop.

Place the file in any subfolder; it is sourced automatically on the next `ops-reload`.

## Development environment

The production clone lives at `$HOME/repos/opscli`.
The development clone lives at `$HOME/repos/opscli.dev` (same `.dev` suffix convention as `.wiki`).

Set up the dev environment from a running prod shell:

```bash
ops-init-dev   # clones the repo to the .dev path and creates the dev branch
ops-dev        # switch the active library to the dev clone
```

Typical development cycle:

1. `git merge main && git push` — sync the dev branch with the latest release
2. Add or modify `.sh` files in the dev clone
3. `ops-reload` — pick up the changes in the current shell
4. `git commit` the changes
5. When ready to release, follow the release process in [CLAUDE.md](CLAUDE.md)

To switch back to production:

```bash
ops-prod       # reload from the production clone
ops-update     # fast-forward to the latest version tag
```

`ops-update` automatically switches from dev to prod when invoked from the dev clone, so you do not need to run `ops-prod` first.

## Debugging

`set -x` is safe to use interactively. `ops::common::appendPromptCommand` prepends `set +x` to `PROMPT_COMMAND`, so xtrace is silenced automatically before the next prompt — stray `set -x` calls will not pollute your interactive shell.

Enable `writeDBG` output:

```bash
export DEBUG=true   # or: debug=true
```

When `DEBUG` is set, temp directories created by `shellTMPdir` are not cleaned up on exit or `CTRL-C`, making it easier to inspect intermediate state.
