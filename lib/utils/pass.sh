# orb_pass
declare -A orb_pass_args=(
  ['-a arg']='array name where to append args'
  ['-s']='skip: flag before flagged arg, block marks, "--" before "-- *"'
  ['-x']='expand/exec array/cmd after adding args to -a arg array"'
  ['*']='array/cmd elements; OPTIONAL; CATCH_ANY'
	['-- *']='flags to pass;'
); function orb_pass() { # Pass commands to arr eg: cmd=( my__cmd ); orb_pass my__cmd -- -fs 1 2 *
  source orb

  if [[ -n "${_args['-a arg']}" ]]; then
    declare -n __cmd="${_args['-a arg']}"
    ${_args['*']} && __cmd+=("${_orb_wildcard[@]}")
  elif ${_args['*']}; then
    # wildcards to be executed
    declare -n __cmd=_orb_wildcard
  else
    orb_raise_error "-a arg or * required" 
  fi


  [[ -z $_orb_caller_function ]] && orb_raise_error 'must be used from within a caller function'
  [[ ! -v _orb_caller_args_declaration[@] ]] && orb_raise_error "$_orb_caller_function_descriptor has no arguments to pass"

  local _arg; for _arg in "${_orb_dash_wildcard[@]}"; do
    if orb_is_flag "$_arg"; then
      _orb_pass_flag "$_arg"
    elif orb_is_block "$_arg"; then
      _orb_pass_block "$_arg"
    elif orb_is_nr "$_arg"; then
      _orb_pass_nr "$_arg"
    elif [[ "$_arg" == '*' ]]; then
      _orb_pass_wildcard
    elif [[ "$_arg" == '-- *' ]]; then
      _orb_pass_dash_wildcard
    else
      orb_raise_error "$_arg not a flag, block, nr or wildcard"
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

_orb_pass_flag() { # $1 = flag arg/args
  local _flags=()

  if orb_is_verbose_flag "$1"; then
    _flags+=( "$1" )
  else
    _flags+=( $(echo "${1:1}" | grep -o . | sed  s/^/-/g) )
  fi

  local _flag; for _flag in ${_flags[@]}; do
    if _orb_is_declared_boolean_flag "$_flag" _orb_caller_args_declaration; then
      # declared boolean flag
      ${_orb_caller_args["$_flag"]} && \
      __cmd+=( "$_flag" )
    elif _orb_is_declared_flagged_arg "$_flag" _orb_caller_args_declaration; then
      # declared flag with arg
      if [[ -n ${_orb_caller_args["$_flag arg"]+x} ]]; then
        ! ${_args[-s]} && __cmd+=( "$_flag" )
        __cmd+=( "${_orb_caller_args["$_flag arg"]}" )
      fi
    else # undeclared
      _orb_raise_undeclared "$_flag"
    fi
  done
}

_orb_pass_block() {
  _orb_declared_block "$1" _orb_caller_args_declaration || _orb_raise_undeclared "$1"
  ${_orb_caller_args["$1"]} || return
  local _arr_name="$(_orb_block_to_arr_name "$1")"
  declare -n _block_ref=$_arr_name
  local _to_add=()
  _to_add+=("${_block_ref[@]}")
  ${_args[-s]} || _to_add=("$1" "${_to_add[@]}" "$1") 
  __cmd+=( "${_to_add[@]}" )
}

_orb_pass_nr() { # $1 = nr arg
  _orb_declared_inline_arg "$1" _orb_caller_args_declaration || _orb_raise_undeclared "$1"
  [[ -n ${_orb_caller_args["$1"]+x} ]] && \
  __cmd+=( "${_orb_caller_args["$1"]}" )
}


_orb_pass_wildcard() {
  _orb_declared_wildcard _orb_caller_args_declaration || _orb_raise_undeclared "*"
  ${_orb_caller_args['*']} && \
  __cmd+=( "${_orb_caller_wildcard[@]}" )
}

_orb_pass_dash_wildcard() {
  _orb_declared_dash_wildcard _orb_caller_args_declaration || _orb_raise_undeclared "-- *"
  ${_orb_caller_args['-- *']} || return
  ${_args[-s]} || __cmd+=( '--' )
  __cmd+=( "${_orb_caller_dash_wildcard[@]}" )
}

