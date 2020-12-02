#!/bin/bash
#
# Argument collector used for all functions
# Allowing them to define their own arg deps
#
# Arguments are specified for each function by
# declaring an associative array (key-val arr)
# with same name as function suffixed with "_args"
#
# For example
#
# declare -A name_of_function_args=(
#		[1]="first unflagged input arg"
#		[-r]="r flag description"
# 	[-e arg]="-e flag followed by value arg"
# )
#
# Values are then stored in $args array
# and can be retrieved by eg:
#
# ${args["-e arg"]}
#
#########################################

# Default args
# env="dev"
# service="web"
# f_arg=0
# r_arg=0
# args=()
function_args="${function_name}_args"
declare -A args
remaining_args=($@) # array of input args so can access from handle func
arg_count=1 # non-flagged args, first = 1 to mimic $@


# Main function
collect_args() {
	while [[ ${#remaining_args} -gt 0 ]]; do
	arg="${remaining_args[0]}"

	case $arg in
		-e|-s|-f|-r|-db)
			handle_flagged_arg $arg
			# shift
			# env="$2"
			# set_env=1
			# if [[ $env != 'prod' && $env != 'staging' && $env != 'dev' && $env != 'idle' ]]; then
			#     echo '-e not prod/staging/idle/dev'
			#     exit 1
			# fi
			# shift # past argument
			# shift # past value
		;;
		*) # Unflagged argument
			args[$arg_count]=$arg
			((arg_count++))
			shift_args
		;;
	esac

	# if [[ $function_name == 'runremote' ]]; then
	#     # take all following args to remote
	#     args+=("$1")
	#     shift
	# else

	# fi
done
}

# .env overrides
# if [[ -n $DEFAULT_ENV ]]; then
# 	echo "Default env $DEFAULT_ENV"
# 	env=$DEFAULT_ENV
# fi
# if [[ -n $DEFAULT_SERVICE ]]; then
# 	echo "Default service $DEFAULT_SERVICE"
# 	service=$DEFAULT_SERVICE
# fi


# function arg_help() {
#     echo "\
#     -e  = env      (def=dev)
#     -s  = service  (def=web)
#     -f  = force/follow
#     -r  = restart
#     -db = db"
# }


handle_flagged_arg() { # $1 = argument
	# if function declared seeking flagged arg
	if [[ -v "$function_args[$1]" ]]; then
		args[$1]=true
		shift_args
	elif [[ -v "$function_args[$1 arg]" ]]; then
		# if arg suffix, set value to next arg and shift both
		args["$1 arg"]=${remaining_args[1]}
		shift_args 2
	else
		echo "invalid param -e"
		shift_args
	fi
}

# shift one = remove first arg from arg array
shift_args() {
	steps=${1-1} # 1 default value
	for (( i = 0; i < $steps; i++ )); do
		remaining_args=(${remaining_args[@]:1})
	done
}


# Run main function
collect_args


