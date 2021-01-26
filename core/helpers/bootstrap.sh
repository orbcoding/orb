_collect_namespace_extensions() {
	local _extension_files=( $_orb_extensions/* )

	local _file; for _file in ${_extension_files}; do
		_namespace=$(basename $_file)
		_namespaces+=( ${_namespace/.*/} )
	done
}

_get_current_namespace() {
	if [[ " ${_namespaces[@]} " =~ " ${1} " ]]; then
		echo "$1"
	else
		echo $(_eval_variable_or_string_options "$ORB_DEFAULT_NAMESPACE|docker")
		exit 1
	fi
}

_get_current_namespace_extension() {
	if [[ -n $_orb_extensions && -f $_orb_extensions/${_current_namespace}.sh ]]; then
		echo "$_orb_extensions/${_current_namespace}.sh"
	else
		exit 1
	fi
}

_collect_namespace_files() {
	if [[ -d "$_namespace_dir" ]]; then
		# Add all non_underscore namespace_dir files to namespace_files
		local _files
		readarray -d '' _files < <(find "$_namespace_dir" -type f -name "*.sh" ! -name '_*' -print0 | sort -z)
		_namespace_files+=( "${_files[@]}" )
	fi

	if $_current_namespace_extension_file; then
		_namespace_files+=( "$_current_namespace_extension_file" )
	fi
}

_get_function_descriptor() {
	if [[ -n $_function_name ]]; then
		echo "$_current_namespace->$(_bold)${_function_name}$(_normal)"
	else
		echo "$(_bold)$_current_namespace$(_normal)"
	fi
}

_handle_public_function_missing() {
	if ! _function_exists $_function_name; then
		orb -c utils raise_error "undefined"
	fi
}

_handle_help_requested() {
	if $_global_help_requested || $_namespace_help_requested; then
		_print_namespace_help
	else
		return 1
	fi
}
