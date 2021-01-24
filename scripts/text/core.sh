function _bold() { # $(orb text bold)text$(orb text normal)
	echo $(tput bold)
}

function _italic() { # $(orb text italic)text$(orb text normal)
	echo '\e[3m'
}

function _underline() { # $(orb text underline)text$(orb text normal)
	echo '\e[4m'
}

function _red() { # $(orb text red)redtext...
	echo '\033[0;91m'
}

function _normal() { # $(orb text bold)text$(orb text normal)
	echo $(tput sgr0)
}

function _nocolor() { # $(orb text nocolor)text...
 	echo '\033[0m'
}

function _upcase() { # upcase all characters in text
	echo "$1" | tr a-z A-Z
}

