_orb_catches_any() { # $1 arg, $2 optional args_declaration
	_orb_get_arg_prop "$1" "CATCH_ANY" $2
}

_orb_catches_empty() {
	_orb_get_arg_prop "$1" "CATCH_EMPTY" $2
}


_orb_arg_default_prop() { # $1 arg, $2 optional args_declaration
	_orb_get_arg_prop "$_arg" DEFAULT $2
}

_orb_get_arg_prop() { # $1 arg_key, $2 sub_property, $3 optional args_declaration_variable
	declare -n _declaration=${3-"_orb_args_declaration"}
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
