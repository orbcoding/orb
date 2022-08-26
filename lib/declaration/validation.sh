# Nothing here yet
# What should be validated is:

# - Required = true/false
# - Default value length <= flag_suffix_length or == 1 for non arrays

# - In is currently only for non arrays...
# - Comment should be able to array and then captured as single
_orb_prevalidate_declaration() {
	if [[ ${declaration[0]} == '=' ]]; then 
		raise_invalid_declaration 'Cannot start with ='
	fi
}

_orb_raise_invalid_declaration() {
	orb_raise_error "Invalid declaration. $@" 
}

_orb_raise_undeclared() {
	orb_raise_error "'$1' not in $_function_descriptor_history_0 args declaration\n\n$(_orb_print_args_explanation _history_0)"
}

_orb_postvalidate_declared_args_options() {
  _orb_postvalidate_declared_args_options_catchs
	_orb_postvalidate_declared_args_options_requireds
}

_orb_postvalidate_declared_args_options_catchs() {
	local arg; for arg in ${_orb_declared_args[@]}; do
		local arg_catch; _orb_get_arg_catch_arr $arg arg_catch

		local value; for value in "${arg_catch[@]}"; do
			if ! _orb_is_available_catch_value $value; then
				_orb_raise_invalid_declaration "$arg: Invalid catch value: $value. Available values: ${_orb_available_arg_option_catch_values[@]}"
			fi
		done
	done
}

_orb_postvalidate_declared_args_options_requireds() {
	local arg; for arg in ${_orb_declared_args[@]}; do
	 	local value=${_orb_declared_requireds[$arg]}
		if ! _orb_is_available_required_value $value; then
			_orb_raise_invalid_declaration "$arg: Invalid required value: $value. Available values: ${_orb_available_arg_option_required_values[@]}"
		fi
	done
}

_orb_is_valid_arg_option() {
	# local flag_options=( )
	local arg=$1 
	local options_i=$2
	local option=${declared_arg_options[$options_i]}

	_orb_is_available_option $option || return 1

	if _orb_has_declared_boolean_flag $arg; then 
		if ! _orb_is_available_boolean_flag_option $option; then
			_orb_raise_invalid_declaration "$arg: Invalid option: $option. Available options for boolean flags: ${_orb_available_arg_options_boolean_flag[@]}"
		fi
	elif _orb_has_declared_array $arg; then
		if ! _orb_is_available_array_option $option; then
			_orb_raise_invalid_declaration "$arg: Invalid option: $option. Available options for array type arguments: ${_orb_available_arg_options_array_arg[@]}"
		fi
	fi
}
