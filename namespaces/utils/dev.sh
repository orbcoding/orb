# passflags
declare -A passflags_args=(
	['*']='flags to pass; ACCEPTS_FLAGS'
); function passflags() { # pass caller functions flags with values if recieved
  [[ -z $_caller_function_name ]] && orb -c utils raise_error 'must be used from within a caller function'
  [[ ! -v _caller_args_declaration[@] ]] && orb -c utils raise_error "$_caller_function_descriptor has no arguments to pass"
  pass=()

  for arg in "$@"; do
    if [[ -z ${_caller_args_declaration["$arg"]+abc} ]]; then
      orb -c utils raise_error "'$arg' not in $_caller_function_descriptor args declaration\n\n$(_print_args_explanation _caller_args_declaration)"
    elif [[ ${_caller_args["$arg"]} == true ]]; then
      pass+=( "$arg" )
    elif [[ -n ${_caller_args["$arg"]+abc} ]] && _is_flag_with_arg "$arg"; then
      # if non empty and argument ends with ' arg'
      pass+=( "${arg/ arg/} ${_caller_args["$arg"]}" )
    fi
  done

  echo "${pass[@]}" | xargs # trim whitespace
}

# print_args
function print_args() { # print collected arguments, useful for debugging
	declare -A | grep 'A _caller_args=' | cut -d '=' -f2-
	[[ ${_caller_args["*"]} == true ]] && echo "[*]=${_caller_args_wildcard[*]}"
}

# raise_error
declare -A raise_error_args=(
  ['1']='error_message; ACCEPTS_FLAGS'
  ['-d arg']='descriptor; DEFAULT: $_caller_function_descriptor|$_function_descriptor'
  ['-t']='trace; DEFAULT: true'
); function raise_error() { # Raise pretty error msg and kill namespace
  orb -c utils print_error $(orb -c utils passflags "-d arg") "$1"
  ${_args[-t]} && print_stack_trace >&2
  kill_namespace
}

# print_error
declare -A print_error_args=(
	['1']='message; ACCEPTS_FLAGS'
  ['-d arg']='descriptor; DEFAULT: $_caller_function_descriptor|$_function_descriptor'
); function print_error() { # print pretty error
	msg=(
    "$(_red)$(_bold)Error:$(_normal)"
    "${_args[-d arg]}"
    "$1"
  )

	echo -e "${msg[*]}" >&2
};

# kill_namespace
# https://stackoverflow.com/a/14152313
declare -A kill_namespace_args=(

); function kill_namespace() { # kill namespace and dump stack trace
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
