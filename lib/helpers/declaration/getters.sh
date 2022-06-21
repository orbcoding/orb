_orb_get_args_index() {
  local arg=$1
  declare -n declared_args="_orb_declared_args$(_orb_history_suffix $2)"

  local args_i=0 
  local found=false
  for declared_arg in "${declared_args[@]}"; do
    if [[ $declared_arg == $arg ]]; then
      found=true
      break
    fi

    ((args_i++))
  done

  $found && echo $args_i && return 0
  return 1
}

_orb_arg_is_required() {
  local args_i=$1
  ${_orb_declared_requireds[$args_i]} || return 1
}

_orb_get_arg_comment() {
  local args_i=$1
  if [[ -n "${_orb_declared_comments[$args_i]}" ]]; then
    echo "${_orb_declared_comments[$args_i]}"
  else
    return 1
  fi
}

# sets value to arg_default variable that should be declared local in calling fn
_orb_get_arg_default_arr() {
  local args_i=$1
  local i=${_orb_declared_defaults_indexes[$args_i]}
  [[ -z $i ]] && return 1
  local len=${_orb_declared_defaults_lengths[$args_i]}
  arg_default=( "${_orb_declared_defaults[@]:$i:$len}" )
}

# sets value to arg_in variable that should be declared local in calling fn
_orb_get_arg_in_arr() {
  local args_i=$1
  local i=${_orb_declared_ins_indexes[$args_i]}
  [[ -z $i ]] && return 1
  local len=${_orb_declared_ins_lengths[$args_i]}
  arg_in=( "${_orb_declared_ins[@]:$i:$len}" )
}
