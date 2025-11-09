# templates

This folder contains BASH templates for extending this library with functions and for BASH scripts that use this library.

|file|template for|
|---|---|
|[function.tmpl](./function.tmpl)|Template for writing functions to extend this library
|[scripts.tmpl](./script.tmpl)|Template for writing BASH scripts which use functions from this library

## function.tmpl

This file is a template to be cloned to a BASH script file (.sh) when adding new functions to this library.  
Place the cloned file in a subfolder of this repository. Subfolders are used to group the files in logical modules.
The file extension for the cloned file should be ```.sh```.

## scripts.tmpl

This file is a template to be cloned to a BASH script file (.sh) located outside this repository. 
To load and use this library in a script, and you have this library also sourced in your own BASH shell, you need to unset the block variable.
This is done in the ```script.tmpl``` file
