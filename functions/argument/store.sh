# Store argument values in single values array
# With each argument specifying start index and length
_orb_store_arg_value() {
	local _orb_arg=$1 && shift

	if _orb_has_arg_value $_orb_arg && _orb_arg_option_value_is $_orb_arg Multiple: true; then
		_orb_args_values_start_indexes[$_orb_arg]+=" ${#_orb_args_values[@]}"
		_orb_args_values_lengths[$_orb_arg]+=" $#"
	else
		_orb_args_values_start_indexes[$_orb_arg]=${#_orb_args_values[@]}
		_orb_args_values_lengths[$_orb_arg]="$#"
	fi
	 
	_orb_args_values+=("$@")
}

_orb_store_boolean_flag() {
	local _orb_arg="${1/+/-}"
	local _orb_shift=${2-1}
	local _orb_value=$(_orb_flag_value "$1")
	_orb_store_arg_value $_orb_arg $_orb_value
	_orb_shift_args $_orb_shift
}

_orb_flag_value() {
	[[ ${1:0:1} == '-' ]] && echo true || echo false
}

_orb_store_flagged_arg() {
	local _orb_arg=$1
	local _orb_suffix=${_orb_declared_arg_suffixes[$_orb_arg]}
	local _orb_shift=${2-$(($_orb_suffix + 1))}
	local _orb_value=("${args_remaining[@]:1:$_orb_suffix}")

	if _orb_is_valid_arg "$_orb_arg" "${_orb_value[@]}"; then
		_orb_store_arg_value $_orb_arg "${_orb_value[@]}"
	else
		_orb_raise_invalid_arg "$_orb_arg" "${_orb_value[@]}"
	fi

	_orb_shift_args $_orb_shift
}

_orb_store_block() {
	local _orb_arg=$1
	local _orb_value=()
	_orb_shift_args # shift away first block

	local _orb_a; for _orb_a in "${args_remaining[@]}"; do
		if [[ "$_orb_a" == "$_orb_arg" ]]; then
			# end of block
			_orb_shift_args
			_orb_store_arg_value $_orb_arg "${_orb_value[@]}"
			return 0
		else
			_orb_value+=("$_orb_a")
			_orb_shift_args
		fi 
	done

	_orb_raise_error "'$_orb_arg' missing block end"
}

_orb_store_inline_arg() {
	_orb_store_arg_value $args_count "$1"
	(( args_count++ ))
	_orb_shift_args
}

_orb_store_dash() {
	_orb_store_arg_value "${args_remaining[@]}"
	args_remaining=()
}

_orb_store_rest() {
	# variables have to be prefixed not to collide with assignment
	local _orb_next_i=1
	local _orb_rest=()

	local _orb_arg; for _orb_arg in "${args_remaining[@]}"; do
		_orb_rest+=("$_orb_arg")

		if [[ "${args_remaining[$_orb_next_i]}" == '--' ]]; then
			_orb_shift_args $_orb_next_i
			_orb_store_dash
			break
		fi

		((_orb_next_i++))
	done

	_orb_store_arg_value '...' "${_orb_rest[@]}"
 	args_remaining=()
}
