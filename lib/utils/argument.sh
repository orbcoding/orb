# orb_is_flag
declare -A orb_is_flag_args=(
	['1']='arg; CATCH_ANY'
); function orb_is_flag() { # starts with single - or + and has no spaces (+ falsifies if default val true)
	[[ $1 =~ ^[-+]{1}[a-zA-ZwW]+$ ]]
}

# orb_is_verbose_flag
declare -A orb_is_verbose_flag_args=(
	['1']='arg; CATCH_ANY'
); function orb_is_verbose_flag() { # starts with -- and has no spaces.
	[[ $1 =~ ^[+-]{1}[-]{1}[a-zA-ZwW0-9_][a-zA-ZwW0-9_-]*$ ]] && [[ "${1: -1}" != "-" ]]
}

declare -A orb_is_any_flag_args=(
	['1']='arg; CATCH_ANY'
); function orb_is_any_flag() { # starts with single - or + and has no spaces (+ falsifies if default val true)
	orb_is_flag "$1" || orb_is_verbose_flag "$1"
}

# orb_is_nr
declare -A orb_is_nr_args=(
	['1']='number input'
); function orb_is_nr() { # check if is nr
	[[ "$1" =~ ^[0-9]+$ ]]
}

# orb_is_flag_with_nr
declare -A orb_is_flag_with_nr_args=(
	['1']='arg'
); function orb_is_flag_with_nr() { # starts with - and has substr ' arg'
	local arg=( $1 )
	local flag="${arg[0]}"
	[[ "${flag:0:1}" == - ]] && orb_is_any_flag "${arg[0]}" && orb_is_nr "${arg[1]}"
}

# orb_is_block
declare -A orb_is_block_args=(
	['1']='arg; CATCH_ANY'
); function orb_is_block() { # like a flag that ends with -
	[[ $1 =~ ^[-]{1}[a-zA-ZwW0-9_-][a-zA-ZwW0-9_-]*-$ ]]
}

# orb_is_rest
declare -A orb_is_rest_args=(
	['1']='arg'
); function orb_is_rest() { # '*' or '-- *'
	[[ "$1" == "..." ]]
}

# orb_is_dash
declare -A orb_is_dash_args=(
	['1']='arg'
); function orb_is_dash() { # '*' or '-- *'
	[[ "$1" == -- ]]
}

function orb_is_input_arg() {
	orb_is_nr $1 || orb_is_any_flag $1 || orb_is_block $1 || orb_is_rest $1 || orb_is_dash $1
}

function orb_is_valid_variable_name() {
	[[ "$1" =~ ^[a-zA-ZwW][a-zA-Z0-9_wW]*$ ]]
}
