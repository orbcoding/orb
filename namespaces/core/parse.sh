# _is_flag
declare -A _is_flag_args=(
	['1']='arg; ACCEPTS_FLAGS'
); function _is_flag() { # starts with - or + and has no spaces (+ falsifies if default val true)
	[[ $1 =~ [-+]{1}[-]{0,1}[a-zA-Z_][a-zA-Z_-]*$ ]]
}

# _is_verbose_flag
declare -A _is_verbose_flag_args=(
	['1']='arg; ACCEPTS_FLAGS'
); function _is_verbose_flag() { # starts with -- and has no spaces.
	[[ $1 =~ [-]{2}[a-zA-Z_][a-zA-Z_-]*$ ]]
}

declare -A _is_wildcard_args=(
	['1']='arg'
); function _is_wildcard() { # '*' or '-- *'
	[[ "$1" == '*' || "$1" == '-- *' ]]
}

# _is_nr
declare -A _is_nr_args=(
	['1']='number input'
); function _is_nr() { # check if is nr
	[[ "$1" =~ ^[0-9]+$ ]]
}

declare -A _function_exists_args=(
	['1']='function_name'
); function _function_exists() { # check if function has been declared
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

# _find_closest
declare -A _find_closest_args=(
	['1']='filename to _find_closest'
	['2']='starting path; DEFAULT: $PWD'
); function _find_closest() { # Find closest filename upwards in filsystem
	local x="$PWD"
	[[ -n "$2" ]] && x="$2"


	# _echoerr "x=$x"
	# _echoerr "1=$1"
	# _echoerr "2=$2"
	while [ "$x" != "/" ] ; do
			if [[ -e "$x/$1" ]]; then
				echo "$x/$1"
				return 0;
			fi
			x=`dirname "$x"`
	done

	return 1;
}

# _join_by
declare -A _join_by_args=(
	['1']='delimiter'
	['*']='to join'
); function _join_by() { # join array by separator
	local d=$1; shift; local f=$1; shift; printf %s "$f" "${@/#/$d}";
}

# _eval_variable_or_string
declare -A _eval_variable_or_string_args=(
	['1']='$variable/string'
); function _eval_variable_or_string() { # if str starts with $ it is evaluated otherwise string returned
	if [[ ${1:0:1} == '$' ]]; then # is variable
		local var=${1:1} # rm $
		# echo if var not null
		if [[ -n ${!var+x} ]]; then
			echo "${!var}"
		else
			return 1
		fi
	elif [[ "$1" == '""' ]]; then
		echo "" # "" reserved for empty string string
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

function _got_orb_prefix() {
  local _caller=${FUNCNAME[1]}
  local _condition=$_function_name

  if [[ $_caller == 'orb' ]]; then
    _caller=${FUNCNAME[2]}
    _condition=$_caller_function_name
  fi

  [[ "$_caller" == "$_condition" ]]
}

