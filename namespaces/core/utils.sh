declare -A _function_declared_args=(
	['1']='function_name'
); function _function_declared() { # check if function has been declared
	declare -f -F $1 > /dev/null
	return $?
}

# _grep_between
declare -A _grep_between_args=(
	['1']='string to grep'
	['2']='grep between from'
	['3']='grep between to'
); function _grep_between() { # grep between two strings, can use (either|or)
	grep -oP "(?<=$2).*?(?=$3)" <<< $1
}

# _join_by
declare -A _join_by_args=(
	['1']='delimiter'
	['*']='to join'
); function _join_by() { # join array by separator
	local _d=$1; shift; local _f=$1; shift; printf %s "$_f" "${@/#/$_d}";
}

# _eval_variable_or_string
declare -A _eval_variable_or_string_args=(
	['1']='$variable/string'
); function _eval_variable_or_string() { # if str starts with $ it is evaluated otherwise string returned
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

# _eval_variable_or_string_options
declare -A _eval_variable_or_string_options_args=(
	['1']='$option1|$option2|fallback_str'
); function _eval_variable_or_string_options() { # return first opt that eval. if opts end with | last fallback is empty string
	local _options
	IFS='|' read -r -a _options <<< $1 # split by |

	local _option; for _option in "${_options[@]}"; do
		local _val;
		if _val=$(_eval_variable_or_string "$_option"); then
			echo "$_val"
			return 0
		fi
	done

	return 1
}

declare -A _is_empty_arr_args=(
	['1']='arr_name'
); function _is_empty_arr() {
	[[ ! -v "$1[@]" ]]
}

