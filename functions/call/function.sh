# Return success => shift away function_name argument from positional args
_orb_get_current_function() {
	if [[ $_orb_sourced == true ]]; then
		echo "$(_orb_get_current_function_from_trace)"
		return 2
	else
		echo "$1"
	fi
}

_orb_get_current_function_from_trace() {
	local i=0
	local fn; for fn in "${_orb_function_trace[@]}"; do
		if [[ $fn != "source" ]]; then
			echo "${_orb_function_trace[$i]}" 
			return
		fi
		(( i++ ))
	done
}

_orb_get_current_function_descriptor() { # $1 = $_orb_function_name $2 = $_orb_namespace
	local fn=$1
	local ns=$2

	if [[ -n $ns ]]; then
		echo "$ns->$(orb_bold)${fn}$(orb_normal)"
	else
		echo "$(orb_bold)${fn}$(orb_normal)"
	fi
}

# _orb_runtime_shell() {
# 	# https://unix.stackexchange.com/a/72475
# 	# Determine what (Bourne compatible) shell we are running under.
# 	:
# 	# local shell=sh


# 	# if test -n "$ZSH_VERSION"; then
# 	# 	shell=zsh
# 	# elif test -n "$BASH_VERSION"; then
# 	# 	shell=bash
# 	# elif test -n "$KSH_VERSION" || test -n "$FCEDIT"; then
# 	# 	shell=ksh
# 	# elif test -n "$PS3"; then
# 	# 	shell=unknown
# 	# fi

# }
