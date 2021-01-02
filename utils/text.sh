function bold() { # $(bold)text$(normal)
	echo $(tput bold)
}

function normal() { # $(bold)text$(normal)
	echo $(tput sgr0)
}

function italic() { # $(italic)text$(normal)
	echo '\e[3m'
}

function underline() { # $(underline)text$(normal)
	echo '\e[4m'
}

declare -A color_args=(
	['1']='color; IN: red|none'
); function color() { # $(color red)text$(color normal)
	[[ $1 == 'red' ]] && echo '\033[0;91m'
	[[ $1 == 'none' ]] && echo '\033[0m' # No Color
}
