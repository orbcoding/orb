function _bold() { # $(_bold)text$(_normal)
	echo $(tput bold)
}

function _italic() { # $(_italic)text$(_normal)
	echo '\e[3m'
}

function _underline() { # $(_underline)text$(_normal)
	echo '\e[4m'
}

function _red() { # $(_red)redtext...
	echo '\033[0;91m'
}

function _green() { # $(_green)greentext...
	echo '\033[0;32m'
}

function _normal() { # $(_bold)text$(_normal)
	echo $(tput sgr0)
}

function _nocolor() { # $(_nocolor)text...
 	echo '\033[0m'
}

function _upcase() { # upcase all characters in text
	echo "$1" | tr a-z A-Z
}
