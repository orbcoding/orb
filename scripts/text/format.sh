function bold() { # $(orb text bold)text$(orb text reset)
	echo $(tput bold)
}

function italic() { # $(orb text italic)text$(orb text reset)
	echo '\e[3m'
}

function underline() { # $(orb text underline)text$(orb text reset)
	echo '\e[4m'
}

function red() { # $(orb text red)redtext...
	echo '\033[0;91m'
}

function reset() { # $(orb text bold)text$(orb text reset)
	echo $(tput sgr0)
}

function nocolor() { # $(orb text nocolor)text...
 	echo '\033[0m'
}

