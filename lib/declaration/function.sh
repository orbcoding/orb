_orb_parse_function_declaration() {
	declare -n declaration=${1-"_orb_function_declaration"}
	_orb_prevalidate_declaration

	declare -A declared_args_start_indexes
	declare -A declared_args_lengths
	_orb_parse_declared_args
	_orb_parse_function_options
}
 
_orb_parse_function_options() {
	local args_start_i=${declared_args_start_indexes[${_orb_declared_args[0]}]}
	[[ $args_start_i == 0 ]] && return 1

	local options=${declaration[@]:0:$args_start_i}

	_orb_extract_function_comment #&& options=${options:1:${#options[@]}} 
}

_orb_extract_function_comment() {
	_orb_declared_comments["function"]="${options[0]}"
}
