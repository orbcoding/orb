# _raise_error
declare -A _raise_error_args=(
  ['1']='error_message'
  ['-d arg']='descriptor; DEFAULT: $_caller_function_descriptor|$_function_descriptor;'
  ['-t']='trace; DEFAULT: true'
); function _raise_error() { # Raise pretty error msg and kill namespace
  if ! _got_orb_prefix; then orb core $FUNCNAME "$@"; return; fi

  cmd=( orb core _print_error )
  orb core _args_to cmd -x -- -d 1 # not using -x as would change caller_info
  ${_args[-t]} && _print_stack_trace >&2
  _kill_script
}

# _print_error
declare -A _print_error_args=(
	['1']='message; ACCEPTS_FLAGS'
  ['-d arg']='descriptor; DEFAULT: $_caller_function_descriptor|$_function_descriptor'
); function _print_error() { # print pretty error
  if ! _got_orb_prefix; then orb core $FUNCNAME "$@"; return; fi

	msg=(
    "$(_red)$(_bold)Error:$(_normal)"
    "${_args[-d arg]}"
    "$1"
  )

	echo -e "${msg[*]}" >&2
};

# _kill_script
# https://stackoverflow.com/a/14152313
function _kill_script() { # kill script
  kill -PIPE 0
}

# _print_stack_trace
function _print_stack_trace() {
  local i=0
  local line_no
  local function_name
  local file_name
  echo
  while caller $i; do ((i++)); done | while read _line_no _function_name _file_name; do
    echo -e "$_file_name:$_line_no\t$_function_name"
  done
}

# _print_args
function _print_args() { # print collected arguments, useful for debugging
	declare -A | grep 'A _caller_args=' | cut -d '=' -f2-
	[[ ${_caller_args["*"]} == true ]] && echo "[*]=${_caller_args_wildcard[*]}"
}

# _echoerr
declare -A _echoerr_args=(
  ['*']='msg; ACCEPTS_FLAGS'
); function _echoerr() { # echo to stderr, useful for debugging without polluting stdout
  echo "$@" >&2
}

# _args_to
declare -A _args_to_args=(
  ['1']='array_name;'
  ['-s']='skip flag before flag arg, and "--" before "-- *"'
  ['-x']='expand/exec array after adding args: "${array_name[@]}"'
	['-- *']='flags to pass;'
); function _args_to() { # cmd=( my_cmd ); orb core _args_to my_cmd -- -fs --v-flag 1 2 *
  if ! _got_orb_prefix; then orb core $FUNCNAME "$@"; return; fi

  declare -n _cmd=$1

  [[ -z $_caller_function_name ]] && orb core _raise_error 'must be used from within a caller function'
  [[ ! -v _caller_args_declaration[@] ]] && orb core _raise_error "$_caller_function_descriptor has no arguments to pass"

  local arg; for arg in "${_args_wildcard[@]}"; do
    if _is_flag "$arg"; then
      _args_to_pass_flag "$arg"
    elif _is_nr "$arg"; then
      _args_to_pass_nr "$arg"
    elif [[ "$arg" == '*' || "$arg" == '-- *' ]]; then
      _args_to_pass_wildcard "$arg"
    else
      orb core _raise_error "$arg not a flag, nr or wildcard"
    fi
  done

  ${_args[-x]} && "${_cmd[@]}"
}

_args_to_pass_flag() { # $1 = flag arg/args
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
      _cmd+=( "$flag" )
    elif [[ -n ${_caller_args_declaration["$flag arg"]+x} ]]; then
      # declared flag with arg
      [[ -n ${_caller_args["$flag arg"]+x} ]] && \
      ! ${_args[-s]} && cmd+=( "$flag" )
      _cmd+=( "${_caller_args["$flag arg"]}" )
    else # undeclared
      orb core _raise_error "'$flag' not in $_caller_function_descriptor args declaration\n\n$(__print_args_explanation _caller_args_declaration)"
    fi
  done
}

_args_to_pass_nr() { # $1 = nr arg
  [[ -n ${_caller_args["$arg"]+x} ]] && \
  _cmd+=( "${_caller_args["$arg"]}" )
}


_args_to_pass_wildcard() { # $1 == wildcard arg
  [[ ${_caller_args['*']} == true || ${_caller_args['-- *']} == true ]] && \
  _cmd+=( "${_caller_args_wildcard[@]}" )
}
