# OPSLIB

This repository is a framework for BASH functions. These functions can be used in scripts, reusing code instead of having in scripts similar code for general stuff.
Also the functions can be used from a BASH terminal. 
To have a structured approach, the function names follow a convention. The convention is:

**prefix::module::name**

This makes reloading the functions easier, because we can first remove all functions that start with the prefix.  
But to make life easier to run functions directly from the terminal we use aliases.  
The repository exists of a default set of functions, and can be extended by adding more bash functions, grouped in subfolders.  
The default set is used for control the library itself, and for some common log functionality.

## Preruiqisites

- git installed localy
- BASH shell
- a git server, containing this repository.  
  (gitea, gitlab, github)

# How-To


## how-to consume this library

The only action you need to do is to source the library.sh file once.
This will load all functions into memory and creates alias. To prevent a loop, the library.sh will set a block variable. When library.sh detects this variable it refuses to load the library.  
You can reload or update it with predefined aliases.  
This alias is mentioned in the welcome message when the library is (re)loaded.

### from .bashrc

To automaticly load the library when logging into a bash shell, add the following code to the .bashrc

```bash
OPSLIBDEV=""
if [[ -f $HOME/.opslib.dev ]]; then
    # Opslib was run in development mode
    OPSLIBDEV="dev/"
fi
source $HOME/repos/${OPSLIBDEV}opslib/library.sh
unset OPSLIBDEV
```

## How-to install this library

