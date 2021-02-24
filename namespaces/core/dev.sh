# _raise_error
declare -A _raise_error_args=(
  ['1']='error_message;'
  ['-d arg']='descriptor; DEFAULT: $_caller_function_descriptor|$_function_descriptor;'
  ['-t']='trace; DEFAULT: true'
); function _raise_error() { # Raise pretty error msg and kill namespace
  source "$_orb_dir/core/ensure_core_cmd_orb_handled.sh" core $FUNCNAME "$@"

  cmd=( _print_error )
  _args_to cmd -x -- -d 1 # not using -x as would change caller_info
  ${_args[-t]} && _print_stack_trace >&2
  _kill_script
}

# _print_error
declare -A _print_error_args=(
	['1']='message; ACCEPTS_FLAGS;'
  ['-d arg']='descriptor; DEFAULT: $_caller_function_descriptor|$_function_descriptor'
); function _print_error() { # print pretty error
  source "$_orb_dir/core/ensure_core_cmd_orb_handled.sh" core $FUNCNAME "$@"

	msg=(
    "$(_red)$(_bold)Error:$(_normal)"
    "${_args[-d arg]}"
    "${_args[1]}"
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
  local _i=0
  local _line_no
  local _function_name
  local _file_name
  echo
  while caller $_i; do ((_i++)); done | while read _line_no _function_name _file_name; do
    echo -e "$_file_name:$_line_no\t$_function_name"
  done
}

# _print_args
function _print_args() { # print collected arguments, useful for debugging
  source "$_orb_dir/core/ensure_core_cmd_orb_handled.sh" core $FUNCNAME "$@"
	declare -A | grep 'A _caller_args=' | cut -d '=' -f2-
	if [[ ${_caller_args["*"]} == true ]] || ${_caller_args["-- *"]} == true ]]; then
    echo "[*]=${_caller_args_wildcard[*]}"
  fi
}

# _ee
declare -A _ee_args=(
  ['*']='msg; ACCEPTS_FLAGS'
); function _ee() { # echo to stderr, useful for debugging without polluting stdout
  echo "$@" >&2
}

# _args_to
declare -A _args_to_args=(
  ['1']='array_name;'
  ['-s']='skip flag before flag arg, and "--" before "-- *"'
  ['-x']='expand/exec array after adding args: "${array_name[@]}"'
	['-- *']='flags to pass;'
); function _args_to() { # cmd=( my_cmd ); _args_to my_cmd -- -fs --v-flag 1 2 *
  source "$_orb_dir/core/ensure_core_cmd_orb_handled.sh" core $FUNCNAME "$@"

  declare -n _cmd=${_args[1]}

  [[ -z $_caller_function_name ]] && _raise_error 'must be used from within a caller function'
  [[ ! -v _caller_args_declaration[@] ]] && _raise_error "$_caller_function_descriptor has no arguments to pass"

  local _arg; for _arg in "${_args_wildcard[@]}"; do
    if _is_flag "$_arg"; then
      _args_to_pass_flag "$_arg"
    elif _is_nr "$_arg"; then
      _args_to_pass_nr "$_arg"
    elif [[ "$_arg" == '*' || "$_arg" == '-- *' ]]; then
      _args_to_pass_wildcard "$_arg"
    else
      _raise_error "$_arg not a flag, nr or wildcard"
    fi
  done

  ${_args[-x]} && "${_cmd[@]}"
}

_args_to_pass_flag() { # $1 = flag arg/args
  local _flags=()

  if _is_verbose_flag "$1"; then
    _flags+=( "$1" )
  else
    _flags+=( $(echo "${1:1}" | grep -o . | sed  s/^/-/g) )
  fi

  local _flag; for _flag in ${_flags[@]}; do
    if [[ -n ${_caller_args_declaration["$_flag"]+x} ]]; then
      # declared boolean flag
      [[ ${_caller_args["$_flag"]} == true ]] && \
      _cmd+=( "$_flag" )
    elif [[ -n ${_caller_args_declaration["$_flag arg"]+x} ]]; then
      # declared flag with arg
      if [[ -n ${_caller_args["$_flag arg"]+x} ]]; then
        ! ${_args[-s]} && _cmd+=( "$_flag" )
        _cmd+=( "${_caller_args["$_flag arg"]}" )
      fi
    else # undeclared
      _raise_error "'$_flag' not in $_caller_function_descriptor args declaration\n\n$(__print_args_explanation _caller_args_declaration)"
    fi
  done
}

_args_to_pass_nr() { # $1 = nr arg
  [[ -n ${_caller_args["$_arg"]+x} ]] && \
  _cmd+=( "${_caller_args["$_arg"]}" )
}


_args_to_pass_wildcard() { # $1 == wildcard arg
  [[ ${_caller_args['*']} == true || ${_caller_args['-- *']} == true ]] && \
  _cmd+=( "${_caller_args_wildcard[@]}" )
}
