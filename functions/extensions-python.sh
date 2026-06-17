#!/bin/bash

function ops::extensions::init-python() {
#-- START CHEAT --
#  Function: ops::extensions::init-python
#    Alias:  ops-init-extensions-py
#    Description: Initialize a Python-based opscli extensions repo
#    Parameters:
#      -h | --help   Show help
#-- END CHEAT --

    function ops::extensions::init-python::_usage() {
        cat <<-EOF
        Initialize a new opscli extensions repo at \$OPSCLI_EXTENSIONS_PATH
        with Python-based extension functions and bash management functions.

        Usage: ops-init-extensions-py [-h]

        Creates the directory with a Python package, a demo extension, bash
        management functions (info, dev/prod switch, update), a virtual
        environment, and an initial git commit.

        Set OPSCLI_EXTENSIONS_PATH in your .bashrc before running this command.

        Options:
          -h, --help    Show this help message and exit

EOF
    }

    function ops::extensions::init-python::_guardrails() {
        if [[ -z "${OPSCLI_EXTENSIONS_PATH:-}" ]]; then
            writeERR "OPSCLI_EXTENSIONS_PATH is not set."
            writeINF 'Add to your .bashrc:  export OPSCLI_EXTENSIONS_PATH="$HOME/repos/my-extensions"'
            return 1
        fi
        if [[ -d "${OPSCLI_EXTENSIONS_PATH}" ]]; then
            writeERR "Directory already exists: ${OPSCLI_EXTENSIONS_PATH}"
            writeINF "Remove it first or choose a different path."
            return 1
        fi
        if ! command -v python3 &>/dev/null; then
            writeERR "python3 not found in PATH."
            return 1
        fi
        if ! python3 -c "import venv" &>/dev/null; then
            writeERR "Python venv module not available. Install python3-venv."
            return 1
        fi
        return 0
    }

    function ops::extensions::init-python::_process-arguments() {
        local arguments=($(ops::common::splitArgs "$@"))
        for (( i=0; i<${#arguments[@]}; i++ )); do
            case ${arguments[i]} in
                -h|--help)
                    ops::extensions::init-python::_usage
                    return 0
                    ;;
                *)
                    writeWRN "Unknown option ${arguments[i]}"
                    ops::extensions::init-python::_usage
                    return 2
                    ;;
            esac
        done
    }

    function ops::extensions::init-python::_main() {
        local ext_path="${OPSCLI_EXTENSIONS_PATH}"
        local prefix py_pkg

        read -r -p "Function prefix (e.g. mycompany) [ext]: " prefix
        prefix="${prefix:-ext}"
        py_pkg="${prefix//-/_}_ext"

        writeINF "Initializing Python extensions repo at ${ext_path}"

        mkdir -p "${ext_path}/demo"
        mkdir -p "${ext_path}/manage"
        mkdir -p "${ext_path}/src/${py_pkg}/demo"

        # --- .gitignore ---
        cat > "${ext_path}/.gitignore" <<'GITIGNOREEOF'
.venv/
__pycache__/
*.pyc
*.egg-info/
dist/
build/
GITIGNOREEOF

        # --- pyproject.toml ---
        cat > "${ext_path}/pyproject.toml" <<PYPROJECTEOF
[project]
name = "${prefix}-ext"
version = "0.1.0"
requires-python = ">=3.9"

[project.scripts]
${prefix}-hello = "${py_pkg}.demo.hello:main"

[build-system]
requires = ["setuptools>=64"]
build-backend = "setuptools.build_meta"

[tool.setuptools.packages.find]
where = ["src"]
PYPROJECTEOF

        # --- Python package ---
        touch "${ext_path}/src/${py_pkg}/__init__.py"
        touch "${ext_path}/src/${py_pkg}/demo/__init__.py"

        cat > "${ext_path}/src/${py_pkg}/demo/hello.py" <<'PYTHONEOF'
#!/usr/bin/env python3
import argparse


def main():
    parser = argparse.ArgumentParser(description="Demo extension — greet someone")
    parser.add_argument("name", nargs="?", default="world", help="name to greet")
    args = parser.parse_args()
    print(f"Hello, {args.name}!")


if __name__ == "__main__":
    main()
PYTHONEOF

        # --- bash wrapper for the Python demo ---
        cat > "${ext_path}/demo/hello.sh" <<WRAPPEREOF
#!/bin/bash

function ${prefix}::demo::hello() {
#-- START CHEAT --
#  Function: ${prefix}::demo::hello
#    Alias:  ${prefix}-hello
#    Description: Demo extension — greet someone (Python)
#    Parameters:
#      --help   Show help
#      name     Name to greet (optional)
#-- END CHEAT --
    "\${OPSCLI_EXTENSIONS_PATH}/.venv/bin/${prefix}-hello" "\$@"
}

alias ${prefix}-hello='${prefix}::demo::hello'
WRAPPEREOF

        # --- manage/info.sh ---
        cat > "${ext_path}/manage/info.sh" <<INFOEOF
#!/bin/bash

function ${prefix}::manage::info() {
#-- START CHEAT --
#  Function: ${prefix}::manage::info
#    Alias:  ${prefix}-info
#    Description: Show extension repo parameters
#    Parameters:
#      -a | --all    Show all parameters (default)
#      -h | --help   Show help
#-- END CHEAT --

    if [[ -z "\${OPSCLI_EXTENSIONS_PATH:-}" ]]; then
        writeERR "OPSCLI_EXTENSIONS_PATH is not set."
        return 1
    fi

    local _key="\${1:--a}"
    local _is_dev=false
    [[ "\${OPSCLI_EXTENSIONS_PATH}" =~ \.dev\$ ]] && _is_dev=true

    case "\${_key}" in
        name)
            local _base
            _base="\$(basename "\${OPSCLI_EXTENSIONS_PATH}")"
            echo "\${_base%.dev}"
            ;;
        env)
            \$_is_dev && echo "dev" || echo "prod"
            ;;
        path)
            echo "\${OPSCLI_EXTENSIONS_PATH}"
            ;;
        prod_path)
            echo "\${OPSCLI_EXTENSIONS_PATH%.dev}"
            ;;
        dev_path)
            echo "\${OPSCLI_EXTENSIONS_PATH%.dev}.dev"
            ;;
        version)
            local _ver
            _ver="\$(cd "\${OPSCLI_EXTENSIONS_PATH}" && git describe --tags --exact-match 2>/dev/null || git rev-parse --abbrev-ref HEAD)"
            echo "\${_ver}"
            ;;
        git_url)
            echo "\$(cd "\${OPSCLI_EXTENSIONS_PATH}" && git config --get remote.origin.url 2>/dev/null)"
            ;;
        -a|--all)
            echo "name:    \$(${prefix}::manage::info name)"
            echo "env:     \$(${prefix}::manage::info env)"
            echo "path:    \$(${prefix}::manage::info path)"
            echo "version: \$(${prefix}::manage::info version)"
            echo "git_url: \$(${prefix}::manage::info git_url)"
            ;;
        -h|--help)
            echo "Usage: ${prefix}-info [-a|--all] [key]"
            echo "Keys: name, env, path, prod_path, dev_path, version, git_url"
            ;;
        *)
            writeWRN "Unknown key: \${_key}"
            ;;
    esac
}

alias ${prefix}-info='${prefix}::manage::info'
INFOEOF

        # --- manage/switch.sh ---
        cat > "${ext_path}/manage/switch.sh" <<SWITCHEOF
#!/bin/bash

function ${prefix}::manage::dev() {
#-- START CHEAT --
#  Function: ${prefix}::manage::dev
#    Alias:  ${prefix}-dev
#    Description: Switch extensions to the dev clone and reload
#    Parameters:
#      -h | --help   Show help
#-- END CHEAT --

    [[ "\$1" == "-h" || "\$1" == "--help" ]] && {
        echo "Usage: ${prefix}-dev"
        echo "  Switch OPSCLI_EXTENSIONS_PATH to the dev clone and reload."
        return 0
    }

    if [[ -z "\${OPSCLI_EXTENSIONS_PATH:-}" ]]; then
        writeERR "OPSCLI_EXTENSIONS_PATH is not set."
        return 1
    fi

    local _dev_path="\${OPSCLI_EXTENSIONS_PATH%.dev}.dev"
    if [[ ! -d "\${_dev_path}" ]]; then
        writeERR "Dev path not found: \${_dev_path}"
        return 1
    fi
    export OPSCLI_EXTENSIONS_PATH="\${_dev_path}"
    writeINF "Switching extensions to dev: \${_dev_path}"
    local _sb
    _sb="\$(basename "\${OPSCLI_PATH}")"; _sb="\${_sb%.dev}_loaded"; _sb="\${_sb//[.]/_}"; _sb="\${_sb^^}"
    unset "\${_sb}"
    source "\${OPSCLI_PATH}/library.sh"
}

alias ${prefix}-dev='${prefix}::manage::dev'


function ${prefix}::manage::prod() {
#-- START CHEAT --
#  Function: ${prefix}::manage::prod
#    Alias:  ${prefix}-prod
#    Description: Switch extensions to the production clone and reload
#    Parameters:
#      -h | --help   Show help
#-- END CHEAT --

    [[ "\$1" == "-h" || "\$1" == "--help" ]] && {
        echo "Usage: ${prefix}-prod"
        echo "  Switch OPSCLI_EXTENSIONS_PATH to the production clone and reload."
        return 0
    }

    if [[ -z "\${OPSCLI_EXTENSIONS_PATH:-}" ]]; then
        writeERR "OPSCLI_EXTENSIONS_PATH is not set."
        return 1
    fi

    local _prod_path="\${OPSCLI_EXTENSIONS_PATH%.dev}"
    if [[ ! -d "\${_prod_path}" ]]; then
        writeERR "Prod path not found: \${_prod_path}"
        return 1
    fi
    export OPSCLI_EXTENSIONS_PATH="\${_prod_path}"
    writeINF "Switching extensions to prod: \${_prod_path}"
    local _sb
    _sb="\$(basename "\${OPSCLI_PATH}")"; _sb="\${_sb%.dev}_loaded"; _sb="\${_sb//[.]/_}"; _sb="\${_sb^^}"
    unset "\${_sb}"
    source "\${OPSCLI_PATH}/library.sh"
}

alias ${prefix}-prod='${prefix}::manage::prod'
SWITCHEOF

        # --- manage/update.sh ---
        cat > "${ext_path}/manage/update.sh" <<UPDATEEOF
#!/bin/bash

function ${prefix}::manage::update() {
#-- START CHEAT --
#  Function: ${prefix}::manage::update
#    Alias:  ${prefix}-update
#    Description: Update the extension repo to a version tag and reload
#    Parameters:
#      -h | --help    Show help
#      \$1             Version tag (optional, defaults to latest stable)
#-- END CHEAT --

    [[ "\$1" == "-h" || "\$1" == "--help" ]] && {
        echo "Usage: ${prefix}-update [tag]"
        echo "  Without a tag, updates to the latest stable version."
        return 0
    }

    if [[ -z "\${OPSCLI_EXTENSIONS_PATH:-}" ]]; then
        writeERR "OPSCLI_EXTENSIONS_PATH is not set."
        return 1
    fi

    local _tag="\${1:-}"
    local _target="\${OPSCLI_EXTENSIONS_PATH}"

    if [[ "\${_target}" =~ \.dev\$ ]]; then
        _target="\${_target%.dev}"
        writeINF "Switching to prod for update: \${_target}"
    fi

    local _cwd="\$(pwd)"
    cd "\${_target}" || { writeERR "Cannot cd to \${_target}"; return 1; }
    git fetch --all --tags

    if [[ -z "\${_tag}" ]]; then
        _tag=\$(git tag -l 'v*.*.*' | grep -v -- '-' | sort -V | tail -1)
        if [[ -z "\${_tag}" ]]; then
            writeFAIL "No version tags found."
            cd "\${_cwd}"
            return 1
        fi
    fi

    git reset --hard "\${_tag}" || {
        writeERR "Failed to reset to \${_tag}"
        cd "\${_cwd}"
        return 1
    }

    if [[ -f "\${_target}/pyproject.toml" && -d "\${_target}/.venv" ]]; then
        writeINF "Updating Python extensions"
        "\${_target}/.venv/bin/pip" install -q -e "\${_target}"
    fi

    cd "\${_cwd}"
    export OPSCLI_EXTENSIONS_PATH="\${_target}"
    writeOK "Updated to \${_tag}"
    local _sb
    _sb="\$(basename "\${OPSCLI_PATH}")"; _sb="\${_sb%.dev}_loaded"; _sb="\${_sb//[.]/_}"; _sb="\${_sb^^}"
    unset "\${_sb}"
    source "\${OPSCLI_PATH}/library.sh"
}

alias ${prefix}-update='${prefix}::manage::update'
UPDATEEOF

        # --- create venv and install ---
        writeINF "Creating Python virtual environment"
        python3 -m venv "${ext_path}/.venv"
        writeINF "Installing extension package"
        "${ext_path}/.venv/bin/pip" install -q -e "${ext_path}"

        # --- git init ---
        pushd "${ext_path}" > /dev/null
        git init -q
        git add .
        git commit -q -m "initial commit — Python extensions with demo"
        popd > /dev/null

        writeOK "Extensions repo created at ${ext_path}"
        writeINF \
"Next steps:

  1. Reload your shell to pick up the extensions:
       ops-reload

  2. Try the demo:
       ${prefix}-hello
       ${prefix}-hello YourName

  3. Check repo info:
       ${prefix}-info

  4. Add new Python extensions:
       - Create src/${py_pkg}/<namespace>/<module>.py
       - Add the entry point to pyproject.toml [project.scripts]
       - Add a bash wrapper in <namespace>/<name>.sh with a cheat block
       - Run: ${ext_path}/.venv/bin/pip install -e ${ext_path}
       - Run: ops-reload"
        return 0
    }

    ops::extensions::init-python::_guardrails "$@" || return $?
    ops::extensions::init-python::_process-arguments "$@" || return $?
    ops::extensions::init-python::_main || return $?
}

alias ops-init-extensions-py='ops::extensions::init-python'
