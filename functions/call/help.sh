# Internal help functions
_orb_handle_help() {
	$_orb_setting_help || return 1

	if [[ -n "$_orb_function_name" ]]; then
		_orb_print_function_help
	elif [[ -n $_orb_namespace ]]; then
		_orb_print_namespace_help
	else
		_orb_print_orb_help
	fi

	return 0
}

_orb_print_orb_help() {
	local def_namespace_msg

	if [[ -n $ORB_DEFAULT_NAMESPACE ]]; then
		def_namespace_msg="Default namespace: $(orb_bold)$ORB_DEFAULT_NAMESPACE$(orb_normal)"
	else
		def_namespace_msg="Default namespace \$ORB_DEFAULT_NAMESPACE not set"
	fi

	local help_msg="$def_namespace_msg.\n\n"

	if orb_is_empty_arr _orb_namespaces; then
		help_msg+="No namespaces found"
	else
		help_msg+="Available namespaces listed below:\n\n"
		help_msg+="  $(orb_join_by ', ' "${_orb_namespaces[@]}").\n\n"
		help_msg+="To list commands in a namespace, use \`orb \"namespace\" --help\`"
	fi

	echo -e "$help_msg"
}

_orb_print_namespace_help() {
	local i=0 file current_dir output

	local file; for file in ${_orb_namespace_files[@]}; do
		local dir="${_orb_namespace_files_orb_dir_tracker[$i]}"

		if [[ "$dir" != "$current_dir" ]]; then
			current_dir="$dir"
			output+="-----------------§$(orb_italic)${current_dir}$(orb_normal)\n"
		fi

		output+="$(orb_bold)$(orb_upcase $(basename $file))$(orb_normal)\n"
		source "$file"
		local fns; orb_get_public_functions "$file" fns

		local fn; for fn in "${fns[@]}"; do
			declare -A _orb_declared_comments=()
			_orb_parse_function_declaration "${fn}_orb" false
			output+="  $fn§"
			output+="${_orb_declared_comments[function]}\n"
		done

		output+="\n§\n"


		((i++))
	done

	# remove last 5 chars \n§\n
	echo -e "${output::-5}" | column -tes '§'
}

_orb_print_function_help() {
	_orb_print_orb_function_and_comment
	local msg=$(_orb_print_args_explanation)
	[[ -n "$msg" ]] && echo -e "\n$msg"
	return 0
}


_orb_print_orb_function_and_comment() {
	declare -n comments=_orb_declared_comments$_orb_variable_suffix
	declare -n function_descriptor=_orb_function_descriptor$_orb_variable_suffix
	local comment="${comments[function]}"
	echo "$(orb_bold)$function_descriptor$(orb_normal) $([[ -n "$comment" ]] && echo "- $comment")"
}

_orb_print_args_explanation() {
	declare -n declared_args=_orb_declared_args$_orb_variable_suffix
	[[ ${#declared_args[@]} == 0 ]] && return 1

	OLD_IFS=$IFS
	IFS='§'; local msg="$(orb_bold)§${_orb_available_arg_options_help[*]}§$(orb_normal)\n"
	IFS=$OLD_IFS

	local arg; for arg in "${declared_args[@]}"; do
		local msg+="$arg"

		local opt; for opt in "${_orb_available_arg_options_help[@]}"; do
			local value=()
			
			if [[ $opt == "Default:" ]]; then
				_orb_get_arg_option_value $arg "DefaultHelp:" value
				[[ -z ${value[@]} ]] &&  _orb_get_arg_option_value $arg "Default:" value
			else 
				_orb_get_arg_option_value $arg $opt value
			fi

			msg+="§$([[ -n "${value[@]}" ]] && echo "${value[@]}" || echo '-')"
		done

		local comment; comment="$(_orb_get_arg_comment $arg)"
		if [[ $? == 1 ]]; then
			declare -n declared_vars=_orb_declared_vars$_orb_variable_suffix
			comment=${declared_vars[$arg]}
		fi

		msg+="§$comment\n"
	done

	echo -e "$msg" | sed 's/^/  /' | column -t -s '§'
}
