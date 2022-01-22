_orb_prevalidate_declaration() {
	if [[ ${_orb_declaration[0]} == '=' ]]; then 
		raise_invalid_declaration 'Cannot start with ='
	fi
}

_orb_raise_invalid_declaration() {
	orb_raise_error "Invalid declaration. $@" 
}




# _orb_parse_declared_arg

# _orb_parse_declaration_arg_options() {
# 	local options_i=$1 len=$2

# 	[[ $options_i > $len ]] && return

# 	local opt="${_orb_declaration[$options_i]}"
# 	local current_arg_index=$(( ${#_orb_declared_args[@]} - 1 ))
	
# 	while _orb_is_valid_arg_option $opt; do
# 		# TODO figure out how to store function => argument => property => value
# 	done

# }

# $1 arg, $2 optional name of declaration array, default: _orb_declared_args
# returns index of arg in declaration
# -f matches for "-f arg"
# returns -1 if arg not found
_orb_index_of_declared() { 

	# for service in ${!_orb_declared_args@}; do
	# 	echo "$service"
	# done

	# eval "arr=(\"\${${2-_orb_declared_args}[@]}\")"
	local arr=${2-_orb_declared_args}[@]

	local i=0
	local arg; for arg in "${!arr}"; do
		if [[ "$arg" == "$1" ]] || [[ ${arg%% *} == "$1" ]]; then
			echo "$i"
			return 0;
		fi
		(( i++ ))
	done;

	echo "-1"
	return 1
}

_orb_caller_index_of_declared() { # $1 arg
	_orb_index_of_declared "$1" _orb_caller_args_declared
}

_orb_raise_undeclared() {
	orb_raise_error "'$1' not in $_orb_caller_function_descriptor args declaration\n\n$(_orborb_print_args_explanation _orb_caller_args_declaration)"
}

# _orb_declared_flag() { # $1 arg $2 optional args_declaration
# 	declare -n _declaration=${2-"_orb_declaration"}
# 	[[ -n ${_declaration["${1/+/-}"]} ]]
# }

# _orb_declared_flagged_arg() { # $1 arg $2 optional args_declaration
# 	declare -n _declaration=${2-"_orb_declaration"}
# 	[[ -n ${_declaration["$1 arg"]} ]]
# }

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
