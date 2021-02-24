_get_current_namespace() {
	if [[ " ${_namespaces[@]} " =~ " ${1} " ]]; then
		echo "$1"
	elif [[ -n $ORB_DEFAULT_NAMESPACE ]]; then
		echo $ORB_DEFAULT_NAMESPACE
		return 1
	elif ! $_global_help_requested; then
		_raise_error +t -d "$(_bold)${1-\"\"}$(_normal)" "not a valid namespace and \$ORB_DEFAULT_NAMESPACE not set. \n\n  Available namespaces: ${_namespaces[*]}"
	fi
}

_collect_namespace_files() {
	local _orb_config_dirs=( $_orb_dir )

	! $_core_files_only && _orb_config_dirs+=( "${_orb_extensions[@]}" )
	local _conf_dir

 	for _conf_dir in "${_orb_config_dirs[@]}"; do
	 	local _files _dir="$_conf_dir/namespaces/$_current_namespace"

		if [[ -d "$_dir" ]]; then
			readarray -d '' _files < <(find $_dir -type f -name "*.sh" ! -name '_*' -print0 | sort -z)

			local _from=${#_namespace_files[@]}
			local _to=$(( ${#_namespace_files[@]} + ${#_files[@]} - 1 ))
			local _i; for _i in $(seq $_from $_to ); do
				_namespace_files_dir_tracker[$_i]="$_conf_dir"
			done

			_namespace_files+=( "${_files[@]}" )

		elif [[ -f "${_dir}.sh" ]]; then
			_namespace_files_dir_tracker[${#_namespace_files[@]}]="$_conf_dir"
			_namespace_files+=( "${_dir}.sh" )
		fi
	done
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
		_raise_error "undefined"
	fi
}

_handle_help_requested() {
	if $_global_help_requested; then
		_print_global_namespace_help_intro
	elif $_namespace_help_requested; then
		_print_namespace_help
	else
		return 1
	fi
}
