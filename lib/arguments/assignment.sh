_orb_flag_value() {
	[[ ${1:0:1} == '-' ]] && echo true || echo false
}

_orb_assign_flag() {
	_args["${1/+/-}"]=$(_orb_flag_value "$1")
	_orb_shift_args ${2:-1}
}

# if specified with arg suffix, set value to next arg and shift both
_orb_assign_flagged_arg() {
	if _orb_is_valid_arg "$1 arg" "${_args_remaining[1]}"; then
		_args["$1 arg"]="${_args_remaining[1]}"
	else
		_orb_raise_invalid_arg "$1 arg" "${_args_remaining[1]}"
	fi

	_orb_shift_args ${2:-2}
}

_orb_assign_orb_block() {
	_orb_shift_args
	[[ ${#_args_remaining[@]} > 0 ]] && \
	[[ ${_args_remaining[0]} != "$1" ]] && \
	_args["$1"]=true
	local _arr_name="$(_orb_block_to_arr_name "$1")"
	declare -n _arr_ref="$_arr_name"
	local _arg; for _arg in "${_args_remaining[@]}"; do
		if [[ "$_arg" == "$1" ]]; then
			# end of block
			_orb_shift_args
			return
		else
			_arr_ref+=("$_arg")
			_orb_shift_args
		fi 
	done

	_raise_error "'$1' missing block end"
}

_orb_assign_inline_arg() {
	_args_nrs[$_args_nrs_count - 1]="$1"
	_args[$_args_nrs_count]="$1"
	(( _args_nrs_count++ ))
	_orb_shift_args
}

_orb_assign_dash_wildcard() {
	_orb_shift_args
	[[ ${#_args_remaining[@]} > 0 ]] && _args['-- *']=true
	_orb_dash_wildcard+=("${_args_remaining[@]}")
	_args_remaining=()
}

_orb_assign_wildcard() {
	_args['*']=true

	local _next_index=1
	local _arg; for _arg in ${_args_remaining[@]}; do
		_orb_wildcard+=( "$_arg" )

		if [[ "${_args_remaining[$_next_index]}" == '--' ]]; then
			_orb_shift_args $_next_index
			_orb_assign_dash_wildcard
			return 0
		fi

		_next_index=$((_next_index + 1))
	done

 	_args_remaining=()
}

# shift one = remove first arg from arg array
_orb_shift_args() {
	local _steps=${1-1} # 1 default value
	local _i; for (( _i = 0; _i < $_steps; _i++ )); do
		_args_remaining=("${_args_remaining[@]:1}")
	done
}
