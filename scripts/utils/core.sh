# is_boolean_flag
declare -A is_boolean_flag_args=(
	['1']='arg; CAN_START_WITH_FLAG'
); function is_boolean_flag() { # starts with - or + and has no spaces
	[[ ${1:0:1} == '-' ]] || [[ ${1:0:1} == '+' ]] && [[ "${1/ /}" == "$1" ]]
}

# is_flag_with_arg
declare -A is_flag_with_arg_args=(
	['1']='arg; CAN_START_WITH_FLAG'
); function is_flag_with_arg() { # starts with - and has substr ' arg'
	[[ ${1:0:1} == '-' ]] && [[ "${1/ arg/}" !=  "$1" ]]
}

# is_flagged_arg
declare -A is_flagged_arg_args=(
	['1']='arg; CAN_START_WITH_FLAG'
); function is_flagged_arg() {
	is_boolean_flag "$1" || is_flag_with_arg "$1"
}

# isnr
declare -A isnr_args=(
	['1']='number input'
); function isnr() { # check if is nr
	[[ "$1" =~ ^[0-9]+$ ]]
}

declare -A function_exists_args=(
	['1']='function_name'
); function function_exists() {
	declare -f -F $1 > /dev/null
	return $?
}

# parsenv
declare -A parseenv_args=(
	['1']='path to .env'
); function parseenv() { # export variables in .env to shell
	echo "eval $(egrep -v '^#' $1 | sed -e 's/ = /=/g' | xargs -0)"
}

# grepbetween
declare -A grepbetween_args=(
	['1']='string to grep'
	['2']='grep between from'
	['3']='grep between to'
); function grepbetween() { # grep between two strings, can use (either|or)
	echo "$(grep -oP "(?<=$2).*?(?=$3)" <<< $1)"
}

# upfind
declare -A upfind_args=(
	['1']='filename to upfind'
); function upfind() { # Find closest filename upwards in filsystem
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

# eval_variable_or_string
declare -A eval_variable_or_string_args=(
	['1']='$variable/string'
); function eval_variable_or_string() { # $1 $variable/string (in string format)
	str="$1"
	if [[ ${str:0:1} == '$' ]]; then # is variable
		str="${str:1}" # rm $
		echo "${!str}" # eval var name
	else # is static value
		echo "$str" # set it and break
	fi
}

# join_by
declare -A join_by_args=(
	['1']='delimiter'
	['*']='to join'
); function join_by() { # join array by separator
	local d=$1; shift; local f=$1; shift; printf %s "$f" "${@/#/$d}";
}
