# _is_boolean_flag
declare -A _is_boolean_flag_args=(
	['1']='arg; CAN_START_WITH_FLAG'
); function _is_boolean_flag() { # starts with - or + and has no spaces
	[[ ${1:0:1} == '-' ]] || [[ ${1:0:1} == '+' ]] && [[ "${1/ /}" == "$1" ]]
}

# _is_flag_with_arg
declare -A _is_flag_with_arg_args=(
	['1']='arg; CAN_START_WITH_FLAG'
); function _is_flag_with_arg() { # starts with - and has substr ' arg'
	[[ ${1:0:1} == '-' ]] && [[ "${1/ arg/}" !=  "$1" ]]
}

# _is_flagged_arg
declare -A _is_flagged_arg_args=(
	['1']='arg; CAN_START_WITH_FLAG'
); function _is_flagged_arg() {
	_is_boolean_flag "$1" || _is_flag_with_arg "$1"
}

# _isnr
declare -A _isnr_args=(
	['1']='number input'
); function _isnr() { # check if is nr
	[[ "$1" =~ ^[0-9]+$ ]]
}

declare -A _function_exists_args=(
	['1']='function_name'
); function _function_exists() {
	declare -f -F $1 > /dev/null
	return $?
}

# parsenv
declare -A _parseenv_args=(
	['1']='path to .env'
); function _parseenv() { # export variables in .env to shell
	echo "eval $(egrep -v '^#' $1 | sed -e 's/ = /=/g' | xargs -0)"
}

# _grepbetween
declare -A _grepbetween_args=(
	['1']='string to grep'
	['2']='grep between from'
	['3']='grep between to'
); function _grepbetween() { # grep between two strings, can use (either|or)
	echo "$(grep -oP "(?<=$2).*?(?=$3)" <<< $1)"
}

# _upfind
declare -A _upfind_args=(
	['1']='filename to _upfind'
); function _upfind() { # Find closest filename upwards in filsystem
	x=`pwd`
	while [ "$x" != "/" ] ; do
			if [[ -e "$x/$1" ]]; then
				echo "$x/$1"
				break;
				exit 0;
			fi
			x=`dirname "$x"`
	done

	exit 1;
}

# _eval_variable_or_string
declare -A _eval_variable_or_string_args=(
	['1']='$variable/string'
); function _eval_variable_or_string() { # $1 $variable/string (in string format)
	str="$1"
	if [[ ${str:0:1} == '$' ]]; then # is variable
		str="${str:1}" # rm $
		echo "${!str}" # eval var name
	else # is static value
		echo "$str" # set it and break
	fi
}

# _join_by
declare -A _join_by_args=(
	['1']='delimiter'
	['*']='to join'
); function _join_by() { # join array by separator
	local d=$1; shift; local f=$1; shift; printf %s "$f" "${@/#/$d}";
}

# _echoerr
declare -A _echoerr_args=(
  ['*']='msg; CAN_START_WITH_FLAG'
); function _echoerr() { # echo to stderr, useful for debugging functions that return values in stdout
  echo "$@" >&2
}
