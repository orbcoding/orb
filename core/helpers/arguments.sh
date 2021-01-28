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
#		['*']='matches rest of args when non req inline arg fail IN requirement or not declared'
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
# - ['*'] or ['1'] (any nr) with ACCEPTS_FLAGS allows unrecognized flag to start assignment
#
#
# Values are then stored in $_args array
# and can be retrieved by eg:
#
# ${_args["-e arg"]} => arg_value if applied
# ${_args[-e]} => true if applied
# ${_args['*']} => true if wildcards exist
# $_args_wildcard holds wildcard args as nested arrays not supported
#
# Numbered args and wildcards also passed as inline args to function call.
# This allows expected access through: $1, $2, $@/$* etc
#
#
# If the first argument of any function is --help
# An argument help output will be printed
#
#########################################

# Main function
_parse_args() {
	local _args_nrs_count=1
	local _args_remaining=("$@") # array of input args each quoted
	if [[ ! -v _args_declaration[@] ]]; then
		if [[ ${#_args_remaining[@]} > 0 ]]; then
			orb -c utils raise_error "does not accept arguments"
		else # no args to parse
			return 0
		fi
	fi

	_set_arg_defaults
	_collect_args
	_post_validation
}

_set_arg_defaults() {
	for _arg in "${!_args_declaration[@]}"; do
		local _default _value _def
		_def="$(_arg_default_prop)" && _default="$_def"

		if [[ -z "${_default+x}" ]]; then
			# DEFAULT == null => set flags and wildcard to false for ez conditions
			_is_flag "$_arg" || [[ "$_arg" == '*' ]] && _args["$_arg"]=false
		elif _value=$(_eval_variable_or_string_options "$_default"); then
			# evaled DEFAULT value != null
			_args["$_arg"]="$_value"
			_is_nr "$_arg" && _args_nrs["$args_nr"]="$_value"
		# else eval DEFAULT value == null => do nothing
		fi
	done
}

_collect_args() {
	# Start collecting from first input arg onwards
	while [[ ${#_args_remaining[@]} > 0 ]]; do
		local _arg="${_args_remaining[0]}"
		[[ _arg == '""' ]] && _arg="" # "" => empty string

		if _is_flag "$_arg"; then
			_parse_flag_arg "$_arg"
		else
			_parse_inline_arg "$_arg"
		fi
	done
}

_parse_flag_arg() { # $1 arg_key
	if _declared_flag "$1"; then
		_assign_flag "$1" && _shift_args
	elif _declared_flag_with_arg "$1"; then
		_assign_flag_with_arg "$1" && _shift_args 2
	else
		local _invalid_flags=()
		_try_assign_multiple_flags "$1"
		if [[ $? == 1 ]]; then
			if _declared_inline_arg && _accepts_flags "$_args_nrs_count" && _is_valid_arg "$_args_nrs_count" "$1"; then
				_assign_inline_arg "$1"
			elif _declared_wildcard && _accepts_flags '*'; then
				_assign_wildcard
			else
				_error_and_exit "${_invalid_flags[*]}"
			fi
		fi
	fi
}

_parse_inline_arg() { # $1 = arg_key
	# add numbered args to args and _args_nrs
	if _declared_inline_arg && _is_valid_arg "$_args_nrs_count" "$1"; then
		_assign_inline_arg "$1"
	elif _declared_wildcard; then
		_assign_wildcard
	else
		_error_and_exit "$_args_nrs_count" "$1"
	fi
}


###################
# ARG HELPERS
###################
_is_flag_with_arg() { # starts with - and has substr ' arg'
	[[ "${1}" =~ ^[-]{1,2}[a-zA-Z_-]+[[:space:]]arg$ ]]
}

_flag_value() {
	[[ ${1:0:1} == '-' ]] && echo true || echo false
}

_declared_flag() { # $1 arg $2 optional args_declaration
	declare -n _declaration=${2-"_args_declaration"}
	[[ -n ${_declaration["${1/+/-}"]} ]]
}

_declared_flag_with_arg() { # $1 arg $2 optional args_declaration
	declare -n _declaration=${2-"_args_declaration"}
	[[ -n ${_declaration["$1 arg"]} ]]
}

_declared_inline_arg() {
	[[ -n ${_args_declaration["$_args_nrs_count"]} ]]
}

_declared_wildcard() {
	[[ -n ${_args_declaration['*']} ]]
}

_assign_flag() {
	_args["${1/+/-}"]=$(_flag_value "$1")
}

# if specified with arg suffix, set value to next arg and shift both
_assign_flag_with_arg() {
	if _is_valid_arg "$1 arg" "${_args_remaining[1]}"; then
		_args["$1 arg"]="${_args_remaining[1]}"
	else
		_error_and_exit "$1 arg" "${_args_remaining[1]}"
	fi
}

_assign_inline_arg() {
	_args_nrs[$_args_nrs_count - 1]="$1"
	_args[$_args_nrs_count]="$1"
	(( _args_nrs_count++ ))
	_shift_args
}

_try_assign_multiple_flags() { # $1 arg_key
	if _is_verbose_flag "$1"; then
		_invalid_flags+=( "$1" )
		return 1 # only boolean flags can be multi-flags
	fi

	local _flags=$(echo "${1:1}" | grep -o .)
	local _shift_steps=1

	for _flag in $_flags; do
		if _declared_flag "-$_flag"; then
			_assign_flag "-$_flag"
		elif _declared_flag_with_arg "-$_flag"; then
			_assign_flag_with_arg "-$_flag" && _shift_steps=2
		else
			_invalid_flags+=(-$_flag)
		fi
	done

	if [[ ${#_invalid_flags} == 0 ]]; then
		_shift_args $_shift_steps
	else
		return 1
	fi
}

_assign_wildcard() {
	_args['*']=true # cant preserve spaces so put in wildcards
	_args_wildcard+=("${_args_remaining[@]}")
	_args_remaining=()
}

###########################
# VALIDATIONS AND ARG PROPS
###########################

_is_valid_arg() { # $1 arg_key, $2 arg
	_is_valid_in "$1" "$2" && _is_valid_empty "$1" "$2"
}

_is_valid_in() { # $1 arg_key $2 arg
	local _in_str=$(_get_arg_prop "$1" IN)
	[[ -z $_in_str ]] && return 0 # Np if no in validation

	IFS='|' read -r -a _in_arr <<< $_in_str # split by |

	# check each unless found
	local _in; for _in in ${_in_arr[@]}; do
		local _val=$(_eval_variable_or_string "$_in")
		[[ "$2" == "$_val" ]] && return 0 # return if found
	done

	return 1
}

_is_valid_empty() { # $1 arg_key, $2 arg
	if [[ ( -z "$2" && -n ${2+x} ) || "$2" == '""' ]]; then
		# is empty str
		if ! _accepts_empty_string "$1"; then
		 	return 1
		fi
	fi
}

_post_validation() {
	local _arg; for _arg in "${!_args_declaration[@]}"; do
		_validate_required "$_arg"
	done
}

_validate_required() { # $1 arg, $2 optional args_declaration
	if [[ -z ${_args["$1"]+x} ]] && _is_required "$1" $2; then
		_error_and_exit "$1" 'required'
	fi
}

_is_required() { # $1 arg, $2 optional args_declaration
	( (_is_flag "$1" || _is_flag_with_arg "$1") && _get_arg_prop "$1" 'REQUIRED' $2) || \
	( (! _is_flag "$1" && ! _is_flag_with_arg "$1") && ! _get_arg_prop "$1" 'OPTIONAL' $2)
}

_accepts_flags() { # $1 arg, $2 optional args_declaration
	_get_arg_prop "$1" "ACCEPTS_FLAGS" $2
}

_accepts_empty_string() {
	_get_arg_prop "$1" "ACCEPTS_EMPTY_STRING" $2
}

_arg_default_prop() { # $1 arg, $2 optional args_declaration
	_get_arg_prop "$_arg" DEFAULT $2
}


###################
# HELPERS
##################
_get_arg_prop() { # $1 arg_key, $2 sub_property, $3 optional args_declaration_variable
	declare -n _declaration=${3-"_args_declaration"}
	local _value

	local _boolean_props=( REQUIRED OPTIONAL ACCEPTS_FLAGS ACCEPTS_EMPTY_STRING)

	if [[ "$2" == 'DESCRIPTION' ]]; then # Is first
		local _val="$(_grep_between "${_declaration["$1"]}" '^' '(;|$)')" && _value="$_val"
	elif [[ " ${_boolean_props[@]} " =~ " $2 " ]]; then
		echo "${_declaration["$1"]}" | grep -q "$2" && return 0
	else # value props
		local _val="$(_grep_between "${_declaration["$1"]}" "$2: " '(;|$)')" && _value="$_val"
	fi

	if [[ -n "${_value+x}" ]]; then
		echo "$_value" && return 0
	else
		return 1
	fi
}

# shift one = remove first arg from arg array
_shift_args() {
	local _steps=${1-1} # 1 default value
	local _i; for (( _i = 0; _i < $_steps; _i++ )); do
		_args_remaining=("${_args_remaining[@]:1}")
	done
}

_error_and_exit() { # $1 arg_key $2 arg_value/required
	local _arg
	[[ ${1:0:1} == '-' ]] && _arg='flags' || _arg='args'
	local _msg="invalid $_arg: $1"
	if [[ "$2" == 'required' ]]; then
		_msg+=" is required"
	elif [[ -n "$2" && "$2" != '""' ]]; then # non empty string
		_msg+=" with value $2"
	elif [[ -n "${2+x}" ]]; then # empty string
		_msg+=" with value \"\""
		_msg+="\n\n Add ACCEPTS_EMTPY_STRING to $1 declaration if empty string is acceptable"
	fi

	_msg+="\n\n$(_print_args_explanation)"

	orb -c utils raise_error "$_msg"
}


