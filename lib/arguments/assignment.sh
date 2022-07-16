_orb_assign_arg_value() {
	local arg=$1 && shift
	local var=${_orb_declared_vars[$arg]}
	_orb_args_values_start_indexes[$arg]=${#_orb_args_values[@]}
	_orb_args_values+=("$@")
	_orb_args_values_lengths[$arg]=$#

	declare -n var_ref=$var
	if _orb_has_declared_array $arg; then
		var_ref=("$@")
	else
		var_ref="$@"
	fi
}

_orb_assign_boolean_flag() {
	local arg="${1/+/-}"
	local value=$(_orb_flag_value "$1")
	_orb_assign_arg_value $arg $value
	_orb_shift_args ${2:-1}
}

_orb_flag_value() {
	[[ ${1:0:1} == '-' ]] && echo true || echo false
}

# if specified with arg suffix, set value to next arg and shift both
_orb_assign_flagged_arg() {
	local arg=$1
	local suffix=${_orb_declared_arg_suffixes[$arg]}
	local value=("${args_remaining[@]:1:$suffix}")

	if _orb_is_valid_arg "$arg" "${value[@]}"; then
		_orb_assign_arg_value $arg "${value[@]}"
	else
		_orb_raise_invalid_arg "$arg" "${value[@]}"
	fi

	_orb_shift_args ${2:-$suffix}
}

_orb_assign_block() {
	local arg=$1
	local value=()
	_orb_shift_args # shift away first block

	local a; for a in "${args_remaining[@]}"; do
		if [[ "$a" == "$arg" ]]; then
			# end of block
			_orb_shift_args
			_orb_assign_arg_value $arg "${value[@]}"
			return 0
		else
			value+=("$a")
			_orb_shift_args
		fi 
	done

	orb_raise_error "'$arg' missing block end"
}

# TODO TODO CONTINUE
_orb_assign_inline_arg() {
	_args_nrs[$args_count - 1]="$1"
	_args[$args_count]="$1"
	(( args_count++ ))
	_orb_shift_args
}

_orb_assign_dash_wildcard() {
	_orb_shift_args
	[[ ${#args_remaining[@]} > 0 ]] && _args['-- *']=true
	_orb_dash_wildcard+=("${args_remaining[@]}")
	args_remaining=()
}

_orb_assign_rest() {
	_args['*']=true

	local _next_index=1
	local _arg; for _arg in ${args_remaining[@]}; do
		_orb_wildcard+=( "$_arg" )

		if [[ "${args_remaining[$_next_index]}" == '--' ]]; then
			_orb_shift_args $_next_index
			_orb_assign_dash_wildcard
			return 0
		fi

		_next_index=$((_next_index + 1))
	done

 	args_remaining=()
}

# shift one = remove first arg from arg array
_orb_shift_args() {
	local steps=${1-1}
	args_remaining=("${args_remaining[@]:${steps}}")
}
