_orb_set_arg_defaults() {
	local _arg; for _arg in "${!_orb_declaration[@]}"; do
		[[ -n ${_args["$_arg"]+x} ]] && continue # next if already has value

		local _def _default _value
		_def="$(_orb_arg_default_prop)" && _default="$_def"

		if [[ -z ${_default+x} ]]; then
			# DEFAULT == null => set flags blocks, and wildcard to false for ez conditions
			orb_is_flag "$_arg" || _is_wildcard "$_arg" || orb_is_block "$_arg" && _args["$_arg"]=false
		elif _value=$(orb_eval_variable_or_string_options "$_default"); then
			# evaled DEFAULT value != null
			_orb_assign_default
		# else eval DEFAULT value == null => do nothing
		fi; 
		unset _def _default _value
	done
}

_orb_assign_default() {
	[[ "$_value" == "unset" ]] && return

	if [[ "$_arg" == '*' ]]; then
		_orb_wildcard+=("$_value")
		_args["$_arg"]=true
	elif [[ "$_arg" == '-- *' ]]; then
		_orb_dash_wildcard+=("$_value")
		_args["$_arg"]=true
	elif orb_is_block "$_arg"; then
		local _arr_name="$(_orb_block_to_arr_name "$_arg")"
		declare -n _arr_ref="$_arr_name"
		_arr_ref+=("$_value")
		_args[$_arg]=true
	else
		_args["$_arg"]="$_value"
		orb_is_nr "$_arg" && _args_nrs["$_arg"]="$_value"
	fi
}
