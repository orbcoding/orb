function bold() { # $(orb text bold)text$(orb text normal)
	echo $(tput bold)
}

function italic() { # $(orb text italic)text$(orb text normal)
	echo '\e[3m'
}

function underline() { # $(orb text underline)text$(orb text normal)
	echo '\e[4m'
}

function red() { # $(orb text red)redtext...
	echo '\033[0;91m'
}

function normal() { # $(orb text bold)text$(orb text normal)
	echo $(tput sgr0)
}

function nocolor() { # $(orb text nocolor)text...
 	echo '\033[0m'
}

