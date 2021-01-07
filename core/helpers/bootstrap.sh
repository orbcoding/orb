# Unset all commands prefixed with function except for the one called
# Effectively only allowing functions to be called with orb prefix and arg handling
unset_all_functions_except_called_and_wrapper() {
	while read fn; do
			[[ $fn != $function_name && $fn != 'orb' ]] && unset -f ${fn}
	done <  <( declare -F | cut -d" " -f3 )
}

handle_function_is_help_or_missing() {
	if [[ "$function_name" == 'help' ]]; then
		print_script_help && exit 0
	elif ! declare -F | grep -q "$function_name"; then
		[[ -z "$function_name" ]] &&  echo -e "$(color red)Error: no function provided$(color none)" \
			|| echo -e "$(red)Error:$(nocolor) $script_name->$(bold)$function_name$(reset) undefined"
		exit 1
	fi
}
