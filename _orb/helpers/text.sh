function bold() { # $(orb bold)text$(orb nostyle)
	echo $(tput bold)
}

function italic() { # $(orb italic)text$(orb nostyle)
	echo '\e[3m'
}

function underline() { # $(orb underline)text$(orb nostyle)
	echo '\e[4m'
}

function red() {
	echo '\033[0;91m'
}

function nostyle() { # $(orb bold)text$(orb nostyle)
	echo $(tput sgr0)
}

function nocolor() {
 	echo '\033[0m'
}

