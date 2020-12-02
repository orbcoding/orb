#!/bin/bash
# Run in shell by ./utils.sh functionName

# Use by $(./utils.sh parseenv path/to/.env)
parseenv() {
	echo "eval $(egrep -v '^#' $1 | sed -e 's/ = /=/g' | xargs -0)"
}

listfunctions() { # $1 = path, $2 = with_comments=0
	if [[ $2 == '1' ]]; then
		grep "^function" "$1" | cut -d ' ' -f2- | sed 's/() {/ --/g'
	else
		grep "^function" "$1" | cut -d ' ' -f2 | sed 's/()//g'
	fi
}

hasfunction() { # $1 = function, $2 = file
	listfunctions $2 | grep -Fxq $1
}


cpsamples() {
	from=$1; to=$2
	for file in $(find $from -maxdepth 1 -type f -exec basename {} \;); do
		cp -n "$from/$file" "$to/${file//sample./}";
	done;
}

splitstring() { # $1 = string, $2 = delimiter, $3 = return index
	IFS=$2 read -r -a array <<< "$1"
	echo "${array[$3]}"
}

upfind() { # $1 = filename
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

# To enable running functions directly
# https://stackoverflow.com/questions/8818119/how-can-i-run-a-function-from-a-script-in-command-line
"$@"

