# _raise_error
declare -A _raise_error_args=(
  ['1']='error_message;'
  ['-d arg']='descriptor; DEFAULT: $_caller_function_descriptor|$_function_descriptor;'
  ['-t']='trace; DEFAULT: true'
); function _raise_error() { # Raise pretty error msg and kill namespace
  source "$_orb_dir/core/ensure_core_cmd_orb_handled.sh" core $FUNCNAME "$@"

  _args_to _print_error -- -d 1 # not using -x as would change caller_info
  ${_args[-t]} && _print_stack_trace >&2
  _kill_script
}

# _print_error
declare -A _print_error_args=(
	['1']='message; CATCH_ANY;'
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

  local _blocks=( $(_declared_blocks _caller_args_declaration) )
  local _block; for _block in "${_blocks[@]}"; do
    declare -n ref="$(_block_to_arr_name "$_block")"
    if [[ ${_caller_args["$_block"]} == true ]]; then
      echo "[$_block]=${ref[*]}"
    fi
  done
  
  # | cut -d '=' -f2-
	if [[ ${_caller_args["*"]} == true || ${_caller_args["-- *"]} == true ]]; then
    echo "[*]=${_caller_args_wildcard[*]}"
    echo "[-- *]=${_caller_args_dash_wildcard[*]}"
  fi
}

# _ee
declare -A _ee_args=(
  ['*']='msg; CATCH_ANY'
); function _ee() { # echo to stderr, useful for debugging without polluting stdout
  echo "$@" >&2
}

# _args_to
declare -A _args_to_args=(
  ['-a arg']='array name where to append args, created if not exists'
  ['-s']='skip flag before flagged arg, block marks, "--" before "-- *"'
  ['-x']='expand/exec array/cmd after adding args: "${array_name[@]}, true unless -a arg"; DEFAULT: unset'
  ['-e']='echo resulting array/cmd'
  ['*']='array/cmd elements; OPTIONAL'
	['-- *']='flags to pass;'
); function _args_to() { # Pass commands to arr eg: cmd=( my_cmd ); _args_to my_cmd -- -fs 1 2 *
  source "$_orb_dir/core/ensure_core_cmd_orb_handled.sh" core $FUNCNAME "$@"

  if [[ -n "${_args['-a arg']}" ]]; then
    if _is_empty_arr "${_args['-a arg']}"; then
      declare -ag "${_args['-a arg']}"
    fi
    declare -n _cmd="${_args['-a arg']}"
    ${_args['*']} && _cmd+=("${_args_wildcard[@]}")
  elif ${_args['*']}; then
    declare -n _cmd=_args_wildcard
  elif ! ${_args['-e']}; then
    _raise_error "-a arg, -e or * required" 
  fi


  [[ -z $_caller_function_name ]] && _raise_error 'must be used from within a caller function'
  [[ ! -v _caller_args_declaration[@] ]] && _raise_error "$_caller_function_descriptor has no arguments to pass"

  local _arg; for _arg in "${_args_dash_wildcard[@]}"; do
    if _is_flag "$_arg"; then
      _args_to_pass_flag "$_arg"
    elif _is_block "$_arg"; then
      _args_to_pass_block "$_arg"
    elif _is_nr "$_arg"; then
      _args_to_pass_nr "$_arg"
    elif [[ "$_arg" == '*' ]]; then
      _args_to_pass_wildcard
    elif [[ "$_arg" == '-- *' ]]; then
      _args_to_pass_dash_wildcard
    else
      _raise_error "$_arg not a flag, block, nr or wildcard"
    fi
  done

  ${_args['-e']} && echo "${_cmd[@]}"

  if [[ -n "${_args['-a arg']}" ]] || ${_args['-e']}; then
    # With -a arg or -e -x has to be explicitly added to exec
    [[ ${_args['-x']} == true ]] && "${_cmd[@]}"
  else
    # Without -a arg or -e +x has to be explicitly added to not exec
    [[ ${_args['-x']} == false ]] || "${_cmd[@]}"
  fi
}

_args_to_pass_flag() { # $1 = flag arg/args
  local _flags=()

  if _is_verbose_flag "$1"; then
    _flags+=( "$1" )
  else
    _flags+=( $(echo "${1:1}" | grep -o . | sed  s/^/-/g) )
  fi

  local _flag; for _flag in ${_flags[@]}; do
    if _declared_flag "$_flag" _caller_args_declaration; then
      # declared boolean flag
      ${_caller_args["$_flag"]} && \
      _cmd+=( "$_flag" )
    elif _declared_flagged_arg "$_flag" _caller_args_declaration; then
      # declared flag with arg
      if [[ -n ${_caller_args["$_flag arg"]+x} ]]; then
        ! ${_args[-s]} && _cmd+=( "$_flag" )
        _cmd+=( "${_caller_args["$_flag arg"]}" )
      fi
    else # undeclared
      _raise_undeclared "$_flag"
    fi
  done
}

_args_to_pass_block() {
  _declared_block "$1" _caller_args_declaration || _raise_undeclared "$1"
  ${_caller_args["$1"]} || return
  local _arr_name="$(_block_to_arr_name "$1")"
  declare -n _block_ref=$_arr_name
  local _to_add=()
  _to_add+=("${_block_ref[@]}")
  ${_args[-s]} || _to_add=("$1" "${_to_add[@]}" "$1") 
  _cmd+=( "${_to_add[@]}" )
}

_args_to_pass_nr() { # $1 = nr arg
  _declared_inline_arg "$1" _caller_args_declaration || _raise_undeclared "$1"
  [[ -n ${_caller_args["$1"]+x} ]] && \
  _cmd+=( "${_caller_args["$1"]}" )
}


_args_to_pass_wildcard() {
  _declared_wildcard _caller_args_declaration || _raise_undeclared "*"
  ${_caller_args['*']} && \
  _cmd+=( "${_caller_args_wildcard[@]}" )
}

_args_to_pass_dash_wildcard() {
  _declared_dash_wildcard _caller_args_declaration || _raise_undeclared "-- *"
  ${_caller_args['-- *']} || return
  ${_args[-s]} || _cmd+=( '--' )
  _cmd+=( "${_caller_args_dash_wildcard[@]}" )
}


