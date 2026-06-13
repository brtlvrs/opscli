#!/bin/bash

function ops::extensions::init() {
#-- START CHEAT --
#  Function: ops::extensions::init
#    Alias:  ops-init-extensions
#    Description: Initialize a new opscli extensions repo with a demo function
#    Parameters:
#      -h | --help   Show help
#-- END CHEAT --

    function ops::extensions::init::_usage() {
        cat <<-EOF
        Initialize a new opscli extensions repo at \$OPSCLI_EXTENSIONS_PATH.

        Usage: ops-ext-init [-h]

        Creates the directory, runs git init, adds a demo function, and makes
        an initial commit. Set OPSCLI_EXTENSIONS_PATH in your .bashrc before
        running this command.

        Options:
          -h, --help    Show this help message and exit

EOF
    }

    function ops::extensions::init::_guardrails() {
        if [[ -z "${OPSCLI_EXTENSIONS_PATH:-}" ]]; then
            writeERR "OPSCLI_EXTENSIONS_PATH is not set."
            writeINF "Add the following to your .bashrc before the opscli source line:"
            writeINF '  export OPSCLI_EXTENSIONS_PATH="$HOME/repos/my-functions"'
            return 1
        fi
        if [[ -d "${OPSCLI_EXTENSIONS_PATH}" ]]; then
            writeERR "Directory already exists: ${OPSCLI_EXTENSIONS_PATH}"
            writeINF "Remove it first or choose a different path."
            return 1
        fi
        return 0
    }

    function ops::extensions::init::_process-arguments() {
        local arguments=($(ops::common::splitArgs "$@"))
        for (( i=0; i<${#arguments[@]}; i++ )); do
            case ${arguments[i]} in
                -h|--help)
                    ops::extensions::init::_usage
                    return 1
                    ;;
                *)
                    writeWRN "Unknown option ${arguments[i]}"
                    ops::extensions::init::_usage
                    return 2
                    ;;
            esac
        done
    }

    function ops::extensions::init::_main() {
        local ext_path="${OPSCLI_EXTENSIONS_PATH}"

        writeINF "Initializing extensions repo at ${ext_path}"
        mkdir -p "${ext_path}/demo"

        # write demo function
        cat > "${ext_path}/demo/hello.sh" <<'DEMOEOF'
#!/bin/bash

function ops::demo::hello() {
#-- START CHEAT --
#  Function: ops::demo::hello
#    Alias:  ops-hello
#    Description: Demo function — replace this with your own
#    Parameters:
#      -h | --help   Show help
#      $1            Name to greet (optional)
#-- END CHEAT --

    function ops::demo::hello::_usage() {
        cat <<-EOF
        Demo function. Replace this with your own.

        Usage: ops-hello [-h] [name]

        Options:
          -h, --help    Show this help message and exit

EOF
    }

    function ops::demo::hello::_guardrails() {
        return 0
    }

    function ops::demo::hello::_process-arguments() {
        local arguments=($(ops::common::splitArgs "$@"))
        for (( i=0; i<${#arguments[@]}; i++ )); do
            case ${arguments[i]} in
                -h|--help)
                    ops::demo::hello::_usage
                    return 1
                    ;;
                *)
                    greeting_name="${arguments[i]}"
                    ;;
            esac
        done
    }

    function ops::demo::hello::_main() {
        local name="${greeting_name:-world}"
        writeINF "Hello, ${name}!"
        return 0
    }

    unset greeting_name
    ops::demo::hello::_guardrails "$@" || return $?
    ops::demo::hello::_process-arguments "$@" || return $?
    ops::demo::hello::_main || return $?
}

alias ops-hello='ops::demo::hello'
DEMOEOF

        cd "${ext_path}"
        git init -q
        git add .
        git commit -q -m "initial commit — demo function"
        cd - > /dev/null

        writeOK "Extensions repo created at ${ext_path}"
        writeINF \
"Next steps:

  1. Reload your shell to pick up the demo function:
       ops-reload

  2. Try the demo:
       ops-hello
       ops-hello YourName

  3. Add your own functions under ${ext_path}/<subfolder>/<name>.sh
     and run ops-reload to load them."
        return 0
    }

    ops::extensions::init::_guardrails "$@" || return $?
    ops::extensions::init::_process-arguments "$@" || return $?
    ops::extensions::init::_main || return $?
}

alias ops-init-extensions='ops::extensions::init'
