# orb_ee
declare -A orb_ee_args=(
  ['*']='msg; CATCH_ANY'
); function orb_ee() { # echo to stderr, useful for debugging without polluting stdout
  echo "$@" >&2
}

# orb_print_args
function orb_print_args() { # print collected arguments, useful for debugging
  source $orb

  local _orb_history_index=$1

  if [[ -n $_orb_history_index ]]; then
    (( _orb_history_index-- ))
  else
    _orb_history_index=0
  fi

  _orb_variable_suffix=_history_$_orb_history_index

  declare -n _orb_declared_args_ref=_orb_declared_args$_orb_variable_suffix
  [[ -z "${_orb_declared_args_ref[@]}" ]] && return 1

	declare -n _orb_function_descriptor_ref=_orb_function_descriptor$_orb_variable_suffix
  declare -n _orb_declared_vars_ref=_orb_declared_vars$_orb_variable_suffix
  declare -n _orb_declared_comments_ref=_orb_declared_comments$_orb_variable_suffix
  declare -n _orb_declared_arg_suffixes_ref=_orb_declared_arg_suffixes$_orb_variable_suffix

  echo -e "$_orb_function_descriptor_ref - Received argument values:\n"

  local _orb_msg="$(orb_bold)§Variable:§Value:$(orb_normal)\n"

  local _orb_arg; for _orb_arg in ${_orb_declared_args_ref[@]}; do
    if _orb_has_declared_flagged_arg $_orb_arg; then
      _orb_print_arg="$_orb_arg ${_orb_declared_arg_suffixes_ref[$_orb_arg]}"
    else
      _orb_print_arg=$_orb_arg
    fi

    local _orb_value=(); _orb_get_arg_value $_orb_arg _orb_value

    local _orb_var=${_orb_declared_vars_ref[$_orb_arg]}
    local _orb_comment="${_orb_declared_comments_ref[$_orb_arg]}"
    _orb_msg+="$_orb_print_arg§$_orb_var§${_orb_value[@]}\n"
  done

  echo -e "$_orb_msg" | sed 's/^/  /' | column -t -s '§'
}

