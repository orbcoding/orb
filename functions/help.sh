# Internal help functions
_orb_handle_help_requested() {
	if $_orb_setting_help; then
		_orb_print_global_namespace_help_intro
	elif $_orb_setting_namespace_help; then
		_orb_print_namespace_help
	else
		return 1
	fi
}

_orb_print_global_namespace_help_intro() {
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
	local i=0 file current_dir

	for file in ${_orb_namespace_files[@]}; do
		if [[ "${_orb_namespace_files_dir_tracker[$i]}" != "$current_dir" ]]; then
			current_dir="${_orb_namespace_files_dir_tracker[$i]}"
			output+="-----------------# $(orb_italic)${current_dir}\n$(orb_normal)"
		fi

		output+="$(orb_bold)$(orb_upcase $(basename $file))$(orb_normal)\n"
		output+=$(grep "^[); ]*function[ ]*[a-zA-Z_-]*[ ]*()[ ]*{" $file | sed 's/\(); \)*function //' | sed 's/().* {[ ]*//' | sed 's/^/  /')
		output+="\n\n"

		((i++))
	done

	# remove last 4 chars \n\n
	echo -e "${output::-4}" | column -tes '#'
}

_orb_print_function_help() {
	_orb_print_orb_function_and_comment
	local _def=$(_orb_print_args_explanation)
	[[ -n "$_def" ]] && echo -e "\n$_def"
	return 0
}


_orb_print_args_explanation() { # $1 optional args_declaration
	local _declaration_ref=${1-"_orb_function_declaration"}
	declare -n _declaration="$_declaration_ref"

	[[ -z "${!_declaration[@]}" ]] && exit 1
	local _props=('ARG' 'DESCRIPTION' 'DEFAULT' 'IN' 'REQUIRED' 'OTHER')
	IFS=';'; local _msg="$(orb_bold)${_props[*]}$(orb_normal)\n"

	_msg+=$(for _key in "${!_declaration[@]}"; do
		_sub="$_key"
		for _prop in ${_props[@]:1}; do
			_val=
			if [[ "$_prop" == 'REQUIRED' ]]; then
				_orb_is_required "$_key" "$_declaration_ref" && _val='true'
			elif [[ "$_prop" == 'OTHER' ]]; then
				_val=()
				_orb_catches_any "$_key" "$_declaration_ref" && _val+=( CATCH_ANY )
				_orb_catches_empty "$_key" "$_declaration_ref" && _val+=( CATCH_EMPTY )
				_val=$(orb_join_by ', ' ${_val[*]})
			else
				_val="$(_orb_get_arg_prop "$_key" "$_prop" "$_declaration_ref")"
			fi

			_sub+=";$([[ -n "$_val" ]] && echo "$_val" || echo '-')"
		done
		echo "$_sub"
	done | sort)

	echo -e "$_msg" | sed 's/^/  /' | column -t -s ';'
}

_orb_print_function_comment() {
	local _comment_line=$(grep -r "function $_orb_function_name" "$_file_with_function")
	if [[ "$_comment_line" != "${_comment_line/\#/}" ]]; then
	 echo "$_comment_line" | cut -d '#' -f2- | xargs
	fi
}

_orb_print_orb_function_and_comment() {
	local comment=$(_orb_print_function_comment)
	echo "$(orb_bold)$_orb_function_name$(orb_normal) $([[ -n "$comment" ]] && echo "- $comment")"
}

