# opscli repo - README

|||
|:---|:---|
|repository|opscli|
|version|[CHANGELOG.md](CHANGELOG.md)|
|Owner|brtlvrs|
|License|[MIT](LICENSE.md)|

## TLDR

This repository contains a BASH framework which can be extended by writing BASH functions in BASH files.
These files are placed in subfolders and are sourced when the library.sh is sourced.  
To make debugging easier we append ```set +x``` to COMMAND_PROMPT so every ```set -x``` call is closed before the shell prompt $PS1 is shown.  
Please **fork** this repository if you want to use it (at your own risk)

## Installation

### assumptions / preruiqisites

- following is installed:
  - git
  - BASH
  - yq (optional)
  - jq (optional)
- git repos are stored under $HOME/repos/

### steps

1. Fork this repository to your own project.
2. git clone your fork (you should only have a main branch) under $HOME/repos/
   ```BASH
   git clone <git repo url> -b <version>
   ``` 
3. update .bashrc with the code below
4. reload .bashrc
5. run ops-update to point to the latest version

Alternative instead of appending code to .bashrc just source the library.sh file by running

```bash
source library.sh
```

### .bashrc

Append the following code to the .bashrc file

```bash
#-- load opscli framework
if [[-f $HOME/.opscli.dev ]]; then
    # We detected the development marker file, so we source development environment
    source $HOME/repos/dev/opscli/library.sh
else
    source $HOME/repos/opscli/library.sh
fi
```

### setup development environment

This framework is meant to be extended with extra BASH functions to support Day2Operations.
Adding these functions should be done in the development environment, and then promoted.
The development environment is a new clone of this repo under the $HOME/repos/dev/ folder.
To setup the development environment run

```bash
ops-dev-init
```

See the [development](#development) paragraph for more information

## development / extending library

Development is done in its own branch and not on the main branch.
You can choose to have just a dev branch (which is automatically created when running ```ops-dev-init```)

### Way of working

#### In short

1. In the dev branch do a ```git merge main``` and ```git push``` to update remote and to have starting point to start the development from.
1. add, fix, change the code in the dev branch
2. git commit these changes (and push them to the remote)
3. Update CHANGELOG.md and update the version
4. ```git checkout main branch```
5. do a ```git merge --squash <deb branch>``` of the dev branch  
   This results in stage containing everything that is done between step 1 and this step
6. do a ```git commit -m "<version>"```
7. ```git tag "<version>"```
8. ```git push && git push --tags```
9. change env to prod with ```ops-prod```
10. update to latest version ```ops-update```

This would result in a main branch which only contains commits with a version, and these commits are tagged with the corresponding version

#### Version

To determine the version we use semver.  
The format is ```major.minor.patch```

|type|Description|
|:---|:---|
|major|These are breaking changes. Resulting in updating code that is using functions from this library
|minor|These are additions to the library. New functions that are introduced.
|patch|These are bug fixes, patches of functions

When you have multiple changes on the repo, then major trumps minor trumps patch. Meaning when you introduce a new function but als fixed a bug, then the minor index is bumped up and patch index is reset to 0.

## HOW-TO

- [Use this library in scripts](#use-this-library-in-scripts)
- [Log to console](#log-to-console)
- [Debugging scripts](#debugging-scripts)

### use this library in scripts

When this library is sourced, library.sh will create a env var OPSCLI_PATH which points to the root folder of this library. So when you want to use functions from this library in scripts, the script should start with 

```bash
#!/bin/bash

if [[  ! -d ${OPSCLI_PATH} ]]; then
    echo "WARNING: failed to source opscli library, cannot run script."
    exit 1
fi

# load opscli library
source ${OPSCLI_PATH}/library.sh

..... the rest of your code 
```

### log to console

Instead of using ```echo``` to output log messages to the console, this library has a set of functions to format these messages, so that these are standardized. The library knows the following log functions

|||
|:---|:---|
|writeINF| Write the message labeled as INFO
|writeDBG| If DEBUG environment variable is set, write the message labeled with DEBUG
|writeWRN| Write the message labeled as WARNING. It also shows where in the code this instruction is called.
|writeERR| Write the message labeled as ERROR. Including the position in the code where this is called.
|writeTODO| Write the message labeled as TODO, including the position in the code from where it is called.

All these functions don't write to a file, just to a console.
These functions format the message with a log level and color. So you don't have to do this with each ```echo``` instruction. The message is formatted and written to the console with the ```echo -e``` command.  
This makes writing multiline messages easier. For instance

```bash
writeINF \
"
This is a multiline message.
As a demonstration.
I could also use 
Hello world.
"

writeWRN "Something went not as expected."
```

### Debugging scripts

Ofcourse you have your own way of debugging. ```set -x``` is often used to see more in depth how the script is executed.   But if you forget ``` set +x``` your console could be filled with too much info.  
To solve this, ```set +x``` is added to the PROMPT_COMMAND variable. This string is executed before your prompt is written (PS1 environment variable).  
This is configured in the __trap.sh file under the _common folder.