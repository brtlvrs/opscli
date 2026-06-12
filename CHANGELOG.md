# CHANGELOG

# Version
|version|Worked
|---|---|
|[v2.3.0](#v2.3.0)|ops-update auto-switches to prod when running from dev|
|[v2.2.5](#v2.2.5)|fix ops-prod and ops-dev not reloading the library|
|[v2.2.4](#v2.2.4)|fix ops-update not fetching new tags|
|[v2.2.3](#v2.2.3)|bug fixes from code review|
|[v2.2.2](#v2.2.2)|bug fixes and set -u compatibility|
|[v2.2.1](#v2.2.1)|bug fixes in develop, show and http tools|
|[v2.2.0](#v2.2.0)|added writeNote for simple formatted echoing
|[v2.1.4](#v2.1.4)|refactored ops-update
|[v2.1.3](#v2.1.3)|bug fix ops-info
|[v2.1.1](#v2.1.1)|bug fix version check, and argument processing
|[v2.1.0](#v2.1.0)|added version check in library.sh, force
|[v2.0.0](#v2.0.0)|changed assumed location for dev repository
|[v1.2.0](#v1.2.0)|added version validation
|[v1.1.2](#v1.1.2)|removed demo
|[v1.1.1](#v1.1.1)|demo
|[v1.1.0](#v1.1.0)|Added --help option to ops-info
|[v1.0.2](#v1.0.2)|Coloured response from ops-functions
|[v1.0.1](#v1.0.1)|Replaced opslib with opscli|
|[v1.0.0](#v1.0.0)|Renamed repo from opslib to opscli|
|[v0.9.3](#v0.9.3)|Bug fix in console.sh
|[v0.9.2](#v0.9.2)|Merge fix
|[v0.9.1](#v0.9.1)|bug fix in library.sh
|[v0.9.0](#v0.9.0)|Updated README.md, updated welcome message, added templates
|[v0.8.0](#v0.8.0)|Added env argument to info function
|[v0.7.3](#v0.7.3)|Using color vars in banner
|[v0.7.2](#v0.7.2)|Fixed CHANGELOG.md
|[v0.7.1](#v0.7.1)|Added LICENSE.md
|[v0.7.0](#v0.7.0)|traps, COMMAND_PROMPT
|[v0.6.3](#v0.6.3)|refactored ops-info|
|[v0.6.2](#v0.6.2)|bug fix ops-alias|
|[v0.6.1](#v0.6.1)|Refactored ops-alias|
|[v0.6.0](#v0.6.0)|Cleanup|
|[v0.5.0](#v0.5.0)|Cleanup and renaming|
|[v0.4.2](#v0.4.2)|bug fix|
|[v0.4.1](#v0.4.1)|bug fix|
|[v0.4.0](#v0.4.0)|added arguments to ops-info|
|[v0.3.1](#v0.3.1)|bugfix ops-update|
|[v0.3.0](#v0.3.0)|added arguments to ops-parameters|
|[v0.2.0](#v0.2.0)|added parameters function|
|[v0.1.1](#v0.1.1)|fixed ops-prod and ops-dev|
|[v0.1.0](#v0.1.0)|first edition|


## Semver / version explenation

Version format is ```<major>.<minor>.<patch>```

|||
|---|---|
|major|Structural / breaking changes|
|minor|New functionality without breaking changes|
|patch|bug fixes|

# v2.3.1

fixed:

- functions/update.sh: sourcing prod library mid-function triggered the cleanup loop twice, leaving ops::functions::update undefined after ops-update returned; replaced mid-function source with a local target_path variable and a single reload at the end
- functions/update.sh: failure-path error message referenced $OPSCLI_PATH instead of target_path, showing the wrong path when running from dev

# v2.3.0

changed:

- functions/update.sh: ops-update now automatically switches to the production environment (sources prod library.sh -f) when invoked from the dev clone, instead of refusing with an error. No manual ops-prod required before running ops-update.

# v2.2.5

fixed:

- _common/_lib-env.sh: ops-prod and ops-dev used single-quoted aliases so ${stopBlock} expanded at execution time when stopBlock was already unset, making the unset a no-op and the stop-block preventing the library from reloading; switched to double quotes so ${stopBlock} expands at definition time (matching how ops-reload works in library.sh)

# v2.2.4

fixed:

- functions/update.sh: git fetch --all does not reliably fetch new tags; changed to git fetch --all --tags so ops-update finds the latest version tag without requiring a manual git fetch first

# v2.2.3

fixed:

- functions/version.sh: banner condition used && instead of || so ops::common::banner was never called
- functions/update.sh: error message referenced undefined $LIB_PATH instead of $LIBPATH_VAR
- ___log/console.sh: writeTODO prepended "TODO: " to wrong variable ($msg instead of $message), so prefix was silently lost
- _common/__trap.sh: $? in CTRLC error message was from cleanupTMP, not the original triggering error; now captured before cleanup runs

# v2.2.2

fixed:

- _common/__trap.sh: rm glob was quoted so temp dirs created by shellTMPdir were never cleaned up on exit
- _common/__trap.sh: ${trapCTRLC_ran:-0} guard for set -u compatibility
- functions/update.sh: git reset --hard exit code was lost because cd overwrote $? before the check
- library.sh: uppercase BASH in guard condition meant writeOK was never shown when sourced from an interactive shell
- info/info.sh: typo LIBMAME instead of LIBNAME broke dev-path detection
- console.sh: ${debug}/${DEBUG} check replaced with [[ ! -v debug && ! -v DEBUG ]] for set -u compatibility; added return after unknown log level to prevent fall-through with unset $LEVEL
- tools/http_response.sh + http_test.sh: ${skip_ssl:-} and ${quit:-} for set -u compatibility
- info/info.sh, functions/update.sh, _common/banner.sh: color variable references guarded with :- defaults for set -u compatibility

# v2.2.1

fixed:

- functions/develop.sh: missing `[[ ]]` around `-d` test, missing space in `[[ ]]`, duplicate `git` and misplaced `!` in `ls-remote` condition
- functions/show.sh: `--help` was calling `ops::fly::login::_usage` instead of `ops::functions::show::_usage`
- tools/http_response.sh: curl exit code was lost due to combining `local` and assignment on one line
- tools/http_test.sh: same curl exit code fix as http_response.sh

# v2.2.0

- introducing writeNOTE, which is formatted same as writeFAIL or writeOK but using the color grey for the whole line.

# v2.1.4

changed:

- changed some writeWRN into writeFAIL for ops-update
- changed the reload of the library, stepped away from using the alias

# v2.1.3

fixed:

- ops-info detection for .dev 

# v.2.1.1

fixed:

- library.sh - fixed argument processing

# v2.1.0

added:

- implemented ops::version::isSupported into library.sh
- added -f / --force to library.sh so it will unload the stopblock before (re)loading

changed:

- changed log functions, to use less console lines

# v2.0.0

changed:

- instead of assuming the dev repository is under a sibling folder called dev. The dev repository ends now with .dev (just like .wiki for wiki repositories). This is a breaking change.
- Updated README.md with feature paragraph
- changed suffix of variable that prevents looping of library from _LIB to _LOADED

# v1.2.0

added:

- ops::version::isSupported added, to be used as a guardrail function in scripts as a version check of this library


changed:

- library.sh - removed export DEBUG=true line
- updated template file for scripts including ops::version::isSupported as a guardrail

# v1.1.2

removed:

- demo folder

# v1.1.1

added:

- demo 


# v1.1.0

added:

- --help top ops-info, showing help message

# v1.0.2

added:

- path_var and block_var to ops-info, returns the ENV var for the path of this library and the ENV var that prevents reloading.

changed:

- ops-functions returns now coloured response

# v1.0.1

changed:

- replaced all opslib words with opscli

# v1.0.0

change:

- renamed repo from opslib to opscli. Renaming env vars that are build on this name.
  OPSLIB_PATH renamed to OPSCLI_PATH and OPSLIB_LIB renamed to OPSCLI_LIB

# v0.9.3

fix:

- missing set +x instruction in console.sh, fixed. Now when you do a set -x to test scripts, the log function will ignore it, making the output more readable when debugging.

# v0.9.2

bug:

- merge conflict was pushed, this is fixed

# v0.9.1

bug:

- library.sh - syntax error in echo instruction when detecting of library.sh is directly or sourced 

# v0.9.0

added:

- template files to extend library with functions
- template file for writing scripts that use/source this library

changed:

- welcome message when sourcing library.sh shows ops-info command
- Updated README.md

# v0.8.0

add:

- ops::info::get - ops-inf - added 'env' argument. This returns dev when we point to the dev repo, or prod if it is the prod repo.
- ops::functions::init_dev - ops-init-dev - setup the dev environment of this lbrary

# v0.7.3

changed:

- ops::common::banner - replaced color codes with predefined color variables. Making it better readable

# v0.7.2

fix:

- typos in the table of CHANGELOG.md

# v0.7.1

added:

- added LICENSE.md

# v0.7.0

changed:

- moved trap handling to separate module
- adding extra commands to COMMAND_PROMPT, including set +x, so set -x won't affect the prompt
- updating documentation

# v0.6.3

changed:

- ops::info::show / ops-info - removed running information, added running tag to show which repo is used

# v0.6.2

fix:

- ops::functions::update - typo fix

# v0.6.1

Changed:

- ops::functions::show::_aliases / ops-alias - Starting the description at the same position for each line, and sorting on alias
- Updated README.md

# v0.6.0

changed:

- removing references

# v0.5.0

changed:

- ops::ops into ops::info
- ops-cheat into ops-functions
- ops-summ into ops-alias
- ops::ops::update into ops::functions::update

# v0.4.2

fix:
- bug fixes


# v0.4.1

fix:
- failed merge cleanup in info.sh
- renamed parameters.sh to info.sh

# v0.4.0

added:

- extra arguments to ops-info

changed:

- ops-parameters to ops-info
- ops::ops::parameters to ops::info::get

# v0.3.1

fix:

- ops::ops::update - ops-update - removed return 0 blocking flow of code

# v0.3.0

added:

- ops::ops::parameters - added arguments version,name,prod_path,dev_path,git_url

# v0.2.0

added:

- ops::ops::parameters - configuration parameters of this library

changed:

- ops::ops::update - using ops::ops::parameters for repository path and version

# v0.1.1

fix:

- ops-prod pointing to correct path
- ops-dev pointing to correct path

# v0.1.0


