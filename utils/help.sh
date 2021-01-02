function print_args() { # print collected arguments from arguments.sh, useful for debugging
	declare -A | grep 'A args=' | cut -d '=' -f2-
	[[ ${args["*"]} == true ]]  && echo "[*]=${args_wildcard[*]}"
}


###############
# INTERNAL
###############
print_global_help() {
echo "$(cat <<EOF
orb [script_name(default=d)] [function_name]

available scripts: $(echo ${scripts[*]} | sed 's/ /, /g')
EOF
)"
}

print_script_help() {
	# flags `${args[*]}`
	for file in ${script_files[@]}; do
		echo "$(bold)$(basename $file | tr a-z A-Z)$(normal)"
		lines=$(grep "^[); ]*function" $script_dir/$file | sed 's/\(); \)*function //' | sed 's/().* {[ ]*//')
		echo "$lines" | column -ts '#'
		echo
	done
}

print_function_help() {
	print_function_name_and_comment
	echo
	print_args_definition
}


print_args_definition() {
	props=('ARG' 'DESCRIPTION' 'DEFAULT' 'IN' 'REQUIRED')
	IFS=';'
	msg="$(bold)${props[*]}$(normal)\n"
	# IFS=''
	msg+=$(for key in "${!args_declaration[@]}"; do
		sub="$key"
		for prop in ${props[@]:1}; do
			val=
			if [[ "$prop" == 'REQUIRED' ]]; then
				is_required "$key" && val='true'
			else
				val="$(get_arg_prop "$key" "$prop")"
			fi

			sub+=";$([[ -n "$val" ]] && echo "$val" || echo '-')"
		done
		echo "$sub"
	done | sort)

	echo -e "$msg" | sed 's/^/  /' | column -t -s ';'
}

print_function_comment() {
	grep -r --include \*.sh "function $function_name" "$script_dir" | cut -d '#' -f2- | xargs
}

print_function_name_and_comment() {
	comment=$(print_function_comment)
	echo "$(bold)$function_name$(normal) $([[ -n "$comment" ]] && echo "- $comment")"
}
