# passflags
declare -A passflags_args=(
	['*']='flags to pass; CAN_START_WITH_FLAG'
); function passflags() { # pass caller functions flags with values if recieved
  [[ -z $_orb_caller_function_name ]] && orb utils -dc raise_error 'must be used from within a caller function'
  [[ ! -v _orb_caller_args_declaration[@] ]] && orb utils -dc raise_error "$_orb_caller_function_descriptor has no arguments to pass"
  pass=()

  for arg in "$@"; do
    if [[ -z ${_orb_caller_args_declaration["$arg"]+abc} ]]; then
      orb -dc utils raise_error "'$arg' not in $_orb_caller_function_descriptor args declaration\n\n$(_print_args_explanation _orb_caller_args_declaration)"
    elif [[ ${_orb_caller_args["$arg"]} == true ]]; then
      pass+=( "$arg" )
    elif [[ -n ${_orb_caller_args["$arg"]+abc} ]] && _is_flag_with_arg "$arg"; then
      # if non empty and argument ends with ' arg'
      pass+=( "${arg/ arg/} ${_orb_caller_args["$arg"]}" )
    fi
  done

  echo "${pass[@]}" | xargs # trim whitespace
}

# print_args
function printargs() { # print collected arguments, useful for debugging
	declare -A | grep 'A _orb_caller_args=' | cut -d '=' -f2-
	[[ ${_orb_caller_args["*"]} == true ]] && echo "[*]=${_orb_caller_args_wildcard[*]}"
}

# raise_error
declare -A raise_error_args=(
  ['1']='error_message; CAN_START_WITH_FLAG'
); function raise_error() { # Raise pretty error msg and kill script
  print_error "${_orb_caller_function_descriptor-"$_function_descriptor"}" "$1" && kill_script
}

# print_error
declare -A print_error_args=(
	['1']='descriptor'
	['2']='message; CAN_START_WITH_FLAG'
); function print_error() { # print pretty error
	msg=(
    "$(_red)$(_bold)Error:$(_normal)"
    "$1"
    "$2"
  )

	echo -e "${msg[*]}" >&2
};

# kill_script
# https://stackoverflow.com/a/14152313
function kill_script() { # kill script and dump stack trace
  print_stack_trace >&2
  kill -PIPE 0
}

# print_stack_trace
function print_stack_trace() {
  local i=0
  local line_no
  local function_name
  local file_name
  echo
  while caller $i; do ((i++)); done | while read _line_no _function_name _file_name; do
    echo -e "$_file_name:$_line_no\t$_function_name"
  done
}
