# _upfind_closest
declare -A _upfind_closest_args=(
	['1']='filename to _upfind_closest'
	['2']='starting path; DEFAULT: $PWD'
); function _upfind_closest() { # Find closest filename upwards in filsystem
	local _p="${2-$PWD}" _sep _options

	[[ ${_p[1]} != '/' ]] && _p="$(pwd)/$_p"

	while [ "$_p" != "/" ] ; do
			if [[ -e "$_p/$1" ]]; then
				echo "$_p/$1"
				return 0;
			fi
			_p=`dirname "$_p"`
	done

	return 1;
}

# _upfind_to_arr
declare -A _upfind_to_arr_args=(
	['1']='array name'
	['2']='filename(s) multiple files sep with & (and) or | (or)'
	['3']='starting path; DEFAULT: $PWD'
); function _upfind_to_arr() { # finds all files with filename(s) upwards in file system
	local _p="${3-$PWD}"

	[[ ${_p[1]} != '/' ]] && _p="$(pwd)/$_p"

	declare -n _arr=$1
	[[ -n "$2" ]] && local _path="$2"

	local _sep='&'; [[ $2 == *"|"* ]] && _sep='|'

	local _options; IFS="$_sep" read -r -a _options <<< $2 # split by sep
	local _option

	while [ "$_p" != "/" ] ; do
		local _found=false

		for _option in "${_options[@]}"; do
			if [[ -e "$_p/$_option" ]]; then
				[[ $_sep == '|' ]] && $_found && break
				_arr+=( "$_p/$_option" )
			fi
		done

		_p=$(dirname "$_p")
	done
}

# parsenv
declare -A _parse_env_args=(
	['1']='path to .env'
); function _parse_env() { # export variables in .env to shell
	set -o allexport; source "$1"; set +o allexport
}

# has_public_function $1 function, $2 file
declare -A _has_public_function_args=(
	['1']='function_name'
	['2']='file'
); function _has_public_function() { # check if file has function
	grep -q "^[); ]*function[ ]*$1[ ]*()[ ]*{" "$2"
}
