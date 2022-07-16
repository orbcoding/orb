#!/bin/bash
#
# Function arguments collector
#
# Arguments are checked against the functions orb declaration
# _orb_parse_declaration should have been called before


# Main function
_orb_parse_function_args() {
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
	
	if [[ ${#_orb_declared_args[@]} == 0 ]]; then
		if [[ ${#args_remaining[@]} != 0 ]]; then
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

		if orb_is_any_flag "$arg"; then 
			_orb_collect_flag_arg "$arg"
		elif orb_is_block "$arg"; then
			_orb_collect_block_arg "$arg"
		else
			_orb_collect_inline_arg "$arg"
		fi
	done
}

_orb_collect_flag_arg() { # $1 input_arg
	local arg=$1

	if _orb_has_declared_boolean_flag $arg; then
		_orb_assign_boolean_flag "$arg"
	elif _orb_has_declared_flagged_arg "$arg"; then
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
	local arg=$1

	if _orb_has_declared_arg "$arg"; then
		_orb_assign_block "$arg"
	else
		_orb_try_inline_arg_fallback "$arg" "$arg"
	fi
}

_orb_collect_inline_arg() { # $1 = input_arg
	local arg=$1
	# add numbered args to args and _args_nrs
	if [[ "$arg" == '--' ]] && _orb_has_declared_arg $1; then
		_orb_assign_dash_wildcard
	elif _orb_has_declared_arg "$args_count" && _orb_is_valid_arg "$args_count" "$arg"; then
		_orb_assign_inline_arg "$arg"
	elif _orb_has_declared_arg '...'; then
		_orb_assign_rest
	else
		_orb_raise_invalid_arg "$args_count with value ${1:-\"\"}"
	fi
}

_orb_try_inline_arg_fallback() {
	# If failed to parse flags or block, fall back to inline args 
	local arg=$1
	local failed_arg=$2 # usually the same unless multiflag

	if _orb_has_declared_arg "$args_count" && _orb_arg_catches "$args_count" "$arg" && _orb_is_valid_arg "$args_count" "$1"; then
		_orb_assign_inline_arg "$arg"
	elif _orb_has_declared_arg "..." && _orb_arg_catches "..." "$arg"; then
		_orb_assign_rest
	else
		_orb_raise_invalid_arg "$failed_arg"
	fi
}

_orb_try_parse_multiple_flags() { # $1 arg
	if orb_is_verbose_flag "$1"; then
		invalid_flags+=( "$1" )
		return 1 # only single boolean flags can be multi-flags
	fi

	# split to individual flags
	local flags=$(echo "${1:1}" | grep -o . | sed s/^/-/g )
	local valid_flags=()

	# collect all invalid flags for verbose error
	local flag; for flag in $flags; do
		if _orb_has_declared_arg "$flag"; then
			valid_flags+=($flag)
		else
			invalid_flags+=($flag)
		fi
	done

	# assign flags only if no invalids
	[[ ${#invalid_flags} != 0 ]] && return 1

	local shift_steps=1
	local flag; for flag in "${valid_flags[@]}"; do
		local suffix=${_orb_declared_arg_suffixes[$flag]}

		if [[ -z "$suffix" ]]; then 
			_orb_assign_boolean_flag "$flag" 0
		else
			_orb_assign_flagged_arg "$flag" 0
			(( $suffix > $shift_steps )) && shift_steps=$suffix
		fi
	done

	_orb_shift_args $shift_steps 
}

_orb_set_args_positional() {
	_orb_positional=( "${_args_nrs[@]}" "${_orb_wildcard[@]}" )
}

