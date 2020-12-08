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
# function_args=$(declare -A | grep "-A ${function_name}_args=" | cut -d '=' -f2-)
# $function_args=$(eval ${function_name}_args)

# Name ref to function defined args (from string variable)
declare -n function_args=${function_name}_args
inline_args=() # $1, $2... will be passed forward to function call so $1 == ${args[1]}
declare -A args # all args
remaining_args=("$@") # array of input args each quoted

# Main function
parse_args() {
	set_arg_defaults
	collect_args
	validate_args
}

collect_args() {
	while [[ ${#remaining_args[@]} -gt 0 ]]; do
		arg="${remaining_args[0]}"

		if [[ ${arg:0:1} == '-' ]]; then
			handle_flagged_arg "$arg"
		else
			# add numbered args to args and inline_args
			inline_args+=("$arg")
			arg_nr=${#inline_args[@]}
			args[$arg_nr]="$arg"
			shift_args
		fi
	done
}


handle_flagged_arg() {
	# if function declared seeking flagged arg
	if [[ -v "function_args["$1"]" ]]; then
		args[$1]=true
		shift_args
	elif [[ -v "function_args[$1 arg]" ]]; then
		# if arg suffix, set value to next arg and shift both
		args["$1 arg"]=${remaining_args[1]}
		shift_args 2
	else
		echo "error, invalid param: $1"
		exit 1
		shift_args
	fi
}



set_arg_defaults() {
	for arg in "${!function_args[@]}"; do
		value=$(get_arg_value "$arg" DEFAULT)
		[[ -z $value ]] && return # Exit if no default param values

		IFS='|' read -r -a options <<< $value # split by |

		# check each unless defined
		for option in ${options[@]}; do
			if [[ ${option:0:1} == '$' ]]; then
				# is variable
				option="${option:1}" # rm $
				value="${!option}" # eval var name
				[[ -n "$value" ]] && break # break if exists
			else
				# is static value
				value="$option" # set it and break
				break;
			fi
		done

		args["$arg"]="$value"
	done
}

validate_args() { # $1 arg
	for arg in "${!function_args[@]}"; do
		validate_required "$arg"
		validate_in "$arg"
	done
}

validate_required() { # $1 arg
	echo "${function_args[$1]}" | grep -q 'REQUIRED' && \
	[[ -z ${args[$1]} ]] && \
	echo "error, $1 is required" && \
	exit 1
}

validate_in() { # $1 arg
	[[ -z ${args[$1]} ]] && return # Exit if empty
	in_str=$(get_arg_value "$1" IN)
	[[ -z $in_str ]] && return # Exit if no validations

	IFS='|' read -r -a in_arr <<< $in_str # split by |

	# check each unless found
	for in in ${in_arr[@]}; do
		val=$(eval_variable_or_string "$in")
		[[ "${args[$arg]}" == "$val" ]] && return # return if found
	done

	# error if not found in IN
	echo "error, $arg not in IN $in_str"
	exit 1
}


get_arg_value() { # $1 arg_key, $2 sub_property
	echo "$($utils grepbetween "${function_args[$1]}" "$2: " '(;|$)')"
}

eval_variable_or_string() { # $1 $variable/string (in string format)
	str="$1"
	if [[ ${str:0:1} == '$' ]]; then # is variable
		str="${str:1}" # rm $
		echo "${!str}" # eval var name
	else # is static value
		echo "$str" # set it and break
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
parse_args




	# if [[ $function_name == 'runremote' ]]; then
	#     # take all following args to remote
	#     args+=("$1")
	#     shift
	# else

	# fi



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
