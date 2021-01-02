declare -A passflags_args=(
	['*']='flags to pass'
); function passflags() { # pass functions flags with values if recieved
  pass=""

  for arg in "$@"; do
    if [[ ${args[$arg]} == true ]]; then
      pass+=" $arg"
    elif [[ -n ${args[$arg]} ]] && is_flag_with_arg "$arg"; then
      # if non empty and argument ends with ' arg'
      pass+=" ${arg/ arg/} ${args[$arg]}"
    fi
  done

  echo "$pass" | xargs # trim whitespace
}
