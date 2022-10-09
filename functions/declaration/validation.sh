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
	_orb_raise_error "Invalid declaration. $@" 
}

_orb_raise_undeclared() {
	declare -n _orb_fn_descriptor=_orb_function_descriptor$_orb_variable_suffix
	_orb_raise_error "'$1' not in $_orb_fn_descriptor args declaration\n\n$(_orb_print_args_explanation)"
}

_orb_postvalidate_declared_args_options() {
  _orb_postvalidate_declared_args_options_catchs
	_orb_postvalidate_declared_args_options_requireds
	_orb_postvalidate_declared_args_options_multiples
	# _orb_postvalidate_declared_args_incompatible_options
}

_orb_postvalidate_declared_args_options_catchs() {
	local arg; for arg in ${_orb_declared_args[@]}; do
		local arg_catch; _orb_get_arg_option_declaration $arg "Catch:" arg_catch
		
		local value; for value in "${arg_catch[@]}"; do
			if ! orb_in_arr $value _orb_available_arg_option_catch_values; then
				_orb_raise_invalid_declaration "$arg: Invalid Catch: value: $value. Available values: ${_orb_available_arg_option_catch_values[*]}"
			fi
		done
	done
}

_orb_postvalidate_declared_args_options_requireds() {
	local arg; for arg in ${_orb_declared_args[@]}; do
	 	local value; _orb_get_arg_option_value $arg "Required:" value

		if ! orb_in_arr $value _orb_available_arg_option_required_values; then
			_orb_raise_invalid_declaration "$arg: Invalid Required: value: $value. Available values: ${_orb_available_arg_option_required_values[*]}"
		fi
	done
}

_orb_postvalidate_declared_args_options_multiples() {
	local arg; for arg in ${_orb_declared_args[@]}; do
	 	local value; _orb_get_arg_option_value $arg "Multiple:" value
		if [[ -n $value ]] && ! orb_in_arr $value _orb_available_arg_option_multiple_values; then
			_orb_raise_invalid_declaration "$arg: Invalid Multiple: value: $value. Available values: ${_orb_available_arg_option_multiple_values[*]}"
		fi
	done
}

# _orb_postvalidate_declared_args_incompatible_options() {
# 	local arg; for arg in ${_orb_declared_args[@]}; do
# 		if _orb_get_arg_option_declaration $arg "Default:" && _orb_get_arg_option_declaration $arg "DefaultHelp:"; then
# 			_orb_raise_invalid_declaration "$arg: Incompatible options: Default:, DefaultHelp:"
# 		fi
# 	done
# }

_orb_is_valid_arg_option() {
	local arg=$1 
	local option=$2
	local raise=${3-false}
	local error

	if orb_is_nr $arg && ! orb_in_arr "$option" _orb_available_arg_options_number_arg; then
		error="$arg: Invalid option: $option. Available options for number args: ${_orb_available_arg_options_number_arg[*]}"
	elif _orb_has_declared_boolean_flag $arg && ! orb_in_arr "$option" _orb_available_arg_options_boolean_flag; then
		error="$arg: Invalid option: $option. Available options for boolean flags: ${_orb_available_arg_options_boolean_flag[*]}"
	elif _orb_has_declared_flagged_arg $arg && ! orb_in_arr "$option" _orb_available_arg_options_flag_arg; then
		error="$arg: Invalid option: $option. Available options for flag args: ${_orb_available_arg_options_flag_arg[*]}"
	elif _orb_has_declared_array_flag_arg $arg && ! orb_in_arr "$option" _orb_available_arg_options_array_flag_arg; then
		error="$arg: Invalid option: $option. Available options for flag array args: ${_orb_available_arg_options_array_flag_arg[*]}"
	elif orb_is_block $arg && ! orb_in_arr "$option" _orb_available_arg_options_block; then
		error="$arg: Invalid option: $option. Available options for blocks: ${_orb_available_arg_options_block[*]}"
	elif orb_is_dash $arg && ! orb_in_arr "$option" _orb_available_arg_options_dash; then
		error="$arg: Invalid option: $option. Available options for --: ${_orb_available_arg_options_dash[*]}"
	elif orb_is_rest $arg && ! orb_in_arr "$option" _orb_available_arg_options_rest; then
		error="$arg: Invalid option: $option. Available options for ...: ${_orb_available_arg_options_rest[*]}"
	fi

	if [[ -n $error ]]; then
	 	[[ $raise == true ]] && _orb_raise_invalid_declaration "$error"
		return 1
	fi
}


_orb_postvalidate_declared_function_options() {
  _orb_postvalidate_declared_function_options_direct_call
}

_orb_postvalidate_declared_function_options_direct_call() {
	local value=$_orb_declared_direct_call
	if ! orb_in_arr "$value" _orb_available_function_option_direct_call_values; then
		_orb_raise_invalid_declaration "Function: DirectCall: $value. Available values: ${_orb_available_function_option_direct_call_values[*]}"
	fi
}

_orb_is_valid_function_option() {
	local option=$1
	local raise=${2-false}

	if ! orb_in_arr $1 _orb_available_function_options; then
		[[ $raise == true ]] && _orb_raise_invalid_declaration "Function: Invalid option: $option. Available function options ${_orb_available_function_options[*]}"
	fi
}

