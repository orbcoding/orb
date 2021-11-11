_set_arg_defaults() {
	local _arg; for _arg in "${!_args_declaration[@]}"; do
		[[ -n ${_args["$_arg"]+x} ]] && continue # next if already has value

		local _def _default _value
		_def="$(_arg_default_prop)" && _default="$_def"

		if [[ -z ${_default+x} ]]; then
			# DEFAULT == null => set flags blocks, and wildcard to false for ez conditions
			_is_flag "$_arg" || _is_wildcard "$_arg" || _is_block "$_arg" && _args["$_arg"]=false
		elif _value=$(_eval_variable_or_string_options "$_default"); then
			# evaled DEFAULT value != null
			_assign_default
		# else eval DEFAULT value == null => do nothing
		fi; 
		unset _def _default _value
	done
}

_assign_default() {
	[[ "$_value" == "unset" ]] && return

	if [[ "$_arg" == '*' ]]; then
		_args_wildcard+=("$_value")
		_args["$_arg"]=true
	elif [[ "$_arg" == '-- *' ]]; then
		_args_dash_wildcard+=("$_value")
		_args["$_arg"]=true
	elif _is_block "$_arg"; then
		local _arr_name="$(_block_to_arr_name "$_arg")"
		declare -n _arr_ref="$_arr_name"
		_arr_ref+=("$_value")
		_args[$_arg]=true
	else
		_args["$_arg"]="$_value"
		_is_nr "$_arg" && _args_nrs["$_arg"]="$_value"
	fi
}
