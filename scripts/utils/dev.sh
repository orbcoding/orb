# passflags
declare -A passflags_args=(
	['*']='flags to pass; CAN_START_WITH_FLAG'
); function passflags() { # pass functions flags with values if recieved
  pass=()

  for arg in "$@"; do
    if [[ ${parent_args[$arg]} == true ]]; then
      pass+=( $arg )
    elif [[ -n ${parent_args[$arg]} ]] && orb utils is_flag_with_arg "$arg"; then
      # if non empty and argument ends with ' arg'
      pass+=( "${arg/ arg/} ${parent_args[$arg]}" )
    fi
  done

  echo "${pass[@]}" | xargs # trim whitespace
}

function print_args() { # print collected arguments, useful for debugging
	declare -A | grep 'A args=' | cut -d '=' -f2-
	[[ ${args["*"]} == true ]] && echo "[*]=${args_wildcard[*]}"
}


declare -A echoerr_args=(
  ['*']='msg'
); function echoerr() { # echo to stderr, useful for debugging functions that return values in stdout
  echo "$@" >&2
}


declare -A error_args=(
	['1']='message'
); function error() { # print formated error
	msg=( "$(orb text red)$(orb text bold)Error:$(orb text reset)" )
	if [[ -n ${parent_script_name} && -n ${parent_function_name} ]]; then
    script=$parent_script_name
    fn=$parent_function_name
  else
    script=$script_name
    fn=$function_name
	fi
  msg+=( "${script}->$(orb text bold)${fn}" )
	msg+=( $(orb text reset)$1 )
	echo -e ${msg[*]}
};
