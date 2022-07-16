declare -a _orb_available_arg_options=( Comment: Required: Default: In: Catch: )
declare -a _orb_available_arg_options_boolean_flag=( Comment: Required: Default: )
declare -a _orb_available_arg_options_array_arg=( Comment: Required: Default: Catch: )
declare -a _orb_available_arg_option_catch_values=( flag block dash )
declare -a _orb_available_arg_option_required_values=( true false )

_orb_is_available_option() {
	[[ " ${_orb_available_arg_options[@]} " =~ " $1 " ]]
}

_orb_is_available_boolean_flag_option() {
	[[ " ${_orb_available_arg_options_boolean_flag[@]} " =~ " $1 " ]]
}

_orb_is_available_array_option() {
	[[ " ${_orb_available_arg_options_array_arg[@]} " =~ " $1 " ]]
}

_orb_is_available_catch_value() {
	[[ " ${_orb_available_arg_option_catch_values[@]} " =~ " $1 " ]]
}

_orb_is_available_required_value() {
	[[ " ${_orb_available_arg_option_required_values[@]} " =~ " $1 " ]]
}

_orb_has_declared_arg() {
  local arg=$1
	declare -n declared_args="_orb_declared_args$_orb_variable_suffix"
	[[ " ${declared_args[@]} " =~ " $arg " ]]
}

_orb_has_declared_boolean_flag() { # $1 arg
	local arg=$1
	! (_orb_has_declared_arg $arg && orb_is_any_flag $arg) && return 1
	declare -n suffixes="_orb_declared_arg_suffixes$_orb_variable_suffix"
  [[ -z ${suffixes[$arg]} ]]
}

_orb_has_declared_flagged_arg() { # $1 arg
	local arg=$1
	! _orb_has_declared_arg $arg && return 1
	
	declare -n suffixes="_orb_declared_arg_suffixes$_orb_variable_suffix"
	[[ -n ${suffixes[$arg]} ]]
}

_orb_has_declared_array() {
	local arg=$1 

	if orb_is_any_flag $arg; then
		local suffix=${_orb_declared_arg_suffixes[$arg]}
		if orb_is_nr $suffix && (( $suffix > 1 )); then 
			return 0
		fi
	elif orb_is_dash $arg || orb_is_rest $arg || orb_is_block $arg; then
		return 0
	fi
	 
	return 1
}

_orb_arg_is_required() {
	local arg=$1
  [[ ${_orb_declared_requireds[$arg]} == true ]] && return 0
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
  local i=${_orb_declared_defaults_start_indexes[$arg]}
  [[ -z $i ]] && return 1
  local len=${_orb_declared_defaults_lengths[$arg]}
  arg_default=( "${_orb_declared_defaults[@]:$i:$len}" )
}

# sets value to arg_in variable that should be declared local in calling fn
_orb_get_arg_in_arr() {
  local arg=$1
  local i=${_orb_declared_ins_start_indexes[$arg]}
  [[ -z $i ]] && return 1
  local len=${_orb_declared_ins_lengths[$arg]}
  arg_in=( "${_orb_declared_ins[@]:$i:$len}" )
}

# sets value to arg_catch variable that should be declared local in calling fn
_orb_get_arg_catch_arr() {
  local arg=$1
  local i="${_orb_declared_catchs_start_indexes[$arg]}"
  [[ -z $i ]] && return 1
  local len=${_orb_declared_catchs_lengths[$arg]}
  arg_catch=( "${_orb_declared_catchs[@]:$i:$len}" )
}


_orb_arg_catches() { # $1 arg
	local arg=$1
	local value=$2
	local arg_catch; _orb_get_arg_catch_arr $arg

	if orb_is_flag $2; then
		! [[ " ${arg_catch[@]} " =~ " flag " ]] && return 1
	elif orb_is_block $2; then
		! [[ " ${arg_catch[@]} " =~ " block " ]] && return 1
	elif orb_is_dash $2; then
		! [[ " ${arg_catch[@]} " =~ " dash " ]] && return 1
	fi
	
	return 0
}
