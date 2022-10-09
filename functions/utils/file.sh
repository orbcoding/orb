# orb_find_closest_below
orb_find_closest_below_orb=(
	"Find closest filename upwards in filsystem"
	DirectCall: true

	1 = 'filename to orb_find_closest_below'
	2 = 'starting path'
		Default: Help: '$PWD'
)
function orb_find_closest_below() {
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

# orb_find_below_to_arr
orb_find_below_to_arr_orb=(
	"Finds all files with filename(s) upwards in file system"
	DirectCall: true

	1 = 'array_name realpath_array_name (latter optional space separated)'
	2 = 'filename(s) multiple files sep with & (and) or | (or)'
	3 = 'start path; DEFAULT: $PWD'
	4 = 'last check path; DEFAULT: /'
)
function orb_find_below_to_arr() {
	declare -n _orb_arr=$1
	local _orb_sep='&'; [[ $2 == *"|"* ]] && _orb_sep='|'
	local _orb_p="${3-$PWD}"
	local _orb_stop_p="${4-/}"

	[[ ${_orb_p:0:1} != '/' ]] && _orb_p="$(pwd)/$_orb_p"
	[[ ${_orb_stop_p:0:1} != '/' ]] && _orb_stop_p="$(pwd)/$_orb_stop_p"

	local _orb_files _orb_file; IFS="$_orb_sep" read -r -a _orb_files <<< $2 # split by sep
	local _orb_fullpath

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
	"Remove any non unique realpaths (symlinked duplicates) from array of paths"
	DirectCall: true

	1 = _orb_input_array "Input path array name"
	2 = _orb_uniq_array "Array name to store trimmed realpath array version"
)
function orb_trim_uniq_realpaths() {
	declare -n _orb_i_array=$1
	declare -n _orb_uniq_assign=$2
	local _orb_u_array=()
	local _orb_realpaths=()
	local _orb_realpath

	local _orb_path; for _orb_path in "${_orb_i_array[@]}"; do
		_orb_realpath=$(realpath $_orb_path)

	  if ! orb_in_arr $_orb_realpath _orb_realpaths; then
			_orb_u_array+=($_orb_path)
			_orb_realpaths+=("$_orb_realpath")
		fi
	done

	_orb_uniq_assign=("${_orb_u_array[@]}")
}

# orb_parse_env
orb_parse_env_orb=(
	"Export variables in .env to shell"
	DirectCall: true

	1 = 'path to .env'
)
function orb_parse_env() {
	set -o allexport; source "$1"; set +o allexport
}

# orb_has_public_function
orb_has_public_function_orb=(
	"Check if file has function"
	DirectCall: true

	1 = "Function name"
	2 = "File"
)
function orb_has_public_function() {
	grep -q "^[); ]*function[ ]$1[ ]*()" "$2"
}

# orb_get_public_functions
orb_get_public_functions_orb=(
	"Get list public functions in file"
	DirectCall: true

	1 = "File"
	2 = "Assign to arr name"
)
function orb_get_public_functions() {
	local file=$1
	declare -n assign_arr=$2

	# Find function line
	# Remove preceeding "); " up to and including function statement
	# Get first word = function_name ignoring whitespace
	# Remove any () from function_name
	assign_arr=($(\
		grep "^[); ]*function[ ]*[a-zA-Z_-]*[ ]*()" $file | \
			sed 's/\(); \)*function//' | \
			awk '{print $1;}' | \
			sed 's/()//'\
		 ))
}
