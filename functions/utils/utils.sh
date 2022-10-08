# orb_function_declared
orb_function_declared_orb=(
	"Check if a function name has been declared"
	DirectCall: true

	1 = function_name "Function name"
); function orb_function_declared() {
	declare -f -F $1 > /dev/null
	return $?
}

# orb_grep_between
orb_grep_between=(
	1 = 'string to grep'
	2 = 'grep between from'
	3 = 'grep between to'
); function orb_grep_between() { # grep between two strings, can use (either|or)
	grep -oP "(?<=$2).*?(?=$3)" <<< $1
}

# orb_join_by
declare -A orb_join_by_args=(
	['1']='delimiter'
	['*']='to join'
); function orb_join_by() { # join array by separator
	local _d=$1; shift; local _f=$1; shift; printf %s "$_f" "${@/#/$_d}";
}

# orb_eval_variable_or_string
declare -A orb_eval_variable_or_string_args=(
	['1']='$variable/string'
); function orb_eval_variable_or_string() { # if str starts with $ it is evaluated otherwise string returned
	if [[ ${1:0:1} == '$' ]]; then # is variable
		local _val="$(eval echo "$1")"
		# echo if var not null
		if [[ -n ${_val} ]]; then
			echo "${_val}"
		else
			return 1
		fi
	elif [[ -n ${1+x} ]]; then
		# echo if not null static value
		echo "$1"
	else
		return 1
	fi
}

# orb_eval_variable_or_string_options
declare -A orb_eval_variable_or_string_options_args=(
	['1']='$option1|$option2|fallback_str'
); function orb_eval_variable_or_string_options() { # return first opt that eval. if opts end with | last fallback is empty string
	local _options
	IFS='|' read -r -a _options <<< $1 # split by |

	local _option; for _option in "${_options[@]}"; do
		local _val;
		if _val=$(orb_eval_variable_or_string "$_option"); then
			echo "$_val"
			return 0
		fi
	done

	return 1
}

# TODO verify empty or unset?
declare -A orb_is_empty_arr_args=(
	['1']='arr_name'
); function orb_is_empty_arr() {
	[[ ! -v "$1[@]" ]]
}


declare -A orb_remove_prefix_args=(
	['1']='prefix to remove'
	['2']='string to remove from'
); function orb_remove_prefix() {
	if [[ ${2:0:${#1}} == $1 ]]; then # is variable
		echo ${2:${#1}}
	else
		echo $2
		return 1
	fi
}


function orb_index_of() {
	local _orb_arr_value="$1"
	declare -n _orb_arr_ref="$2"

	local _orb_i; for _orb_i in "${!_orb_arr_ref[@]}"; do
		if [[ "${_orb_arr_ref[$_orb_i]}" == "$_orb_arr_value" ]]; then
			echo "$_orb_i" && return
		fi
	done

	echo "-1"
	return 1
}

function orb_in_arr() {
	local _orb_arr_value="$1"
	local _orb_arr_name="$2"

	orb_index_of "$_orb_arr_value" "$_orb_arr_name" > /dev/null
}


# To be evaled
_orb_rename_variable() {
	local _orb_var=$1
	local _orb_name=$2
	local _orb_unset=${3-true}
	local _orb_global=${4-false}

	local _orb_declare_statement; _orb_declare_statement=($(declare -p "$_orb_var" 2>/dev/null)) || return 1
	local _orb_opening=(${_orb_declare_statement[@]:0:2}) # declare -a
	$_orb_global && _orb_opening=(${_orb_opening[0]} -g ${_orb_opening[1]})
	local _orb_assignment=${_orb_declare_statement[@]:2} # var=....
	_orb_assignment="${_orb_name}${_orb_assignment/$_orb_var/}" # name=...

	local to_eval="${_orb_opening[@]} ${_orb_assignment[@]}" 
	$_orb_unset && to_eval+="; unset $_orb_var"

	echo "${to_eval[@]}"
}
