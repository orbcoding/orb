# passflags
declare -A passflags_args=(
	['*']='flags to pass; CAN_START_WITH_FLAG'
); function passflags() { # pass functions flags with values if recieved
  pass=()

  for arg in "$@"; do
    if [[ ${args_caller[$arg]} == true ]]; then
      pass+=( $arg )
    elif [[ -n ${args_caller[$arg]} ]] && orb utils is_flag_with_arg "$arg"; then
      # if non empty and argument ends with ' arg'
      pass+=( "${arg/ arg/} ${args_caller[$arg]}" )
    fi
  done

  echo "${pass[@]}" | xargs # trim whitespace
}

function print_args() { # print collected arguments, useful for debugging
	declare -A | grep 'A caller_args=' | cut -d '=' -f2-
	[[ ${caller_args["*"]} == true ]] && echo "[*]=${caller_args_wildcard[*]}"
}


declare -A echoerr_args=(
  ['*']='msg;' # CAN_START_WITH_FLAG'
); function echoerr() { # echo to stderr, useful for debugging functions that return values in stdout
  echo "$@" >&2
}

# https://stackoverflow.com/a/14152313
function kill_script() { # exits entire script
  kill -PIPE 0
}


declare -A error_args=(
	['1']='message'
); function error() { # print formated error
	msg=( "$(orb text red)$(orb text bold)Error:$(orb text normal)" )
	if [[ $script_name == 'error' && -n ${caller_script_name} && -n ${caller_function_name} ]]; then
    script=$caller_script_name
    fn=$caller_function_name
  else
    script=$script_name
    fn=$function_name
	fi
  script_msg=$script
  [[ -n $fn ]] && script_msg+="->$(orb text bold)${fn}" || script_msg+=' is script tag -'
  [[ -n $script_msg ]] && msg+=( "$script_msg" )

	msg+=( $(orb text normal)$1 )
	echo -e "${msg[*]}" >&2
};
