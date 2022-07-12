_orb_prevalidate_declaration() {
	if [[ ${_orb_declaration[0]} == '=' ]]; then 
		raise_invalid_declaration 'Cannot start with ='
	fi
}

_orb_raise_invalid_declaration() {
	orb_raise_error "Invalid declaration. $@" 
}

_orb_raise_undeclared() {
	orb_raise_error "'$1' not in $_orb_caller_function_descriptor args declaration\n\n$(_orborb_print_args_explanation _orb_caller_args_declaration)"
}

_orb_is_declared_boolean_flag() { # $1 arg $2 optional history index
	local arg=$1
	orb_is_any_flag $arg || return 1
	declare -n suffixes="_orb_declared_suffixes$(_orb_history_suffix $2)"
	local args_i=$(_orb_get_args_index $arg $2)
	[[ -z ${suffixes[$args_i]} ]]
}

_orb_is_declared_flagged_arg() { # $1 arg $2 optional history index
	local arg=$1
	orb_is_any_flag $arg || return 1
	declare -n suffixes="_orb_declared_suffixes$(_orb_history_suffix $2)"
	local args_i=$(_orb_get_args_index $arg $2)
	orb_is_nr ${suffixes[$args_i]}
}

# _orb_declared_inline_arg() { # $1 nr
# 	declare -n _declaration=${2-"_orb_declaration"}
# 	[[ -n ${_declaration["$1"]} ]]
# }

# _orb_declared_wildcard() {
# 	declare -n _declaration=${1-"_orb_declaration"}
# 	[[ -n ${_declaration['*']} ]]
# }

# _orb_declared_dash_wildcard() {
# 	declare -n _declaration=${1-"_orb_declaration"}
# 	[[ -n ${_declaration['-- *']} ]]
# }

# _orb_declared_block() {
# 	declare -n _declaration=${2-"_orb_declaration"}
# 	[[ -n ${_declaration["$1"]} ]]
# }

# _orb_declared_blocks() {
# 	declare -n _declaration=${1-"_orb_declaration"}
# 	local _orb_blocks=()

# 	local _key; for _key in "${!_declaration[@]}"; do
# 		orb_is_block "$_key" && _orb_blocks+=("$_key")
#   done

# 	echo "${_orb_blocks[@]}"
# }

# _orb_block_to_arr_name() {
# 	echo "_args_block_${1:1: -1}"
# }
