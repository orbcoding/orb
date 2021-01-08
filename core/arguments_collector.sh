#!/bin/bash
#
# Argument collector used for all functions
# Allowing them to define their own input args
#
# Arguments are specified for each function by
# declaring an associative array (key-val arr)
# with same name as function suffixed with "_args"
#
#
# For example:
#
# declare -A name_of_args_declaration=(
#		['1']='short description of first non-match flag arg; IN: value1|value2; DEFAULT: $checkedvar|value1'
#		['2']='second non-match flag arg; OPTIONAL'
#		['-r']='r flag description; DEFAULT: true'
# 	['-e arg']='-e flag followed by value arg; REQUIRED'
#		['*']='matches rest of args when non req inline arg fail IN requirement or not sought'
# ); function name_of_function() {}
#
# Flags should be single char to allow multiple flag statements such as -ri
# +r sets [-r]=false. Useful if [-r]=DEFAULT: true - Inspired by bash options https://tldp.org/LDP/abs/html/options.html
#
# Note the available argument properties
# - Numbered args are required unless prop OPTIONAL or supplied DEFAULT
# - Flag args are optional unless prop REQUIRED
# - IN lists multiple accepted values with |
# - DEFAULT can eval variables and falls back through | chain when undef.
# - ['*'] with CAN_START_WITH_FLAG allows unrecognized flag to start wildcard assignment
#
#
# Values are then stored in $args array
# and can be retrieved by eg:
#
# ${args["-e arg"]} => arg_value if applied
# ${args[-e]} => true if applied
# ${args['*']} => true if wildcards exist
# $args_wildcard holds wildcard args as nested arrays not supported
#
# Numbered args and wildcards also passed as inline args to function call.
# This allows expected access through: $1, $2, $@/$* etc
#
#
# If the first argument of any function is help
# An argument help output will be printed
#
#########################################

# Name ref to function defined args (from string variable)
declare -n args_declaration=${function_name}_args

# non-flagged args_nrs $1, $2... (* appended) will be passed forward so
# $1 == ${args[1]} (unless [1] optional and fail validation so cought by wildcard instead)
args_nrs=()
# if mixing numbered and wildcard input, this variable can be used to distinguish them
# args[*] only holds boolean as nested arrays not supported and string list wont preserve indexes
args_wildcard=()
declare -A args # all args
args_remaining=("$@") # array of input args each quoted
args_nrs_count=1


# Main function
parse_args() {
	if [[ ${#args_remaining[@]} > 0 && ! -v args_declaration[@] ]]; then
		error 'does not accept arguments' && kill_script
	fi
	set_arg_defaults
	collect_args
	post_validation
}

set_arg_defaults() {
	for arg in "${!args_declaration[@]}"; do
		value=$(get_arg_prop "$arg" DEFAULT)

		if [[ -z "$value" ]]; then
			# default flags and wildcard to false for ez conditions
			is_flag "$arg" || [[ "$arg" == '*' ]] && args["$arg"]=false
			continue
		fi
		# check each if default defined
		IFS='|' read -r -a options <<< $value # split by |
		for option in ${options[@]}; do
			value="$(eval_variable_or_string $option)"
		done

		args["$arg"]="$value"
		isnr $arg && args_nrs[$arg]="$value"
	done
}

collect_args() {
	# Start collecting from first input arg onwards
	while [[ ${#args_remaining[@]} -gt 0 ]]; do
		arg="${args_remaining[0]}"

		if is_flag "$arg"; then
			parse_flagged_arg "$arg"
		else
			parse_inline_arg "$arg"
		fi
	done
}

parse_flagged_arg() { # $1 arg_key
	if seeks_flag "$1"; then
		assign_flag "$1"
	elif seeks_flag_with_arg "$1"; then
		assign_flag_with_arg "$1"
	else
		invalid_flags=()
		try_assign_multiple_flags "$1"
		if [[ $? == 1 ]]; then
			if wildcard_can_start_with_flag && seeks_wildcard; then
				assign_wildcard
			else
				error_and_exit "${invalid_flags[*]}"
			fi
		fi
	fi
}

parse_inline_arg() { # $1 = arg_key
	# add numbered args to args and args_nrs
	if seeks_inline_arg && is_valid_arg "$args_nrs_count" "$1"; then
		assign_inline_arg "$1"
	elif seeks_wildcard; then
		assign_wildcard
	else
		error_and_exit "$args_nrs_count" "$1"
	fi
}


###################
# ARG HELPERS
###################
flag_value() {
	[[ ${1:0:1} == '-' ]] && echo true || echo false
}

seeks_flag() {
	[[ -n ${args_declaration["${1/+/-}"]} ]]
}

seeks_flag_with_arg() {
	[[ -n ${args_declaration["$1 arg"]} ]]
}

seeks_inline_arg() {
	[[ -n ${args_declaration["$args_nrs_count"]} ]]
}

seeks_wildcard() {
	[[ -n ${args_declaration['*']} ]]
}

wildcard_can_start_with_flag() {
	get_arg_prop "*" "CAN_START_WITH_FLAG"
}

assign_flag() {
	args["${1/+/-}"]=$(flag_value $1)
	shift_args
}

# if specified with arg suffix, set value to next arg and shift both
assign_flag_with_arg() {
	if is_valid_arg "$1 arg" "${args_remaining[1]}"; then
		args["$1 arg"]="${args_remaining[1]}"
		shift_args 2
	else
		error_and_exit "$1 arg ${args_remaining[1]}"
	fi
}

assign_inline_arg() {
	args_nrs[$args_nrs_count]="$1"
	args[$args_nrs_count]="$1"
	(( args_nrs_count++ ))
	shift_args
}

try_assign_multiple_flags() { # $1 arg_key
	flags=$(echo "${1:1}" | grep -o .)
	for flag in $flags; do
		if seeks_flag "-$flag"; then
			args["-$flag"]="$(flag_value "$1")"
		else
			invalid_flags+=(-$flag)
		fi
	done

	[[ ${#invalid_flags} == 0 ]] && shift_args || return 1
}

assign_wildcard() {
	args['*']=true # cant preserve spaces so put in wildcards
	args_wildcard+=("${args_remaining[@]}")
	args_remaining=()
}

##############
# VALIDATIONS
##############

is_valid_arg() { # $1 arg_key, $2 arg
	# is_valid_required "$1"
	is_valid_in "$1" "$2"
}

is_valid_in() { # $1 arg_key $2 arg
	in_str=$(get_arg_prop "$1" IN)
	[[ -z $in_str ]] && return 0 # Np if no in validation

	IFS='|' read -r -a in_arr <<< $in_str # split by |

	# check each unless found
	for in in ${in_arr[@]}; do
		val=$(eval_variable_or_string "$in")
		[[ "$2" == "$val" ]] && return 0 # return if found
	done

	return 1
}

post_validation() {
	for arg in "${!args_declaration[@]}"; do
		validate_required "$arg"
	done
}

validate_required() { # $1 arg
	if [[ -z ${args[$1]} ]] && is_required "$1"; then
		error_and_exit "$1" 'required'
	fi
}

is_required() { # $1 arg
	(is_flag "$1" &&  get_arg_prop "$1" 'REQUIRED') || \
	(! is_flag "$1" && ! get_arg_prop "$1" 'OPTIONAL')
}


###################
# HELPERS
##################

# Returns - if nothing found
#
get_arg_prop() { # $1 arg_key, $2 sub_property
	value=
	# with [*]=wildcard; CAN_START_WITH_FLAG prop an invalid flag can init assign to wildcard
	boolean_props=( REQUIRED OPTIONAL CAN_START_WITH_FLAG )
	if [[ "$2" == 'DESCRIPTION' ]]; then # Is first
		value="$(grepbetween "${args_declaration["$1"]}" '^' '(;|$)')"
	elif [[ " ${boolean_props[@]} " =~ " $2 " ]]; then
		echo "${args_declaration["$1"]}" | grep -q "$2" && return 0
	else # value props
		value="$(grepbetween "${args_declaration["$1"]}" "$2: " '(;|$)')"
	fi

	if [[ -n "$value" ]]; then
		echo "$value" && return 0
	else
		return 1
	fi
}

# shift one = remove first arg from arg array
shift_args() {
	steps=${1-1} # 1 default value
	for (( i = 0; i < $steps; i++ )); do
		args_remaining=("${args_remaining[@]:1}")
	done
}

error_and_exit() { # $1 arg_key $2 arg_value/required
	error "invalid args: $1"

	msg=""
	if [[ "$2" == 'required' ]]; then
		msg+=" is required"
	elif [[ -n "$2" ]]; then
		msg+=" with value $2"
	fi

	echo -e "$msg" >&2
	print_args_definition >&2
	kill_script
}

# Run main function
if [[ $1 == "help" ]]; then
	print_function_help
	exit 0
else
	parse_args
fi
