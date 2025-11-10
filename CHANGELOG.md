# CHANGELOG

# Version
|version|Worked in|
|---|---|
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


