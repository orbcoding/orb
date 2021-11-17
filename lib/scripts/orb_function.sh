function orb() {
  source "$_orb_dir/lib/scripts/orb_settings.sh" 'call'
  source "$_orb_dir/lib/scripts/orb_arguments.sh"
	source "$_orb_dir/lib/scripts/caller.sh"
	source "$_orb_dir/lib/scripts/current.sh"

	${_orb_settings['-r']} && local _function_dump="$(declare -f)"

	# Source namespace _presource.sh in reverse (closest last)
	local _i; for (( _i=${#_orb_extensions[@]}-1 ; _i>=0 ; _i-- )); do
		local _ext="${_orb_extensions[$_i]}"
		if [[ -f "$_ext/namespaces/$_orb_namespace/_presource.sh" ]]; then
			source "$_ext/namespaces/$_orb_namespace/_presource.sh"
		fi
	done

	_orb_collect_orb_namespace_files
	_orb_handle_help_requested && exit 0


	# Source file if has public function
	local _file; for _file in ${_orb_namespace_files[@]}; do
		if _has_public_function "$_orb_function" "$_file"; then
			local _file_with_function="$_file"
			source "$_file"
			break
		fi
	done

	_function_declared $_orb_function || _raise_error "undefined"

	# Parse function args
	if [[ $1 == "--help" ]]; then
		_orb_print_function_help
		exit 0
	elif ${_orb_settings['-d']}; then
		_args_positional=("$@")
	else
		_orb_parse_args "$@"
	fi

	# Call function
	$_orb_function "${_args_positional[@]}"
	local _function_exit_code=$?

	${_orb_settings['-r']} && eval "$_function_dump"

	return $_function_exit_code
}
