_orb_is_available_option() {
	local available_options=( Comment: Required: Default: In: )
	[[ " ${available_options[@]} " =~ " $1 " ]]
}

_orb_is_catch_all_option() {
	local catch_all_options=( Default: In: )
	[[ " ${catch_all_options[@]} " =~ " $1 " ]]
}

_orb_is_invalid_boolean_flag_option() {
	local invalid_boolean_flag_options=( In: )
	[[ " ${invalid_boolean_flag_options[@]} " =~ " $1 " ]]
}

_orb_is_invalid_array_option() {
	local invalid_array_options=( In: )
	[[ " ${invalid_array_options[@]} " =~ " $1 " ]]
}


_orb_declared_arg_is_boolean_flag() {
	local args_i=$1 
	local arg=${_orb_declared_args[$args_i]}
	local suffix=${_orb_declared_arg_suffixes[$args_i]}

	orb_is_any_flag $arg && [[ -z $suffix ]]
}

_orb_declared_arg_is_array() {
	local args_i=$1 
	local arg=${_orb_declared_args[$args_i]}

	if orb_is_any_flag $arg; then
		local suffix=${_orb_declared_arg_suffixes[$args_i]}
		if orb_is_nr $suffix && (( $suffix > 1 )); then 
			return 0
		fi
	elif orb_is_dash $arg || orb_is_rest $arg || orb_is_block $arg; then
		return 0
	fi
	 
	return 1
}
