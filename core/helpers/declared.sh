_declared_flag() { # $1 arg $2 optional args_declaration
	declare -n _declaration=${2-"_args_declaration"}
	[[ -n ${_declaration["${1/+/-}"]} ]]
}

_declared_flagged_arg() { # $1 arg $2 optional args_declaration
	declare -n _declaration=${2-"_args_declaration"}
	[[ -n ${_declaration["$1 arg"]} ]]
}

_declared_inline_arg() { # $1 nr
	declare -n _declaration=${2-"_args_declaration"}
	[[ -n ${_declaration["$1"]} ]]
}

_declared_wildcard() {
	declare -n _declaration=${1-"_args_declaration"}
	[[ -n ${_declaration['*']} ]]
}

_declared_dash_wildcard() {
	declare -n _declaration=${1-"_args_declaration"}
	[[ -n ${_declaration['-- *']} ]]
}

_declared_block() {
	declare -n _declaration=${2-"_args_declaration"}
	[[ -n ${_declaration["$1"]} ]]
}

_declared_blocks() {
	declare -n _declaration=${1-"_args_declaration"}
	local _blocks=()

	local _key; for _key in "${!_declaration[@]}"; do
		_is_block "$_key" && _blocks+=("$_key")
    # _caller_ref["$_key"]=${_arr_ref["$_key"]}
  done

	echo "${_blocks[@]}"
}

_block_to_arr_name() {
	echo "_args_block_${1:1: -1}"
}

_raise_undeclared() {
	_raise_error "'$1' not in $_caller_function_descriptor args declaration\n\n$(__print_args_explanation _caller_args_declaration)"
}
