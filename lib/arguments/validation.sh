_orb_is_valid_arg() { # $1 arg_key, $2 arg
	_orb_is_valid_in "$1" "$@"
}

_orb_is_valid_in() {
	local arg=$1
	local val="$@"
	
	[[ -z ${_orb_declared_ins_start_indexes[$arg]} ]] && return 0
	local in_arr="${_orb_declared_ins[@]:${_orb_declared_ins_start_indexes[$arg]}:${_orb_declared_ins_lengths[$arg]}}"

	[[ " ${in_arr[@]} " =~ " $val " ]]
}

_orb_raise_invalid_arg() { # $1 arg_key $2 arg_value/required
	local arg
	[[ ${1:0:1} == '-' ]] && ! orb_is_block "$1" && arg='flags' || arg='args'
	local msg="invalid $arg: $1"
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

	msg+="\n\n$(_orb_print_args_explanation)"

	orb_raise_error "$msg"
}


# _orb_args_post_validation() {
# 	local _arg; for _arg in "${!_orb_function_declaration[@]}"; do
# 		_orb_validate_declaration "$_arg"
# 		_orb_validate_required "$_arg"
# 		_orb_validate_empty "$_arg"
# 	done
# }

# _orb_validate_declaration() {
# 	orb_is_flag "$1" || \
# 	orb_is_flag_with_nr "$1" || \
# 	orb_is_nr "$1" || \
# 	orb_is_block "$1" || \
# 	_is_wildcard "$1" || \
# 	_orb_raise_invalid_arg "$1 invalid declaration"
# }

# _orb_validate_required() { # $1 arg, $2 optional args_declaration
# 	if ( \
# 		[[ "$1" == '*' && ${_args['*']} == false ]] || \
# 		[[ "$1" == '-- *' && ${_args['-- *']} == false ]] || \
# 		(! _is_wildcard "$1" && [[ -z ${_args["$1"]+x} ]]) \
# 	) \
# 	&& _orb_is_required "$1" $2; then
# 		_orb_raise_invalid_arg "$1 is required"
# 	fi
# }

# _orb_validate_empty() { # $1 arg_key
# 	if [[ -z "${_args["$1"]}" && -n ${_args["$1"]+x} ]]; then
# 		# is empty str
# 		if ! _orb_catches_empty "$1"; then
# 			_orb_raise_invalid_arg "$_arg with value \"\", add CATCH_ANY to allow empty string"
# 		fi
# 	fi
# }

# _orb_is_required() { # $1 arg, $2 optional args_declaration
# 	( orb_is_flag_with_nr "$1" && _orb_get_arg_prop "$1" 'REQUIRED' $2) || \
# 	( orb_is_block "$1" && _orb_get_arg_prop "$1" 'REQUIRED' $2) || \
# 	( (! orb_is_flag "$1" && ! orb_is_flag_with_nr "$1" && ! orb_is_block "$1" ) && ! _orb_get_arg_prop "$1" 'OPTIONAL' $2)
# }

