# passflags
declare -A passflags_args=(
	['*']='flags to pass; CAN_START_FLAGGED'
); function passflags() { # pass functions flags with values if recieved
  pass=()

  # orb utils print_args

  for arg in "$@"; do
    if [[ ${caller_args["$arg"]} == true ]]; then
      pass+=( "$arg" )
    elif [[ -n ${caller_args["$arg"]} ]] && orb utils is_flag_with_arg "$arg"; then
      # if non empty and argument ends with ' arg'
      pass+=( "${arg/ arg/} ${caller_args["$arg"]}" )
    fi
  done

  echo "${pass[@]}" | xargs # trim whitespace
}

function print_args() { # print collected arguments, useful for debugging
	declare -A | grep 'A caller_args=' | cut -d '=' -f2-
	[[ ${caller_args["*"]} == true ]] && echo "[*]=${caller_args_wildcard[*]}"
}


declare -A echoerr_args=(
  ['*']='msg;' # CAN_START_FLAGGED'
); function echoerr() { # echo to stderr, useful for debugging functions that return values in stdout
  echo "$@" >&2
}

# https://stackoverflow.com/a/14152313
function kill_script() { # exits entire script
  kill -PIPE 0
}

declare -A raise_error_args=(
  ['1']='message'
); function raise_error() {
  orb utils print_error "$1" && orb utils kill_script
}

declare -A print_error_args=(
	['1']='message'
); function print_error() { # print formated error
	msg=( "$(orb text red)$(orb text bold)Error:$(orb text normal)" )
  script=$caller_script_name
  fn=$caller_function_name
  script_msg=$script
  [[ -n $fn ]] && script_msg+="->$(orb text bold)${fn}" || script_msg+=' is script tag -'
  [[ -n $script_msg ]] && msg+=( "$script_msg" )

	msg+=( "$(orb text normal)$1" )
	echo -e "${msg[*]}" >&2
};
