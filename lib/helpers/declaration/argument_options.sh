_orb_is_available_option() {
	local arg=$1
	local available_options=( Comment: Required: Default: In: )
	[[ " ${available_options[@]} " =~ " $arg " ]]
}

_orb_is_catch_all_option() {
	local arg=$1
	local catch_all_options=( Default: In: )
	[[ " ${catch_all_options[@]} " =~ " $arg " ]]
}

_orb_is_invalid_boolean_flag_option() {
	local arg=$1
	local invalid_boolean_flag_options=( In: )
	[[ " ${invalid_boolean_flag_options[@]} " =~ " $arg " ]]
}

_orb_is_invalid_array_option() {
	local arg=$1
	local invalid_array_options=( In: )
	[[ " ${invalid_array_options[@]} " =~ " $arg " ]]
}


_orb_declared_is_boolean_flag() {
	local arg=$1
	orb_is_any_flag $arg && [[ -z ${_orb_declared_suffixes[$arg]} ]]
}

_orb_declared_is_array() {
	local arg=$1 

	if orb_is_any_flag $arg; then
		local suffix=${_orb_declared_suffixes[$arg]}
		if orb_is_nr $suffix && (( $suffix > 1 )); then 
			return 0
		fi
	elif orb_is_dash $arg || orb_is_rest $arg || orb_is_block $arg; then
		return 0
	fi
	 
	return 1
}


_orb_is_valid_arg_option() {
	# local flag_options=( )
	local arg=$1 
	local options_i=$2
	local option=${declared_arg_options[$options_i]}

	_orb_is_available_option $option || return 1

	if _orb_declared_is_boolean_flag $arg; then 
		if _orb_is_invalid_boolean_flag_option $option; then
			_orb_raise_invalid_declaration "$arg, $option not valid option for boolean flags"
		fi
	elif _orb_declared_is_array $arg; then
		if _orb_is_invalid_array_option $option; then
			_orb_raise_invalid_declaration "$arg, $option not valid option for array arguments"
		fi
	fi
}
