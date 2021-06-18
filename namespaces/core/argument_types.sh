# _is_flag
declare -A _is_flagged_args=(
	['1']='arg; CATCH_ANY'
); function _is_flag() { # starts with - or + and has no spaces (+ falsifies if default val true)
	[[ $1 =~ ^[-+]{1}[-]{0,1}[a-zA-Z_][a-zA-Z_-]*$ ]] && [[ "${1: -1}" != "-" ]]
}

# _is_verbose_flag
# is also flag
declare -A _is_verbose_flag_args=(
	['1']='arg; CATCH_ANY'
); function _is_verbose_flag() { # starts with -- and has no spaces.
	[[ $1 =~ ^[-]{2}[a-zA-Z_][a-zA-Z_-]*$ ]] && [[ "${1: -1}" != "-" ]]
}

# _is_flagged_arg
# is not a flag
declare -A _is_flagged_arg_args=(
	['1']='arg'
); function _is_flagged_arg() { # starts with - and has substr ' arg'
	[[ "${1}" =~ ^[-]{1,2}[a-zA-Z_-]+[[:space:]]arg$ ]]
}

# _is_nr
declare -A _is_nr_args=(
	['1']='number input'
); function _is_nr() { # check if is nr
	[[ "$1" =~ ^[0-9]+$ ]]
}

# _is_block
# delineates where block starts/ends
declare -A _is_block_args=(
	['1']='arg; CATCH_ANY'
); function _is_block() { # flag that ends with -
	[[ $1 =~ ^[-]{1}[a-zA-Z_][a-zA-Z_]*-$ ]]
}

# _is_wildcard
declare -A _is_wildcard_args=(
	['1']='arg'
); function _is_wildcard() { # '*' or '-- *'
	[[ "$1" == '*' || "$1" == '-- *' ]]
}
