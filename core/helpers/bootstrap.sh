_get_script_name() {
	if [[ " ${_scripts[@]} " =~ " ${1} " ]]; then
		echo "$1"
	else
		echo orb
		exit 1
	fi
}

_get_script_function_path() {
	local _script_function_path="$_script_name"
	[[ -n $_function_name ]] && _script_function_path+="->$(bold)${_function_name}$(normal)"
	echo "$_script_function_path"
}

_get_current_script_extension() {
	local _orb_extensions=$(upfind _orb_extensions)
	if [[ -n $_orb_extensions && -f $_orb_extensions/${_script_name}.sh ]]; then
		echo "$_orb_extensions/${_script_name}.sh"
	else
		exit 1
	fi
}


_handle_function_is_missing_or_help() {
	if [[ "$_function_name" == 'help' ]]; then
		_print_script_help && exit 0
	elif [[ -z $_function_name ]]; then
		orb utils raise_error "is a script tag - no function provided"
	elif ! function_exists $_function_name; then
		orb utils raise_error "undefined"
	fi
}

# _unset_all_underscored() {
# 	while read _fn; do
# 			[[ $_fn != $_function_name && $_fn != 'orb' ]] && unset -f ${_fn}
# 	done <  <( declare -F | cut -d" " -f3 | egrep '^(_).*')

# 	unset ${!_@}
# }

# Unset all commands prefixed with function except for the one called
# Effectively only allowing functions to be called with orb prefix and arg handling
_unset_redundant_script_functions() {
	local _file
	for _file in "${_core_script_dependencies[@]}"; do
		_forget_script_functions "$_orb_dir/$_file"
	done

	for _file in ${_current_script_dependencies[@]}; do
		_forget_script_functions "$_script_dir/$_file"
	done
	unset list_public_functions
}

_forget_script_functions() { # $1 file
	local _fn
	for _fn in $(list_public_functions "$1"); do
		if [[ $_fn != $_function_name && $_fn != "list_public_functions" ]]; then
			unset "$_fn"
			[[ -v ${_fn}_args[@] ]] && unset "${_fn}_args"
		fi
	done
}

