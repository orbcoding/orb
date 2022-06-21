#!/bin/bash
#
# Argument collector used for all functions
# Allowing them to define their own input args
#
# Arguments are specified for each function by
# declaring an associative array (key-val arr)
# with same name as function suffixed with "_args"

# Main function
_orb_parse_orb_prefixed_args() {
  if [[ $1 == "--help" ]]; then
    _orb_print_function_help && exit 0
  elif $_orb_setting_direct_call; then
    _orb_args_positional=("$@")
  else
    _orb_parse_args "$@"
  fi
}

_orb_parse_args() {
	local args_count=1
	local args_remaining=( "$@" ) # array of input args each quoted
	
	if [[ ! -v _orb_declaration[@] ]]; then
		if [[ ${#args_remaining[@]} > 0 ]]; then
			orb_raise_error "does not accept arguments"
		else # no args to parse
			return 0
		fi
	fi

	_orb_collect_args
	_orb_set_arg_defaults # parse defaults after collection so default could depend on other values mb later
	_orb_args_post_validation
	_orb_set_args_positional
}

_orb_collect_args() {
	# Start collecting from first input arg onwards
	while [[ ${#args_remaining[@]} > 0 ]]; do
		local arg="${args_remaining[0]}"

		if orb_is_flag "$arg"; then 
			_orb_collect_flag_arg "$arg"
		elif orb_is_block "$arg"; then
			_orb_collect_block_arg "$arg"
		else
			_orb_collect_inline_arg "$arg"
		fi
	done
}

_orb_collect_flag_arg() { # $1 arg_key
	local arg=$1
	local args_i

	if _orb_is_declared_boolean_flag $arg; then
		_orb_assign_flag "$arg"
	elif _orb_is_declared_flagged_arg "$arg"; then
		_orb_assign_flagged_arg "$arg"
	else
		local invalid_flags=()
		_orb_try_parse_multiple_flags "$arg"
		if [[ $? == 1 ]]; then 
			_orb_try_inline_arg_fallback "$arg" "${invalid_flags[*]}"
		fi
	fi
}

_orb_collect_block_arg() {
	if _orb_declared_block "$1"; then
		_orb_assign_orb_block "$1"
	else
		_orb_try_inline_arg_fallback "$1" "$1"
	fi
}

_orb_collect_inline_arg() { # $1 = arg_key
	# add numbered args to args and _args_nrs
	if [[ "$1" == '--' ]] && _orb_declared_dash_wildcard; then
		_orb_assign_dash_wildcard
	elif _orb_declared_inline_arg "$args_count" && _orb_is_valid_arg "$args_count" "$1"; then
		_orb_assign_inline_arg "$1"
	elif _orb_declared_wildcard; then
		_orb_assign_wildcard
	else
		_orb_raise_invalid_arg "$args_count with value ${1:-\"\"}"
	fi
}

_orb_try_inline_arg_fallback() {
	# If failed to parse flags, fall back to inline args 
	if _orb_declared_inline_arg "$args_count" && _orb_catches_any "$args_count" && _orb_is_valid_arg "$args_count" "$1"; then
		_orb_assign_inline_arg "$1"
	elif _orb_declared_wildcard && _orb_catches_any '*'; then
		_orb_assign_wildcard
	else
		_orb_raise_invalid_arg "${@:2}"
	fi
}

_orb_try_parse_multiple_flags() { # $1 arg_key
	if orb_is_verbose_flag "$1"; then
		invalid_flags+=( "$1" )
		return 1 # only single boolean flags can be multi-flags
	fi

	local _flags=$(echo "${1:1}" | grep -o . | sed s/^/-/g )
	local _shift_steps=1
	local _to_orb_assign_flags=()
	local _to_orb_assign_flagged_args=()

	local _flag; for _flag in $_flags; do
		if _orb_is_declared_boolean_flag "$_flag"; then
			_to_orb_assign_flags+=("$_flag")
		elif _orb_is_declared_flagged_arg "$_flag"; then
			_to_orb_assign_flagged_args+=($_flag)
		else
			invalid_flags+=($_flag)
		fi
	done

	# assign flags only if no invalids
	if [[ ${#invalid_flags} == 0 ]]; then
		local _flag; for _flag in "${_to_orb_assign_flags[@]}"; do
			_orb_assign_flag "$_flag" 0
		done

		local _flag; for _flag in "${_to_orb_assign_flagged_args[@]}"; do
			_orb_assign_flagged_arg "$_flag" 0 && _shift_steps=2
		done

		_orb_shift_args $_shift_steps
	else
		return 1
	fi
}

_orb_set_args_positional() {
	_orb_positional=( "${_args_nrs[@]}" "${_orb_wildcard[@]}" )
}

