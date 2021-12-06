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
  elif ${_orb_settings['-d']}; then
    _orb_positional=("$@")
  else
    _orb_parse_args "$@"
  fi
}

_orb_parse_args() {
	local _args_nrs_count=1
	local _args_remaining=("$@") # array of input args each quoted
	if [[ ! -v _orb_args_declaration[@] ]]; then
		if [[ ${#_args_remaining[@]} > 0 ]]; then
			_raise_error "does not accept arguments"
		else # no args to parse
			return 0
		fi
	fi

	_orb_collect_args
	_orb_set_arg_defaults # parse defaults after collection so default could depend on other values mb later
	_orb_post_validation
	_orb_set_orb_positional
}

_orb_collect_args() {
	# Start collecting from first input arg onwards
	while [[ ${#_args_remaining[@]} > 0 ]]; do
		local _arg="${_args_remaining[0]}"
		[[ _arg == '""' ]] && _arg="" # "" => empty string

		if _is_flag "$_arg"; then 
			_orb_parse_flag_arg "$_arg"
		elif _is_block "$_arg"; then
			_orb_parse_block_arg "$_arg"
		else
			_orb_parse_inline_arg "$_arg"
		fi
	done
}

_orb_parse_flag_arg() { # $1 arg_key
	if _orb_declared_flag "$1"; then
		_orb_assign_flag "$1"
	elif _orb_declared_flagged_arg "$1"; then
		_orb_assign_flagged_arg "$1"
	else
		local _invalid_flags=()
		_orb_try_parse_multiple_flags "$1"
		if [[ $? == 1 ]]; then 
			_orb_try_inline_arg_fallback "$1" "${_invalid_flags[*]}"
		fi
	fi
}

_orb_parse_block_arg() {
	if _orb_declared_block "$1"; then
		_orb_assign_orb_block "$1"
	else
		_orb_try_inline_arg_fallback "$1" "$1"
	fi
}

_orb_parse_inline_arg() { # $1 = arg_key
	# add numbered args to args and _args_nrs
	if [[ "$1" == '--' ]] && _orb_declared_dash_wildcard; then
		_orb_assign_dash_wildcard
	elif _orb_declared_inline_arg "$_args_nrs_count" && _orb_is_valid_arg "$_args_nrs_count" "$1"; then
		_orb_assign_inline_arg "$1"
	elif _orb_declared_wildcard; then
		_orb_assign_wildcard
	else
		_orb_raise_invalid_arg "$_args_nrs_count with value ${1:-\"\"}"
	fi
}

_orb_try_inline_arg_fallback() {
	# If failed to parse flags, fall back to inline args 
	if _orb_declared_inline_arg "$_args_nrs_count" && _orb_catches_any "$_args_nrs_count" && _orb_is_valid_arg "$_args_nrs_count" "$1"; then
		_orb_assign_inline_arg "$1"
	elif _orb_declared_wildcard && _orb_catches_any '*'; then
		_orb_assign_wildcard
	else
		_orb_raise_invalid_arg "${@:2}"
	fi
}

_orb_try_parse_multiple_flags() { # $1 arg_key
	if _is_verbose_flag "$1"; then
		_invalid_flags+=( "$1" )
		return 1 # only single boolean flags can be multi-flags
	fi

	local _flags=$(echo "${1:1}" | grep -o . | sed s/^/-/g )
	local _shift_steps=1
	local _to_orb_assign_flags=()
	local _to_orb_assign_flagged_args=()

	local _flag; for _flag in $_flags; do
		if _orb_declared_flag "$_flag"; then
			_to_orb_assign_flags+=("$_flag")
		elif _orb_declared_flagged_arg "$_flag"; then
			_to_orb_assign_flagged_args+=($_flag)
		else
			_invalid_flags+=($_flag)
		fi
	done

	# assign flags only if no invalids
	if [[ ${#_invalid_flags} == 0 ]]; then
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

_orb_set_orb_positional() {
	_orb_positional=( "${_args_nrs[@]}" "${_orb_wildcard[@]}" )
}

