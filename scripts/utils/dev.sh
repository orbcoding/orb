# passflags
declare -A passflags_args=(
	['*']='flags to pass; CAN_START_WITH_FLAG'
); function passflags() { # pass caller functions flags with values if recieved
  [[ -z $orb_caller_function_name ]] && orb utils raise_error 'must be used from within a caller function'
  [[ ! -v orb_caller_args_declaration[@] ]] && orb utils raise_error "$orb_caller_descriptor has no arguments to pass"
  pass=()

  for arg in "$@"; do
    if [[ -z ${orb_caller_args_declaration["$arg"]+abc} ]]; then
      orb utils raise_error "'$arg' not in $orb_caller_descriptor args declaration\n\n${orb_caller_args_explanation}"
    elif [[ ${orb_caller_args["$arg"]} == true ]]; then
      pass+=( "$arg" )
    elif [[ -n ${orb_caller_args["$arg"]+abc} ]] && orb utils is_flag_with_arg "$arg"; then
      # if non empty and argument ends with ' arg'
      pass+=( "${arg/ arg/} ${orb_caller_args["$arg"]}" )
    fi
  done

  echo "${pass[@]}" | xargs # trim whitespace
}

# print_args
function printargs() { # print collected arguments, useful for debugging
	declare -A | grep 'A orb_caller_args=' | cut -d '=' -f2-
	[[ ${orb_caller_args["*"]} == true ]] && echo "[*]=${orb_caller_args_wildcard[*]}"
}

# echoerr
declare -A echoerr_args=(
  ['*']='msg; CAN_START_WITH_FLAG'
); function echoerr() { # echo to stderr, useful for debugging functions that return values in stdout
  echo "$@" >&2
}

# raise_error
declare -A raise_error_args=(
  ['1']='error_message; CAN_START_WITH_FLAG'
  ['-p arg']='script_function_path; DEFAULT: $orb_caller_script_function_path'
); function raise_error() { # Raise pretty error msg and kill script
  orb utils print_error "$1" $(orb utils passflags "-p arg") && orb utils kill_script
}

# print_error
declare -A print_error_args=(
	['1']='message; CAN_START_WITH_FLAG'
  ['-p arg']='script_function_path; DEFAULT: $orb_caller_script_function_path'
); function print_error() { # print pretty error
	msg=(
    "$(orb text red)$(orb text bold)Error:$(orb text normal)"
    "${args[-p arg]}"
    "$1"
  )

	echo -e "${msg[*]}" >&2
};

# kill_script
# https://stackoverflow.com/a/14152313
function kill_script() { # kill script and dump stack trace
  orb utils print_stack_trace >&2
  kill -PIPE 0
}

# print_stack_trace
function print_stack_trace() {
  local i=0
  local line_no
  local function_name
  local file_name
  echo
  while caller $i; do ((i++)); done | while read line_no function_name file_name; do
    [[ $function_name == 'orb' ]] && continue
    echo -e "$file_name:$line_no\t$function_name"
  done
}
