_orb_declared_flag() { # $1 arg $2 optional args_declaration
	declare -n _declaration=${2-"_orb_args_declaration"}
	[[ -n ${_declaration["${1/+/-}"]} ]]
}

_orb_declared_flagged_arg() { # $1 arg $2 optional args_declaration
	declare -n _declaration=${2-"_orb_args_declaration"}
	[[ -n ${_declaration["$1 arg"]} ]]
}

_orb_declared_inline_arg() { # $1 nr
	declare -n _declaration=${2-"_orb_args_declaration"}
	[[ -n ${_declaration["$1"]} ]]
}

_orb_declared_wildcard() {
	declare -n _declaration=${1-"_orb_args_declaration"}
	[[ -n ${_declaration['*']} ]]
}

_orb_declared_dash_wildcard() {
	declare -n _declaration=${1-"_orb_args_declaration"}
	[[ -n ${_declaration['-- *']} ]]
}

_orb_declared_block() {
	declare -n _declaration=${2-"_orb_args_declaration"}
	[[ -n ${_declaration["$1"]} ]]
}

_orb_declared_blocks() {
	declare -n _declaration=${1-"_orb_args_declaration"}
	local _orb_blocks=()

	local _key; for _key in "${!_declaration[@]}"; do
		_is_block "$_key" && _orb_blocks+=("$_key")
  done

	echo "${_orb_blocks[@]}"
}

_orb_block_to_arr_name() {
	echo "_args_block_${1:1: -1}"
}

_orb_raise_undeclared() {
	_raise_error "'$1' not in $_orb_caller_function_descriptor args declaration\n\n$(_orb_print_args_explanation _orb_caller_args_declaration)"
}
