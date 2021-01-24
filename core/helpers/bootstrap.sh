_get_script_name() {
	# TODO check list of script extensions
	if [[ " ${_scripts[@]} " =~ " ${1} " ]]; then
		echo "$1"
	else
		echo orb
		exit 1
	fi
}

_get_current_script_extension_file() {
	local _orb_extensions=$(_upfind _orb_extensions)
	if [[ -n $_orb_extensions && -f $_orb_extensions/${_script_name}.sh ]]; then
		echo "$_orb_extensions/${_script_name}.sh"
	else
		exit 1
	fi
}

_collect_script_files() {
	if [[ -d "$_script_dir" ]]; then
		# Add all non_underscore script_dir files to script_files
		local _files
		readarray -d '' _files < <(find "$_script_dir" -type f -name "*.sh" ! -name '_*' -print0)
		_script_files+=( "${_files[@]}" )
	fi

	if $_current_script_extension_file; then
		_script_files+=( "$_current_script_extension_file" )
	fi
}

_get_function_descriptor() {
	local _function_descriptor="$_script_name"
	[[ -n $_function_name ]] && _function_descriptor+="->$(tput bold)${_function_name}$(tput sgr0)"
	echo "$_function_descriptor"
}

_handle_function_is_missing_or_help() {
	if [[ "$_function_name" == 'help' ]]; then
		_print_script_help && exit 0
	elif [[ -z $_function_name ]]; then
		orb -dc utils raise_error "is a script tag - no function provided"
	elif ! _function_exists $_function_name; then
		orb -dc utils raise_error "undefined"
	fi
}


# list_public_functions $1 file
_list_public_functions() {
	for file in "$@"; do
		grep "^[); ]*function" $file | sed 's/\(); \)*function //' | cut -d '(' -f1
	done
}

# has_public_function $1 function, $2 file
_has_public_function() { # check if file has function
	_list_public_functions "$2" | grep -Fxq $1
}

# _unset_all_underscored() {
# 	while read _fn; do
# 			[[ $_fn != $_function_name && $_fn != 'orb' ]] && unset -f ${_fn}
# 	done <  <( declare -F | cut -d" " -f3 | egrep '^(_).*')

# 	unset ${!_@}
# }

# Unset all commands prefixed with function except for the one called
# Effectively only allowing functions to be called with orb prefix and arg handling
# _unset_redundant_script_functions() {
# 	local _file
# 	for _file in "${_core_script_dependencies[@]}"; do
# 		_forget_script_functions "$_orb_dir/$_file"
# 	done

# 	for _file in ${_script_files[@]}; do
# 		_forget_script_functions "$_script_dir/$_file"
# 	done
# 	unset list_public_functions
# }

# _forget_script_functions() { # $1 file
# 	local _fn
# 	for _fn in $(list_public_functions "$1"); do
# 		if [[ $_fn != $_function_name && $_fn != "list_public_functions" ]]; then
# 			unset "$_fn"
# 			[[ -v ${_fn}_args[@] ]] && unset "${_fn}_args"
# 		fi
# 	done
# }

