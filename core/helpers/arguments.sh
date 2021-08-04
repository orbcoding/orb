#!/bin/bash
#
# Argument collector used for all functions
# Allowing them to define their own input args
#
# Arguments are specified for each function by
# declaring an associative array (key-val arr)
# with same name as function suffixed with "_args"

# Main function
_parse_args() {
	local _args_nrs_count=1
	local _args_remaining=("$@") # array of input args each quoted
	if [[ ! -v _args_declaration[@] ]]; then
		if [[ ${#_args_remaining[@]} > 0 ]]; then
			_raise_error "does not accept arguments"
		else # no args to parse
			return 0
		fi
	fi

	_collect_args
	_set_arg_defaults # parse defaults after collection so default could depend on other values mb later
	_post_validation
}

_set_arg_defaults() {
	local _arg; for _arg in "${!_args_declaration[@]}"; do
	# _ee "hej ${_arg}"
	# _ee "${_args["$_arg"]+x}"
		[[ -n ${_args["$_arg"]+x} ]] && continue # next if already has value

		local _def _default _value
		_def="$(_arg_default_prop)" && _default="$_def"

		if [[ -z ${_default+x} ]]; then
			# DEFAULT == null => set flags blcoks, and wildcard to false for ez conditions
			_is_flag "$_arg" || _is_wildcard "$_arg" || _is_block "$_arg" && _args["$_arg"]=false
		elif _value=$(_eval_variable_or_string_options "$_default"); then
			# evaled DEFAULT value != null
			_assign_default
		# else eval DEFAULT value == null => do nothing
		fi; 
		unset _def _default _value
	done
}

_assign_default() {
	[[ "$_value" == "unset" ]] && return

	if [[ "$_arg" == '*' ]]; then
		_args_wildcard+=("$_value")
		_args["$_arg"]=true
	elif [[ "$_arg" == '-- *' ]]; then
		_args_dash_wildcard+=("$_value")
		_args["$_arg"]=true
	elif _is_block "$_arg"; then
		local _arr_name="$(_block_to_arr_name "$_arg")"
		declare -n _arr_ref="$_arr_name"
		_arr_ref+=("$_value")
		_args[$_arg]=true
	else
		_args["$_arg"]="$_value"
		_is_nr "$_arg" && _args_nrs["$args_nr"]="$_value"
	fi
}

_collect_args() {
	# Start collecting from first input arg onwards
	while [[ ${#_args_remaining[@]} > 0 ]]; do
		local _arg="${_args_remaining[0]}"
		[[ _arg == '""' ]] && _arg="" # "" => empty string

		if _is_flag "$_arg"; then 
			_parse_flag_arg "$_arg"
		elif _is_block "$_arg"; then
			_parse_block_arg "$_arg"
		else
			_parse_inline_arg "$_arg"
		fi
	done
}

_parse_flag_arg() { # $1 arg_key
	if _declared_flag "$1"; then
		_assign_flag "$1"
	elif _declared_flagged_arg "$1"; then
		_assign_flagged_arg "$1"
	else
		local _invalid_flags=()
		_try_parse_multiple_flags "$1"
		if [[ $? == 1 ]]; then 
			_try_inline_arg_fallback "$1" "${_invalid_flags[*]}"
		fi
	fi
}

_parse_block_arg() {
	if _declared_block "$1"; then
		_assign_block "$1"
	else
		_try_inline_arg_fallback "$1" "$1"
	fi
}

_parse_inline_arg() { # $1 = arg_key
	# add numbered args to args and _args_nrs
	if [[ "$1" == '--' ]] && _declared_dash_wildcard; then
		_assign_dash_wildcard
	elif _declared_inline_arg "$_args_nrs_count" && _is_valid_arg "$_args_nrs_count" "$1"; then
		_assign_inline_arg "$1"
	elif _declared_wildcard; then
		_assign_wildcard
	else
		_raise_invalid_arg "$_args_nrs_count with value ${1:-\"\"}"
	fi
}

_try_inline_arg_fallback() {
	# If failed to parse flags, fall back to inline args 
	if _declared_inline_arg "$_args_nrs_count" && _catches_any "$_args_nrs_count" && _is_valid_arg "$_args_nrs_count" "$1"; then
		_assign_inline_arg "$1"
	elif _declared_wildcard && _catches_any '*'; then
		_assign_wildcard
	else
		_raise_invalid_arg "${@:2}"
	fi
}

_try_parse_multiple_flags() { # $1 arg_key
	if _is_verbose_flag "$1"; then
		_invalid_flags+=( "$1" )
		return 1 # only single boolean flags can be multi-flags
	fi

	local _flags=$(echo "${1:1}" | grep -o . | sed s/^/-/g )
	local _shift_steps=1
	local _to_assign_flags=()
	local _to_assign_flagged_args=()

	local _flag; for _flag in $_flags; do
		if _declared_flag "$_flag"; then
			_to_assign_flags+=("$_flag")
		elif _declared_flagged_arg "$_flag"; then
			_to_assign_flagged_args+=($_flag)
		else
			_invalid_flags+=($_flag)
		fi
	done

	# assign flags only if no invalids
	if [[ ${#_invalid_flags} == 0 ]]; then
		local _flag; for _flag in "${_to_assign_flags[@]}"; do
			_assign_flag "$_flag" 0
		done

		local _flag; for _flag in "${_to_assign_flagged_args[@]}"; do
			_assign_flagged_arg "$_flag" 0 && _shift_steps=2
		done

		_shift_args $_shift_steps
	else
		return 1
	fi
}


###################
# ARG HELPERS
###################
_flag_value() {
	[[ ${1:0:1} == '-' ]] && echo true || echo false
}

_assign_flag() {
	_args["${1/+/-}"]=$(_flag_value "$1")
	_shift_args ${2:-1}
}

# if specified with arg suffix, set value to next arg and shift both
_assign_flagged_arg() {
	if _is_valid_arg "$1 arg" "${_args_remaining[1]}"; then
		_args["$1 arg"]="${_args_remaining[1]}"
	else
		_raise_invalid_arg "$1 arg" "${_args_remaining[1]}"
	fi

	_shift_args ${2:-2}
}

_assign_block() {
	_shift_args
	[[ ${#_args_remaining[@]} > 0 ]] && \
	[[ ${_args_remaining[0]} != "$1" ]] && \
	_args["$1"]=true
	local _arr_name="$(_block_to_arr_name "$1")"
	declare -n _arr_ref="$_arr_name"
	local _arg; for _arg in "${_args_remaining[@]}"; do
		if [[ "$_arg" == "$1" ]]; then
			# end of block
			_shift_args
			return
		else
			_arr_ref+=("$_arg")
			_shift_args
		fi 
	done

	_raise_error "'$1' missing block end"
}

_assign_inline_arg() {
	_args_nrs[$_args_nrs_count - 1]="$1"
	_args[$_args_nrs_count]="$1"
	(( _args_nrs_count++ ))
	_shift_args
}

_assign_dash_wildcard() {
	_shift_args
	[[ ${#_args_remaining[@]} > 0 ]] && _args['-- *']=true
	_args_dash_wildcard+=("${_args_remaining[@]}")
	_args_remaining=()
}

_assign_wildcard() {
	_args['*']=true

	local _next_index=1
	local _arg; for _arg in ${_args_remaining[@]}; do
		_args_wildcard+=( "$_arg" )

		if [[ "${_args_remaining[$_next_index]}" == '--' ]]; then
			_shift_args $_next_index
			_assign_dash_wildcard
			return 0
		fi

		_next_index=$((_next_index + 1))
	done

 	_args_remaining=()
}

###########################
# VALIDATIONS AND ARG PROPS
###########################

_is_valid_arg() { # $1 arg_key, $2 arg
	_is_valid_in "$1" "$2"
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

_post_validation() {
	local _arg; for _arg in "${!_args_declaration[@]}"; do
		_validate_declaration "$_arg"
		_validate_required "$_arg"
		_validate_empty "$_arg"
	done
}

_validate_declaration() {
	_is_flag "$1" || \
	_is_flagged_arg "$1" || \
	_is_nr "$1" || \
	_is_block "$1" || \
	_is_wildcard "$1" || \
	_raise_invalid_arg "$1 invalid declaration"
}

_validate_required() { # $1 arg, $2 optional args_declaration
	if ( \
		[[ "$1" == '*' && ${_args['*']} == false ]] || \
		[[ "$1" == '-- *' && ${_args['-- *']} == false ]] || \
		(! _is_wildcard "$1" && [[ -z ${_args["$1"]+x} ]]) \
	) \
	&& _is_required "$1" $2; then
		_raise_invalid_arg "$1 is required"
	fi
}

_validate_empty() { # $1 arg_key
	if [[ -z "${_args["$1"]}" && -n ${_args["$1"]+x} ]]; then
		# is empty str
		if ! _catches_empty "$1"; then
			_raise_invalid_arg "$_arg with value \"\", add CATCH_ANY to allow empty string"
		fi
	fi
}

_is_required() { # $1 arg, $2 optional args_declaration
	( _is_flagged_arg "$1" && _get_arg_prop "$1" 'REQUIRED' $2) || \
	( _is_block "$1" && _get_arg_prop "$1" 'REQUIRED' $2) || \
	( (! _is_flag "$1" && ! _is_flagged_arg "$1" && ! _is_block "$1" ) && ! _get_arg_prop "$1" 'OPTIONAL' $2)
}

_catches_any() { # $1 arg, $2 optional args_declaration
	_get_arg_prop "$1" "CATCH_ANY" $2
}

_catches_empty() {
	_get_arg_prop "$1" "CATCH_EMPTY" $2
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

	local _boolean_props=( REQUIRED OPTIONAL CATCH_ANY CATCH_EMPTY )

	if [[ "$2" == 'DESCRIPTION' ]]; then # Is first
		local _val; _val="$(_grep_between "${_declaration["$1"]}" '^' '(;|$)')" && _value="$_val"
	elif [[ " ${_boolean_props[@]} " =~ " $2 " ]]; then
		echo "${_declaration["${1}"]}" | grep -q "$2" && return 0
	else # value props
		local _val; _val="$(_grep_between "${_declaration["$1"]}" "$2: " '(;|$)')" && _value="$_val"
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

_raise_invalid_arg() { # $1 arg_key $2 arg_value/required
	local _arg
	[[ ${1:0:1} == '-' ]] && ! _is_block "$1" && _arg='flags' || _arg='args'
	local _msg="invalid $_arg: $1"
	# if [[ "$2" == 'required' ]]; then
	# 	_msg+=" is required"
  # elif [[ "$2" == "invalid" ]]; then
	# 	_msg+=" invalid argument format"
	# elif [[ -n "$2" && "$2" != '""' ]]; then # non empty string
	# 	_msg+=" with value $2"
	# elif [[ -n "${2+x}" ]]; then # empty string
	# 	_msg+=" with value \"\""
	# 	_msg+="\n\n Add CATCH_EMPTY to arg $1 declaration if empty string is accepted"
	# fi

	_msg+="\n\n$(__print_args_explanation)"

	_raise_error "$_msg"
}


