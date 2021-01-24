# Internal help functions
# print_global_help() {
# echo "$(cat <<EOF
# orb [script_name(default=d)] [function_name]

# available scripts: $(echo ${scripts[*]} | sed 's/ /, /g')
# EOF
# )"
# }

_print_script_help_introtext() {
	if [[ $_script_name == 'orb' ]]; then
		local _intromsg="Main $(_bold)orb$(_normal) namespace scripts listed below.\n"
		_intromsg+="For other script namespaces see: orb "
		local _other_scripts=()
		local _script
		for _script in ${_scripts[@]}; do
			[[ $_script != 'orb' ]] && _other_scripts+=( "$_script" )
		done
		_intromsg+="[$(_join_by '/' "${_other_scripts[@]}")] help\n"
		echo -e "$_intromsg"
	fi
}

_print_script_help() {
	_print_script_help_introtext

	local _file; for _file in ${_script_files[@]}; do
		if [[ "$_file" == "$_current_script_extension_file" ]]; then
			_output+="-----------------# $(_italic)local _orb_extensions\n$(_normal)"
		fi
		_output+="$(_bold)$(_upcase $(basename $_file))$(_normal)\n"
		_output+=$(grep "^[); ]*function" $_file | sed 's/\(); \)*function //' | sed 's/().* {[ ]*//' | sed 's/^/  /')
		_output+="\n\n"
	done

	# remove last 4 chars \n\n
	echo -e "${_output::-4}" | column -tes '#'
}

_print_function_help() {
	_print_function_name_and_comment
	local _def=$(_print_args_explanation)
	[[ -n "$_def" ]] && echo -e "\n$_def"
}


_print_args_explanation() { # $1 optional args_declaration
	local _declaration_ref=${1-"_args_declaration"}
	declare -n _declaration="$_declaration_ref"

	[[ -z "${!_declaration[@]}" ]] && exit
	local _props=('ARG' 'DESCRIPTION' 'DEFAULT' 'IN' 'REQUIRED' 'OTHER')
	IFS=';'; local _msg="$(tput bold)${_props[*]}$(tput sgr0)\n"

	_msg+=$(for _key in "${!_declaration[@]}"; do
		_sub="$_key"
		for _prop in ${_props[@]:1}; do
			_val=
			if [[ "$_prop" == 'REQUIRED' ]]; then
				_is_required_arg "$_key" "$_declaration_ref" && _val='true'
			elif [[ "$_prop" == 'OTHER' ]]; then
				_can_start_flagged "$_key" "$_declaration_ref" && _val='CAN_START_WITH_FLAG (-/+)'
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
	local _comment_line=$(grep -r --include \*.sh "function $_function_name" "$_script_dir")
	if [[ "$_comment_line" != "${_comment_line/\#/}" ]]; then
	 echo "$_comment_line" | cut -d '#' -f2- | xargs
	fi
}

_print_function_name_and_comment() {
	local _comment=$(_print_function_comment)
	echo "$(_bold)$_function_name$(_normal) $([[ -n "$_comment" ]] && echo "- $_comment")"
}

