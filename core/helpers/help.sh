# Internal help functions
# print_global_help() {
# echo "$(cat <<EOF
# orb [script_name(default=d)] [function_name]

# available scripts: $(echo ${scripts[*]} | sed 's/ /, /g')
# EOF
# )"
# }

_print_script_help_introtext() {
	if [[ $script_name == 'orb' ]]; then
		intromsg="Main $(bold)orb$(normal) namespace scripts listed below.\n"
		intromsg+="For other script namespaces see: orb "
		other_scripts=()
		for script in ${scripts[@]}; do
			[[ $script != 'orb' ]] && other_scripts+=( "$script" )
		done
		intromsg+="[$(join_by '/' "${other_scripts[@]}")] help\n"
		echo -e "$intromsg"
	fi
}

_print_script_help() {
	_print_script_help_introtext

	output=
	for file in ${script_files[@]}; do
		filename=$(basename $file)
		if [[ "${filename}" == "${script_name}.sh" ]]; then
			output+="-----------------# $(italic)local _orb_extensions\n$(normal)"
		fi
		output+="$(bold)${filename^^}$(normal)\n"
		output+=$(grep "^[); ]*function" $script_dir/$file | sed 's/\(); \)*function //' | sed 's/().* {[ ]*//' | sed 's/^/  /')
		output+="\n\n"
	done
	# remove last 4 chars \n\n
	echo -e "${output::-4}" | column -tes '#'
}

_print_function_help() {
	_print_function_name_and_comment
	def=$(_print_args_explanation)
	[[ -n "$def" ]] && echo -e "\n$def"
}


_print_args_explanation() {
	[[ -z "${!args_declaration[@]}" ]] && exit
	props=('ARG' 'DESCRIPTION' 'DEFAULT' 'IN' 'REQUIRED' 'OTHER')
	IFS=';'
	msg="$(bold)${props[*]}$(normal)\n"
	# IFS=''
	msg+=$(for key in "${!args_declaration[@]}"; do
		sub="$key"
		for prop in ${props[@]:1}; do
			val=
			if [[ "$prop" == 'REQUIRED' ]]; then
				_is_required "$key" && val='true'
			elif [[ "$prop" == 'OTHER' ]]; then
				_can_start_flagged "$key" && val='CAN_START_WITH_FLAG (-/+)'
			else
				val="$(_get_arg_prop "$key" "$prop")"
			fi

			sub+=";$([[ -n "$val" ]] && echo "$val" || echo '-')"
		done
		echo "$sub"
	done | sort)

	echo -e "$msg" | sed 's/^/  /' | column -t -s ';'
}

_print_function_comment() {
	comment_line=$(grep -r --include \*.sh "function $function_name" "$script_dir")
	if [[ "$comment_line" != "${comment_line/\#/}" ]]; then
	 echo "$comment_line" | cut -d '#' -f2- | xargs
	fi
}

_print_function_name_and_comment() {
	comment=$(_print_function_comment)
	echo "$(bold)$function_name$(normal) $([[ -n "$comment" ]] && echo "- $comment")"
}

