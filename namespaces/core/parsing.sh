declare -A _function_declared_args=(
	['1']='function_name'
); function _function_declared() { # check if function has been declared
	declare -f -F $1 > /dev/null
	return $?
}

# has_public_function $1 function, $2 file
declare -A _has_public_function_args=(
	['1']='function_name'
	['2']='file'
); function _has_public_function() { # check if file has function
	grep -q "^[); ]*function[ ]*$1[ ]*()[ ]*{" "$2"
}

# parsenv
declare -A _parse_env_args=(
	['1']='path to .env'
); function _parse_env() { # export variables in .env to shell
	set -o allexport; source "$1"; set +o allexport
}

# _grep_between
declare -A _grep_between_args=(
	['1']='string to grep'
	['2']='grep between from'
	['3']='grep between to'
); function _grep_between() { # grep between two strings, can use (either|or)
	grep -oP "(?<=$2).*?(?=$3)" <<< $1
}

# _upfind_closest
declare -A _upfind_closest_args=(
	['1']='filename to _upfind_closest'
	['2']='starting path; DEFAULT: $PWD'
); function _upfind_closest() { # Find closest filename upwards in filsystem
	local _p="${2-$PWD}" _sep _options

	[[ ${_p[1]} != '/' ]] && _p="$(pwd)/$_p"

	while [ "$_p" != "/" ] ; do
			if [[ -e "$_p/$1" ]]; then
				echo "$_p/$1"
				return 0;
			fi
			_p=`dirname "$_p"`
	done

	return 1;
}

# _upfind_to_arr
declare -A _upfind_to_arr=(
	['1']='array name'
	['2']='filename(s) multiple files sep with & (and) or | (or)'
	['3']='starting path; DEFAULT: $PWD'
); function _upfind_to_arr() { # finds all files with filename(s) upwards in file system
	local _p="${3-$PWD}"

	[[ ${_p[1]} != '/' ]] && _p="$(pwd)/$_p"

	declare -n _arr=$1
	[[ -n "$2" ]] && _path="$2"

	local _sep='&'; [[ $2 == *"|"* ]] && _sep='|'

	local _options; IFS="$_sep" read -r -a _options <<< $2 # split by sep
	local _option

	while [ "$_p" != "/" ] ; do
		local _found=false

		for _option in "${_options[@]}"; do
			if [[ -e "$_p/$_option" ]]; then
				[[ $_sep == '|' ]] && $_found && break
				_arr+=( "$_p/$_option" )
			fi
		done

		_p=$(dirname "$_p")
	done
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

declare -A _got_orb_prefix_args=(
	['1']='FUNCNAME offset, eg, if check if parent got orb prefix, set 1; DEFAULT: 0'
); function _got_orb_prefix() {
	local _offset
  local _caller=${FUNCNAME[$((${1-0} + 1))]}
  local _condition=$_function_name

  if [[ $_caller == 'orb' ]]; then
    _caller=${FUNCNAME[$((${1-0} + 2))]}
    _condition=$_caller_function_name
  fi

  [[ "$_caller" == "$_condition" ]]
}

