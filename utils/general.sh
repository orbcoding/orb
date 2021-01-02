# parsenv
declare -A parseenv_args=(
	['1']='path to .env'
); function parseenv() { # export variables in .env to shell
	echo "eval $(egrep -v '^#' $1 | sed -e 's/ = /=/g' | xargs -0)"
}

# hasfunction
declare -A hasfunction_args=(
	['1']='function'
	['2']='file'
); function hasfunction() { # check if file has function
	listfunctions "$2" | grep -Fxq $1
}

# isnr
declare -A isnr_args=(
	['1']='number input'
); function isnr() { # check if is nr
	re='^[0-9]+$'
	[[ $1 =~ $re ]] && true || false
}

# isfunction
declare -A isfunction_args=(
	['1']='string'
); function isfunction() { # check if is function
	[ -n "$(LC_ALL=C type -t $1)" ] && [ "$(LC_ALL=C type -t $1)" = function ]
}

# grepbetween
declare -A grepbetween_args=(
	['1']='string to grep'
	['2']='grep betwen from'
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
			if [[ -f "$x/$1" ]]; then
				echo $x
				break;
				exit 0;
			fi
			x=`dirname "$x"`
	done

	exit 1;
}

# eval_variable_or_string
eval_variable_or_string_args=(
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
