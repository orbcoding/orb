# parsenv
declare -A parseenv_args=(
	['1']='path to .env'
); function parseenv() { # export variables in .env to shell
	echo "eval $(egrep -v '^#' $1 | sed -e 's/ = /=/g' | xargs -0)"
}

# isnr
declare -A isnr_args=(
	['1']='number input'
); function isnr() { # check if is nr
	[[ $1 =~ '^[0-9]+$' ]]
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

# list_public_functions
declare -A list_public_functions=(
	['*']='files'
); function list_public_functions() {
	for file in "$@"; do
		grep "^[); ]*function" $file | sed 's/\(); \)*function //' | cut -d '(' -f1
	done
}

# has_public_function
declare -A has_public_function_args=(
	['1']='function'
	['2']='file'
); function has_public_function() { # check if file has function
	orb utils list_public_functions "$2" | grep -Fxq $1
}
