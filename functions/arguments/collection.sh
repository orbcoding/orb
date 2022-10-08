#!/bin/bash
#
# Function arguments collector
#
# Arguments are checked against the functions orb declaration
# _orb_parse_function_declaration should have been called before
#
# OBS
# All local variables in this file have to be _orb prefixed to not block assignment to declared value variables
#
# Main function
_orb_collect_function_args() {
	local _orb_args_count=1
	local _orb_args_remaining=( "$@" ) # array of input args each quoted
	
	if [[ ${#_orb_declared_args[@]} == 0 ]]; then
		if [[ ${#_orb_args_remaining[@]} != 0 ]]; then
			_orb_raise_error "does not accept arguments"
		else # no args to parse
			return 0
		fi
	fi

	_orb_collect_args
	_orb_args_post_validation
}

_orb_collect_args() {
	# Start collecting from first input arg onwards
	while [[ ${#_orb_args_remaining[@]} > 0 ]]; do
		local _orb_arg="${_orb_args_remaining[0]}"

		if orb_is_any_flag "$_orb_arg"; then 
			_orb_collect_flag_arg "$_orb_arg"
		elif orb_is_block "$_orb_arg"; then
			_orb_collect_block_arg "$_orb_arg"
		else
			_orb_collect_inline_arg "$_orb_arg"
		fi
	done
}

_orb_collect_flag_arg() { # $1 input_arg
	local _orb_arg=$1

	if _orb_has_declared_boolean_flag $_orb_arg; then
		_orb_assign_boolean_flag "$_orb_arg"
	elif _orb_has_declared_flagged_arg "$_orb_arg"; then
		_orb_assign_flagged_arg "$_orb_arg"
	else
		local _orb_invalid_flags=()
		_orb_try_collect_multiple_flags "$_orb_arg"

		if [[ $? == 1 ]]; then 
			_orb_try_inline_arg_fallback "$_orb_arg" "${_orb_invalid_flags[*]}"
		fi
	fi
}

_orb_collect_block_arg() {
	local _orb_arg=$1

	if _orb_has_declared_arg "$_orb_arg"; then
		_orb_assign_block "$_orb_arg"
	else
		_orb_try_inline_arg_fallback "$_orb_arg" "$_orb_arg"
	fi
}

_orb_collect_inline_arg() { # $1 = input_arg
	local _orb_arg=$1
	# add numbered args to args and _args_nrs
	if [[ "$_orb_arg" == '--' ]] && _orb_has_declared_arg $_orb_arg; then
		_orb_assign_dash
	elif _orb_has_declared_arg "$_orb_args_count" && _orb_is_valid_arg "$_orb_args_count" "$_orb_arg"; then
		_orb_assign_inline_arg "$_orb_arg"
	elif _orb_has_declared_arg '...'; then
		_orb_assign_rest
	else
		_orb_raise_invalid_arg "$_orb_args_count with value ${1:-\"\"}"
	fi
}

_orb_try_inline_arg_fallback() {
	# If failed to parse flags or block, fall back to inline args 
	local _orb_arg=$1
	local _orb_failed_arg=$2 # usually the same unless multiflag

	if _orb_has_declared_arg "$_orb_args_count" && _orb_is_valid_arg "$_orb_args_count" "$_orb_arg" && _orb_arg_catches "$_orb_args_count" "$_orb_arg"; then
		_orb_assign_inline_arg "$_orb_arg"
	elif _orb_has_declared_arg "..." && _orb_arg_catches "..." "$_orb_arg"; then
		_orb_assign_rest
	else
		_orb_raise_invalid_arg "$_orb_failed_arg"
	fi
}

_orb_try_collect_multiple_flags() { # $1 arg
	if orb_is_verbose_flag "$1"; then
		_orb_invalid_flags+=( "$1" )
		return 1 # only single boolean flags can be multi-flags
	fi

	# split to individual flags
	local _orb_flags=$(echo "${1:1}" | grep -o . | sed s/^/-/g )
	local _orb_valid_flags=()

	# collect all invalid flags for verbose error
	local _orb_flag; for _orb_flag in $_orb_flags; do
		if _orb_has_declared_arg "$_orb_flag"; then
			_orb_valid_flags+=($_orb_flag)
		else
			_orb_invalid_flags+=($_orb_flag)
		fi
	done

	# assign flags only if no invalids
	[[ ${#_orb_invalid_flags} != 0 ]] && return 1

	local _orb_shift_steps=1
	local _orb_flag; for _orb_flag in "${_orb_valid_flags[@]}"; do
		local _orb_suffix=${_orb_declared_arg_suffixes[$_orb_flag]}

		if [[ -z "$_orb_suffix" ]]; then 
			_orb_assign_boolean_flag "$_orb_flag" 0
		else
			_orb_assign_flagged_arg "$_orb_flag" 0
			(( $_orb_suffix >= $_orb_shift_steps )) && _orb_shift_steps=$((_orb_suffix + 1))
		fi
	done

	_orb_shift_args $_orb_shift_steps 
}

