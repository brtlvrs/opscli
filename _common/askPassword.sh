function ops::common::askPassword() {
#-- START CHEAT --
#  Function: ops::common::askPassword
#    Alias:
#    Description: Prompt for a password without echo; supports DEL (backspace) and CTRL+U (clear line)
#    Parameters:
#      (none) — captures keystrokes directly; returns the entered password via stdout
#      Usage: PASSWORD=$(ops::common::askPassword)
#-- END CHEAT --
  # ask for password
  unset PASSWORD
  # Process input one character at a time
  while IFS= read -r -s -n1 char; do
    [[ -z $char ]] && { printf '\n'> /dev/tty; break; } # ENTER pressed
    if [[ $char == $'\x7f' ]]; then # backscape was pressed
      if [[ "x$PASSWORD" != "x" ]]; then
        PASSWORD=${PASSWORD%?}
        printf '\b \b' > /dev/tty
      fi
      continue
    fi
    if [[ $char == $'\x15' ]]; then # detect CTRL+U
      while [[ -n $PASSWORD ]]; do
        PASSWORD=${PASSWORD%?}
        printf '\b \b'  > /dev/tty
      done
      continue
    fi
    # no 'weird' input, store character
      PASSWORD+=$char
      printf '*' > /dev/tty
  done
  echo "${PASSWORD}"
  unset PASSWORD
  }
