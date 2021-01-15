# Unset all commands prefixed with function except for the one called
# Effectively only allowing functions to be called with orb prefix and arg handling
_unset_all_internal_utils() {
	for _file in "${_core_script_dependencies[@]}"; do
		_forget_file_functions "$_file"
	done

	for _file in "${_current_script_depdendencies[@]}"; do
		if [[ -z "$_current_script_extension" || "$_file" != "$_current_script_extension" ]]; then
			_forget_file_functions "$_file"
		fi
	done
}

_unset_all_underscored() {
	while read _fn; do
			[[ $_fn != $function_name && $_fn != 'orb' ]] && unset -f ${_fn}
	done <  <( declare -F | cut -d" " -f3 | egrep '^(_).*')

	unset ${!_@}
}

_forget_file_functions() { # $1 file
	for _fn in $(list_public_functions "$orb_dir/$1"); do
		if [[ $_fn != $function_name ]]; then
			unset "$_fn"
			[[ -v ${_fn}_args[@] ]] && unset "${_fn}_args"
			# declare -A ${_fn}_args > /dev/null && unset "${_fn}_args"
		fi
	done
}

_handle_function_is_missing_or_help() {
	if [[ "$function_name" == 'help' ]]; then
		_print_script_help && exit 0
	elif [[ -z $function_name ]]; then
		orb utils raise_error "is a script tag - no function provided"
	elif ! function_exists $function_name; then
		orb utils raise_error "undefined"
	fi
}
