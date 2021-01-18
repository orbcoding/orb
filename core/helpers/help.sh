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
		local _intromsg="Main $(bold)orb$(normal) namespace scripts listed below.\n"
		_intromsg+="For other script namespaces see: orb "
		local _other_scripts=()
		local _script
		for _script in ${_scripts[@]}; do
			[[ $_script != 'orb' ]] && _other_scripts+=( "$_script" )
		done
		_intromsg+="[$(join_by '/' "${_other_scripts[@]}")] help\n"
		echo -e "$_intromsg"
	fi
}

_print_script_help() {
	_print_script_help_introtext

	local _output=""
	local _script_files=${_current_script_dependencies[@]}

	if [[ -n $_current_script_extension ]]; then
		_script_files+=($(realpath --relative-to $_script_dir $_current_script_extension))
	fi

	local _file
	for _file in ${_script_files[@]}; do
		local _filename=$(basename $_file)
		if [[ "${_filename}" == "${_script_name}.sh" ]]; then
			_output+="-----------------# $(italic)local _orb_extensions\n$(normal)"
		fi
		_output+="$(bold)${_filename^^}$(normal)\n"
		_output+=$(grep "^[); ]*function" $_script_dir/$_file | sed 's/\(); \)*function //' | sed 's/().* {[ ]*//' | sed 's/^/  /')
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


_print_args_explanation() {
	[[ -z "${!_args_declaration[@]}" ]] && exit
	local _props=('ARG' 'DESCRIPTION' 'DEFAULT' 'IN' 'REQUIRED' 'OTHER')
	IFS=';'; local _msg="$(bold)${_props[*]}$(normal)\n"

	_msg+=$(for _key in "${!_args_declaration[@]}"; do
		_sub="$_key"
		for _prop in ${_props[@]:1}; do
			_val=
			if [[ "$_prop" == 'REQUIRED' ]]; then
				_is_required "$_key" && _val='true'
			elif [[ "$_prop" == 'OTHER' ]]; then
				_can_start_flagged "$_key" && _val='CAN_START_WITH_FLAG (-/+)'
			else
				_val="$(_get_arg_prop "$_key" "$_prop")"
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
	echo "$(bold)$_function_name$(normal) $([[ -n "$_comment" ]] && echo "- $_comment")"
}

