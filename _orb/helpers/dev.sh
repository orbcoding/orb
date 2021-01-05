function print_args() { # print collected arguments from arguments.sh, useful for debugging
	declare -A | grep 'A args=' | cut -d '=' -f2-
	[[ ${args["*"]} == true ]] && echo "[*]=${args_wildcard[*]}"
}


declare -A toerr_args=(
  ['1']='msg'
); function toerr() { # echo to stderr, useful for debugging functions that return values in stdout
  echo "$1" >&2
}


declare -A error_args=(
	['1']='message'
); function error() {
	msg=( "$(orb red)$(orb bold)Error:$(orb nostyle)" )
	if [[ -n ${parent_script_name} && -n ${parent_function_name} ]]; then
    script=$parent_script_name
    fn=$parent_function_name
  else
    script=$script_name
    fn=$function_name
	fi
  msg+=( "${script}->$(orb bold)${fn}" )
	msg+=( $(orb nostyle)$1 )
	echo -e ${msg[*]}
};
