_orb_get_declared_number_args_in_order() {
    local _orb_internal_nrs=()
    declare -n _orb_assign_ref=$1

    local _orb_arg; for _orb_arg in "${_orb_declared_args[@]}"; do
      orb_is_nr $_orb_arg && _orb_internal_nrs+=( $_orb_arg )
    done

    IFS=$'\n' _orb_assign_ref=($(sort <<<"${_orb_internal_nrs[*]}")); unset IFS
}

_orb_get_arg_comment() {
  local arg=$1
  if [[ -n "${_orb_declared_comments[$arg]}" ]]; then
    echo "${_orb_declared_comments[$arg]}"
  else
    return 1
  fi
}

# sets value to arg_default variable that should be declared local in calling fn
_orb_get_arg_default_arr() {
  local arg=$1
	declare -n assign_ref=$2
  local i=${_orb_declared_defaults_start_indexes[$arg]}
  [[ -z $i ]] && return 1
  local len=${_orb_declared_defaults_lengths[$arg]}
  assign_ref=( "${_orb_declared_defaults[@]:$i:$len}" )
}

# sets value to arg_in variable that should be declared local in calling fn
_orb_get_arg_in_arr() {
  local arg=$1
	declare -n assign_ref=$2
  local i=${_orb_declared_ins_start_indexes[$arg]}
  [[ -z $i ]] && return 1
  local len=${_orb_declared_ins_lengths[$arg]}
  assign_ref=( "${_orb_declared_ins[@]:$i:$len}" )
}

# sets value to arg_catch variable that should be declared local in calling fn
_orb_get_arg_catch_arr() {
  local arg=$1
	declare -n assign_ref=$2
  local i="${_orb_declared_catchs_start_indexes[$arg]}"
  [[ -z $i ]] && return 1
  local len=${_orb_declared_catchs_lengths[$arg]}
	assign_ref=( "${_orb_declared_catchs[@]:$i:$len}" )
}
