# opscli

| | |
|:---|:---|
| repository | opscli |
| version | [CHANGELOG.md](CHANGELOG.md) |
| owner | brtlvrs |
| license | [MIT](LICENSE.md) |

A BASH shell framework that is sourced into an interactive shell (via `.bashrc`) or into scripts. It provides a structured, reloadable function library with built-in logging, cheatsheet generation, and version management.

> **Fork this repository** if you want to contribute to the framework. To add your own functions, create a separate extensions repo — see [Extensions](#extensions).

## What's new

**v2.7.1** — All `write*` console logging functions have been restyled to a compact single-line format with a coloured symbol prefix (`→`, `✓`, `✗`, `▲`, `✖`, `⚙`, `☐`, `•`). Functions that include call location (`writeWRN`, `writeERR`, `writeDBG`, `writeTODO`) now print it on a second line. Run `writeDEMO` to see them all at once. See the full [CHANGELOG](CHANGELOG.md).

## Table of contents

- [How it works](#how-it-works)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Extensions](#extensions)
- [Key aliases](#key-aliases)
- [Using the library in scripts](#using-the-library-in-scripts)
- [Console logging](#console-logging)
- [Writing functions](#writing-functions)
- [Debugging](#debugging)
- [Contributing to the framework](#contributing-to-the-framework)

## How it works

opscli uses a two-repo model:

| Repo | Purpose |
|:---|:---|
| **opscli** (this repo) | The framework — foundational functions, logging, aliases, version management. Updated via `ops-update`. Never edit directly. |
| **your extensions repo** | Your custom functions. A separate git repo you own and version independently. |

At shell startup, `.bashrc` sources the framework. If `OPSCLI_EXTENSIONS_PATH` points to your extensions repo, the framework automatically sources it too — so `ops-reload` reloads everything in one shot.

```
.bashrc
  └── source opscli/library.sh
        ├── loads framework functions
        └── sources $OPSCLI_EXTENSIONS_PATH  (if set)
```

## Prerequisites

- `bash`
- `git`
- `jq` (optional)
- `yq` (optional)

## Installation

1. Clone this repo under `$HOME/repos/`:

   ```bash
   git clone <opscli-url> $HOME/repos/opscli
   ```

2. Add the following to your `~/.bashrc`:

   ```bash
   # point to your extensions repo (optional but recommended)
   export OPSCLI_EXTENSIONS_PATH="$HOME/repos/my-functions"

   # load the opscli framework
   source $HOME/repos/opscli/library.sh
   ```

3. Reload your shell:

   ```bash
   source ~/.bashrc
   ```

4. Update to the latest tagged version:

   ```bash
   ops-update
   ```

## Extensions

Your custom functions live in a separate repo that you create and manage. The framework sources it automatically when `OPSCLI_EXTENSIONS_PATH` is set.

### Setting up your extensions repo

```bash
mkdir -p $HOME/repos/my-functions
cd $HOME/repos/my-functions
git init
```

Add subfolders for your functions — any `.sh` file in any subfolder is sourced automatically:

```
my-functions/
├── kubernetes/
│   └── helpers.sh
├── aws/
│   └── helpers.sh
└── daily/
    └── shortcuts.sh
```

Set `OPSCLI_EXTENSIONS_PATH` in your `.bashrc` (before the `source` line) and reload. Your functions are now available alongside the framework functions.

### Updating the framework without affecting extensions

```bash
ops-update          # updates the framework, leaves your extensions untouched
ops-reload          # reloads both framework and extensions
```

Because your extensions live in a separate repo, `ops-update` (which does a `git reset --hard` inside the framework repo) never touches your files.

### Writing extension functions

Follow the same conventions as framework functions — see [Writing functions](#writing-functions). Use the `ops::*` namespace so your functions appear in `ops-functions` and are cleaned up correctly on `ops-reload`.

## Key aliases

| Alias | Description |
|:---|:---|
| `ops-reload` | Reload the framework and extensions from their respective paths |
| `ops-functions` | Browse the full function cheatsheet (piped through `less -R`) |
| `ops-alias` | Show alias summary only |
| `ops-info [key]` | Show library metadata (path, version, git url, env, …) |
| `ops-update [--beta] [tag]` | Fetch tags and reset framework to a version; `--beta` targets the latest beta release |
| `ops-init-extensions` | Initialize a new extensions repo at `$OPSCLI_EXTENSIONS_PATH` |
| `shellTMPdir` | Create a hidden temp directory under `$HOME` |
| `shellTMP` | Create a temp file inside a `shellTMPdir` directory |

`ops-info` accepts a key argument to return a single value:

```bash
ops-info version      # current version tag or branch
ops-info git_url      # remote origin URL
ops-info prod_path    # path to the framework clone
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

If `OPSCLI_EXTENSIONS_PATH` is set in the environment, extensions are loaded automatically here too.

Pass `-v <version>` directly to `library.sh` to combine the source and version check:

```bash
source ${OPSCLI_PATH}/library.sh -v v2.0.0 || exit 1
```

## Console logging

Use these functions instead of raw `echo`. All output goes to stderr. Every function produces a compact single-line format: a coloured timestamp + label, a symbol, then the message. Run `writeDEMO` to see them all in one go.

| Function | Symbol | Colour | Notes |
|:---|:---|:---|:---|
| `writeINF` | `→` | cyan | General informational message |
| `writeOK` | `✓` | black on green | Pass / success result |
| `writeFAIL` | `✗` | black on red | Fail / validation result |
| `writeNOTE` | `•` | grey | Subtle annotation or context |
| `writeWRN` | `▲` | yellow | Warning; call location printed on last line |
| `writeERR` | `✖` | red | Hard error; call location printed on last line |
| `writeTODO` | `☐` | yellow | Marks incomplete code; call location printed on last line |
| `writeDBG` | `⚙` | grey | Debug; call location on last line; only printed when `$DEBUG` or `$debug` is set |

```bash
writeINF  "Library loaded successfully."
writeOK   "Connection established."
writeFAIL "Health check failed."
writeNOTE "Skipping optional step."
writeWRN  "Config value missing, using default."
writeERR  "Fatal: could not connect."
writeTODO "Implement retry logic."
DEBUG=true writeDBG "Variable value: $myvar"
```

## Writing functions

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

Place the `.sh` file in any subfolder of your extensions repo; it is sourced automatically on the next `ops-reload`.

## Debugging

`set -x` is safe to use interactively. `ops::common::appendPromptCommand` prepends `set +x` to `PROMPT_COMMAND`, so xtrace is silenced automatically before the next prompt — stray `set -x` calls will not pollute your interactive shell.

Enable `writeDBG` output:

```bash
export DEBUG=true   # or: debug=true
```

When `DEBUG` is set, temp directories created by `shellTMPdir` are not cleaned up on exit or `CTRL-C`, making it easier to inspect intermediate state.

## Contributing to the framework

To contribute changes to the framework itself (not extensions), you need both the production and development clones.

### Setup

```bash
ops-init-dev    # clones the framework repo to $HOME/repos/opscli.dev and creates the dev branch
ops-dev         # switch the active library to the dev clone
```

### Switching between environments

| Alias | Description |
|:---|:---|
| `ops-dev` | Reload from the development clone (`opscli.dev`) |
| `ops-prod` | Reload from the production clone (`opscli`) |

`ops-update` automatically switches from dev to prod when invoked from the dev clone, so you do not need to run `ops-prod` first.

### Development cycle

1. `git merge main && git push` — sync the dev branch with the latest release
2. Add or modify `.sh` files in the dev clone
3. `ops-reload` — pick up the changes in the current shell
4. `git commit` the changes
5. When ready to release, follow the release process in [CLAUDE.md](CLAUDE.md)
