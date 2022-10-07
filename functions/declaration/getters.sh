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

_orb_get_function_option_value() {
  local arg=$1
  local opt=$2
  declare -n value=$3

    case $opt in
      'DirectCall:')
        value="$_orb_declared_direct_call"
        ;;
    esac
}

_orb_get_arg_option_default_value() {
	local arg=$1
  local opt=$2
	declare -n _orb_assign_ref=$3

	case $opt in
		'Required:')
			_orb_assign_ref=$(orb_is_any_flag $arg && echo false || echo true);;
		*)
			_orb_assign_ref=
	esac
}


# If called without assignment param $3 will just check if has value
_orb_get_arg_option_value() {
  local arg=$1
  local opt=$2

  local i=$(orb_index_of $arg _orb_declared_args)
  local start_is=(${_orb_declared_option_start_indexes[$opt]})
  local start_i="${start_is[$i]}"

  # Should always be - if empty but adding -z for sanity when testing
  [[ $start_i == '-' ]] || [[ -z $start_i ]] && return 1
  [[ -z $3 ]] && return 0 

  declare -n _orb_option_value=$3
  local lens=(${_orb_declared_option_lengths[$opt]})
  local len=${lens[$i]}

  _orb_option_value=("${_orb_declared_option_values[@]:$start_i:$len}")
}
