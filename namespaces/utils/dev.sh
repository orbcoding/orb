# args_to_arr
declare -A args_to_arr_args=(
  ['1']='array'
	['*']='flags to pass; ACCEPTS_FLAGS'
); function args_to_arr() { # `eval $(orb utils args_to_arr arr_name -f --v-flag 1 2 *)` to pass args to array _arr_name
  local arr_name=$1

  [[ -z $_caller_function_name ]] && orb -c utils raise_error 'must be used from within a caller function'
  [[ ! -v _caller_args_declaration[@] ]] && orb -c utils raise_error "$_caller_function_descriptor has no arguments to cmd"

  if [[ -v "${arr_name}[@]" ]]; then
    cmd=( "$arr_name+=(" ) # append to if arr exists
  else
    cmd=( "$arr_name=(" )
  fi

  local arg; for arg in "${_args_wildcard[@]}"; do
    if _is_flag "$arg"; then
      flags_to_arr "$arg"
    elif _is_nr "$arg"; then
      [[ -n ${_caller_args["$arg"]+x} ]] && \
      cmd+=( '"${_args['$arg']}"' )
    elif [[ "$arg" == '*' ]]; then
      [[ ${_caller_args['*']} == true ]] && \
      cmd+=( '"${_args_wildcard[@]}"' )
    else
      orb -c utils raise_error "$arg not a flag, nr or *"
    fi
  done

  cmd+=( ')' )

  echo "${cmd[@]}"
}

flags_to_arr() { # $1 = flag arg/args
  local flags=()

  if _is_verbose_flag "$1"; then
    flags+=( "$1" )
  else
    flags+=( $(echo "${1:1}" | grep -o . | sed  s/^/-/g) )
  fi

  local flag; for flag in ${flags[@]}; do
    if [[ -n ${_caller_args_declaration["$flag"]+x} ]]; then
      # declared boolean flag
      [[ ${_caller_args["$flag"]} == true ]] && \
      cmd+=( "$flag" )
    elif [[ -n ${_caller_args_declaration["$flag arg"]+x} ]]; then
      # declared flag with arg
      [[ -n ${_caller_args["$flag arg"]+x} ]] && \
      cmd+=( "$flag "'"${_args["'"$flag arg"'"]}"' )
    else # undeclared
      orb -c utils raise_error "'$flag' not in $_caller_function_descriptor args declaration\n\n$(_print_args_explanation _caller_args_declaration)"
    fi
  done
}

# raise_error
declare -A raise_error_args=(
  ['1']='error_message; DEFAULT: ""; ACCEPTS_EMPTY_STRING'
  ['-d arg']='descriptor; DEFAULT: $_caller_function_descriptor|$_function_descriptor;'
  ['-t']='trace; DEFAULT: true'
); function raise_error() { # Raise pretty error msg and kill namespace
  cmd=( orb -c utils print_error )
  eval $(orb utils args_to_arr cmd -d 1)
  "${cmd[@]}"
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
