# orb_upfind_closest
declare -A orb_upfind_closest_args=(
	['1']='filename to orb_upfind_closest'
	['2']='starting path; DEFAULT: $PWD'
); function orb_upfind_closest() { # Find closest filename upwards in filsystem
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

# orb_upfind_to_arr
declare -A orb_upfind_to_arr_args=(
	['1']='array_name realpath_array_name (latter optional space separated)'
	['2']='filename(s) multiple files sep with & (and) or | (or)'
	['3']='start path; DEFAULT: $PWD'
	['4']='last check path; DEFAULT: /'
); function orb_upfind_to_arr() { # finds all files with filename(s) upwards in file system
	# local _orb_arr_names=($1)
	declare -n _orb_arr=$1
	local _orb_sep='&'; [[ $2 == *"|"* ]] && _orb_sep='|'
	local _orb_p="${3-$PWD}"
	local _orb_stop_p="${4-/}"

	[[ ${_orb_p:0:1} != '/' ]] && _orb_p="$(pwd)/$_orb_p"
	[[ ${_orb_stop_p:0:1} != '/' ]] && _orb_stop_p="$(pwd)/$_orb_stop_p"

	local _orb_files _orb_file; IFS="$_orb_sep" read -r -a _orb_files <<< $2 # split by sep

	while true; do
		for _orb_file in "${_orb_files[@]}"; do
			_orb_fullpath="$_orb_p/$_orb_file"

			if [[ -e "$_orb_fullpath" ]]; then
					_orb_arr+=( "$_orb_p/$_orb_file" )
					[[ $_orb_sep == '|' ]] && break
			fi
		done

		[[ "$_orb_p" == "$_orb_stop_p" ]] || [[ "$_orb_p" == '/' ]] && break
		_orb_p=$(dirname "$_orb_p")
	done
}

# orb_trim_uniq_realpaths
orb_trim_uniq_realpaths_orb=(
	1 = _orb_input_array "Input path array name"
	2 = _orb_uniq_array "Array name to store trimmed realpath array version"
); function orb_trim_uniq_realpaths() {
	declare -n _orb_i_array=$1
	local _orb_u_array=()
	local _orb_realpaths=()
	local _orb_realpath

	local _orb_path; for _orb_path in "${_orb_i_array[@]}"; do
		_orb_realpath=$(realpath $_orb_path)

	  if ! [[ " ${_orb_realpaths[@]} " =~ " $_orb_realpath " ]]; then 
			_orb_u_array+=($_orb_path)
			_orb_realpaths+=("$_orb_realpath")
		fi
	done

	declare -n _orb_uniq_assign=$2
	_orb_uniq_assign=("${_orb_u_array[@]}")
}

# parsenv
declare -A orb_parse_env_args=(
	['1']='path to .env'
); function orb_parse_env() { # export variables in .env to shell
	set -o allexport; source "$1"; set +o allexport
}

# has_public_function $1 function, $2 file
declare -A orb_has_public_function_args=(
	['1']='function_name'
	['2']='file'
); function orb_has_public_function() { # check if file has function
	grep -q "^[); ]*function[ ]*$1[ ]*()[ ]*{" "$2"
}
