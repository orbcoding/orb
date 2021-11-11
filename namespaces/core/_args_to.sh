# _args_to
declare -A _args_to_args=(
  ['-a arg']='array name where to append args'
  ['-s']='skip: flag before flagged arg, block marks, "--" before "-- *"'
  ['-x']='expand/exec array/cmd after adding args to -a arg array"'
  ['*']='array/cmd elements; OPTIONAL; CATCH_ANY'
	['-- *']='flags to pass;'
); function _args_to() { # Pass commands to arr eg: cmd=( my__cmd ); _args_to my__cmd -- -fs 1 2 *
  source orb

  if [[ -n "${_args['-a arg']}" ]]; then
    # if _is_empty_arr "${_args['-a arg']}"; then
    #   _raise_error "array empty, ${_args['-a arg']}"
    # else
    declare -n __cmd="${_args['-a arg']}"
    ${_args['*']} && __cmd+=("${_args_wildcard[@]}")
    # fi
  elif ${_args['*']}; then
    # wildcards to be executed
    declare -n __cmd=_args_wildcard
  else
    _raise_error "-a arg or * required" 
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

  if [[ -n "${_args['-a arg']}" ]]; then
    # With -a arg -x has to be explicitly added to exec
    [[ ${_args['-x']} == true ]] && "${__cmd[@]}"
  else
    # Without -a arg always exec
    "${__cmd[@]}"
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
      __cmd+=( "$_flag" )
    elif _declared_flagged_arg "$_flag" _caller_args_declaration; then
      # declared flag with arg
      if [[ -n ${_caller_args["$_flag arg"]+x} ]]; then
        ! ${_args[-s]} && __cmd+=( "$_flag" )
        __cmd+=( "${_caller_args["$_flag arg"]}" )
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
  __cmd+=( "${_to_add[@]}" )
}

_args_to_pass_nr() { # $1 = nr arg
  _declared_inline_arg "$1" _caller_args_declaration || _raise_undeclared "$1"
  [[ -n ${_caller_args["$1"]+x} ]] && \
  __cmd+=( "${_caller_args["$1"]}" )
}


_args_to_pass_wildcard() {
  _declared_wildcard _caller_args_declaration || _raise_undeclared "*"
  ${_caller_args['*']} && \
  __cmd+=( "${_caller_args_wildcard[@]}" )
}

_args_to_pass_dash_wildcard() {
  _declared_dash_wildcard _caller_args_declaration || _raise_undeclared "-- *"
  ${_caller_args['-- *']} || return
  ${_args[-s]} || __cmd+=( '--' )
  __cmd+=( "${_caller_args_dash_wildcard[@]}" )
}

