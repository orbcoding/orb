# Internal help functions
# print_global_help() {
# echo "$(cat <<EOF
# orb [namespace_name(default=d)] [function_name]

# available namespaces: $(echo ${namespaces[*]} | sed 's/ /, /g')
# EOF
# )"
# }

_print_global_namespace_help_intro() {
	local _intromsg="Default namespace set to $(_bold)$_current_namespace$(_normal). Commands listed below.\n"
	_intromsg+="Available namespaces: orb "
	_intromsg+="[$(_join_by '/' "${_namespaces[@]}")] --help\n"
	echo -e "$_intromsg"
}

_print_namespace_help() {
	if $_global_help_requested; then
		_print_global_namespace_help_intro
	fi

	local _file; for _file in ${_namespace_files[@]}; do
		if [[ "$_file" == "$_current_namespace_extension_file" ]]; then
			_output+="-----------------# $(_italic)local _orb_extension\n$(_normal)"
		fi
		_output+="$(_bold)$(_upcase $(basename $_file))$(_normal)\n"
		_output+=$(grep "^[); ]*function[ ]*[a-zA-Z_-]*[ ]*()[ ]*{" $_file | sed 's/\(); \)*function //' | sed 's/().* {[ ]*//' | sed 's/^/  /')
		_output+="\n\n"
	done

	# remove last 4 chars \n\n
	echo -e "${_output::-4}" | column -tes '#'
}

_print_function_help() {
	_print_function_name_and_comment
	local _def=$(__print_args_explanation)
	[[ -n "$_def" ]] && echo -e "\n$_def"
}


__print_args_explanation() { # $1 optional args_declaration
	local _declaration_ref=${1-"_args_declaration"}
	declare -n _declaration="$_declaration_ref"

	[[ -z "${!_declaration[@]}" ]] && exit 1
	local _props=('ARG' 'DESCRIPTION' 'DEFAULT' 'IN' 'REQUIRED' 'OTHER')
	IFS=';'; local _msg="$(_bold)${_props[*]}$(_normal)\n"

	_msg+=$(for _key in "${!_declaration[@]}"; do
		_sub="$_key"
		for _prop in ${_props[@]:1}; do
			_val=
			if [[ "$_prop" == 'REQUIRED' ]]; then
				_is_required "$_key" "$_declaration_ref" && _val='true'
			elif [[ "$_prop" == 'OTHER' ]]; then
				_accepts_flags "$_key" "$_declaration_ref" && _val='ACCEPTS_FLAGS'
			else
				_val="$(_get_arg_prop "$_key" "$_prop" "$_declaration_ref")"
			fi

			_sub+=";$([[ -n "$_val" ]] && echo "$_val" || echo '-')"
		done
		echo "$_sub"
	done | sort)

	echo -e "$_msg" | sed 's/^/  /' | column -t -s ';'
}

_print_function_comment() {
	local _comment_line=$(grep -r "function $_function_name" "$_file_with_function")
	if [[ "$_comment_line" != "${_comment_line/\#/}" ]]; then
	 echo "$_comment_line" | cut -d '#' -f2- | xargs
	fi
}

_print_function_name_and_comment() {
	local _comment=$(_print_function_comment)
	echo "$(_bold)$_function_name$(_normal) $([[ -n "$_comment" ]] && echo "- $_comment")"
}

