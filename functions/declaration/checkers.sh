declare -a _orb_available_arg_options=( Required: Default: In: Catch: Multiple: DefaultEval: )

declare -a _orb_available_arg_options_number_arg=( Required: Default: DefaultEval: In: )
declare -a _orb_available_arg_options_boolean_flag=( Required: Default: DefaultEval: )
declare -a _orb_available_arg_options_flag_arg=( Required: Default: DefaultEval: Multiple: In: )
# flag args with suffix > 1 
declare -a _orb_available_arg_options_array_flag_arg=( Required: Default: DefaultEval: Multiple: )
declare -a _orb_available_arg_options_block=( Required: Default: DefaultEval: Multiple: )
declare -a _orb_available_arg_options_dash=( Required: Default: DefaultEval: )
declare -a _orb_available_arg_options_rest=( Required: Default: DefaultEval: Catch: )

declare -a _orb_available_arg_option_catch_values=( any flag block dash )
declare -a _orb_available_arg_option_required_values=( true false )
declare -a _orb_available_arg_option_multiple_values=( true false )

_orb_is_available_option() {
	[[ " ${_orb_available_arg_options[@]} " =~ " $1 " ]]
}

_orb_is_available_number_arg_option() {
	[[ " ${_orb_available_arg_options_number_arg[@]} " =~ " $1 " ]]
}

_orb_is_available_boolean_flag_option() {
	[[ " ${_orb_available_arg_options_boolean_flag[@]} " =~ " $1 " ]]
}

_orb_is_available_flag_arg_option() {
	[[ " ${_orb_available_arg_options_flag_arg[@]} " =~ " $1 " ]]
}

_orb_is_available_array_flag_arg_option() {
	[[ " ${_orb_available_arg_options_array_flag_arg[@]} " =~ " $1 " ]]
}

_orb_is_available_block_option() {
	[[ " ${_orb_available_arg_options_block[@]} " =~ " $1 " ]]
}

_orb_is_available_dash_option() {
	[[ " ${_orb_available_arg_options_dash[@]} " =~ " $1 " ]]
}

_orb_is_available_rest_option() {
	[[ " ${_orb_available_arg_options_rest[@]} " =~ " $1 " ]]
}

_orb_is_available_catch_option_value() {
	[[ " ${_orb_available_arg_option_catch_values[@]} " =~ " $1 " ]]
}

_orb_is_available_required_option_value() {
	[[ " ${_orb_available_arg_option_required_values[@]} " =~ " $1 " ]]
}

_orb_is_available_multiple_option_value() {
	[[ " ${_orb_available_arg_option_multiple_values[@]} " =~ " $1 " ]]
}


# Declaration checkers
#
_orb_has_declared_arg() {
  local arg=${1/+/-}
	declare -n declared_args="_orb_declared_args$_orb_variable_suffix"
	[[ " ${declared_args[@]} " =~ " $arg " ]]
}

_orb_has_declared_boolean_flag() { # $1 arg
	local arg=$1
	! (_orb_has_declared_arg $arg && orb_is_any_flag $arg) && return 1
	declare -n suffixes="_orb_declared_arg_suffixes$_orb_variable_suffix"
  [[ -z ${suffixes[$arg]} ]]
}

_orb_has_declared_flagged_arg() { # $1 arg
	local arg=$1
	! _orb_has_declared_arg $arg && return 1
	
	declare -n suffixes="_orb_declared_arg_suffixes$_orb_variable_suffix"
	[[ -n ${suffixes[$arg]} ]]
}

_orb_has_declared_array_flag_arg() {
	local arg=$1
	local suffix=${_orb_declared_arg_suffixes[$arg]}
	if orb_is_any_flag $arg && [[ -n $suffix ]] && (( $suffix > 1 )); then 
		return 0
	fi

	return 1
}

_orb_has_declared_array_arg() {
	local arg=$1

	if ! (_orb_has_declared_array_flag_arg $arg || _orb_arg_is_multiple $arg || \
		orb_is_dash $arg || orb_is_rest $arg || orb_is_block $arg); then
		return 1
	fi
}

_orb_has_declared_arg_default() {
	local _orb_arg=$1
  [[ -n ${_orb_declared_defaults_start_indexes[$_orb_arg]} ]]
}

_orb_has_declared_arg_default_eval() {
	local _orb_arg=$1
  [[ -n ${_orb_declared_default_evals[$_orb_arg]} ]]
}

_orb_arg_is_required() {
	local arg=$1
  [[ ${_orb_declared_requireds[$arg]} == true ]]
}

_orb_arg_is_multiple() {
	local arg=$1
  [[ ${_orb_declared_multiples[$arg]} == true ]]
}

_orb_arg_catches() { # $1 arg
	local arg=$1
	local value=$2
	local arg_catch; _orb_get_arg_catch_arr $arg arg_catch

	[[ " ${arg_catch[@]} " =~ " any " ]] && return

	if orb_is_flag $value; then
		! [[ " ${arg_catch[@]} " =~ " flag " ]] && return 1
	elif orb_is_block $value; then
		! [[ " ${arg_catch[@]} " =~ " block " ]] && return 1
	elif orb_is_dash $value; then
		! [[ " ${arg_catch[@]} " =~ " dash " ]] && return 1
	fi
	
	return 0
}
