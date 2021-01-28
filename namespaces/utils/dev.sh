# pass_flags
declare -A pass_flags_args=(
	['*']='flags to pass; ACCEPTS_FLAGS'
); function pass_flags() { # pass caller functions flags with values if recieved
  [[ -z $_caller_function_name ]] && orb -c utils raise_error 'must be used from within a caller function'
  [[ ! -v _caller_args_declaration[@] ]] && orb -c utils raise_error "$_caller_function_descriptor has no arguments to pass"

  pass=()
  local arg; for arg in "$@"; do
    if _is_flag "$arg"; then
      pass_flag "$arg"
    else
      orb -c utils raise_error "$arg not a flag"
    fi
  done

  echo "${pass[@]}"
}

pass_flag() { # $1 = flag arg/args
  local flags=()

  if _is_verbose_flag "$1"; then
    flags+=( "$1" )
  else
    flags+=( $(echo "${1:1}" | grep -o .) )
  fi

  local flag; for flag in ${flags[@]}; do
    if [[ ${_caller_args["-$flag"]} == true ]]; then
      # has flag == true
      pass+=( "-$flag" )
    elif [[ -n ${_caller_args["-$flag arg"]+x} ]]; then
      # has "flag arg"
      if [[ -z ${_caller_args["-$flag arg"]} ]]; then # empty str
        pass+=( "-$flag" '""')
      else
        pass+=( "-$flag ${_caller_args["-$flag arg"]}" )
      fi
    elif [[ -z ${_caller_args_declaration["-$flag"]+x} && -z ${_caller_args_declaration["-$flag arg"]+x} ]]; then
      # flag never declared
      orb -c utils raise_error "'-$flag' not in $_caller_function_descriptor args declaration\n\n$(_print_args_explanation _caller_args_declaration)"
    fi
  done
}

# raise_error
declare -A raise_error_args=(
  ['1']='error_message; DEFAULT: ""; ACCEPTS_EMPTY_STRING'
  ['-d arg']='descriptor; DEFAULT: $_caller_function_descriptor|$_function_descriptor;'
  ['-t']='trace; DEFAULT: true'
); function raise_error() { # Raise pretty error msg and kill namespace
  orb -c utils print_error $(orb -c utils pass_flags -d) "$1"
  ${_args[-t]} && print_stack_trace >&2
  kill_script
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

# kill_script
# https://stackoverflow.com/a/14152313
function kill_script() { # kill script
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

# print_args
function print_args() { # print collected arguments, useful for debugging
	declare -A | grep 'A _caller_args=' | cut -d '=' -f2-
	[[ ${_caller_args["*"]} == true ]] && echo "[*]=${_caller_args_wildcard[*]}"
}
