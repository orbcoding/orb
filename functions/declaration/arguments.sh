_orb_parse_declared_args() {
	declare -n declaration=${1-"_orb_function_declaration"}
	declare -A declared_args_start_indexes
	declare -A declared_args_lengths
	_orb_get_declarad_args_and_start_indexes
	_orb_validate_declared_args
	_orb_get_declared_args_lengths
	_orb_parse_declared_args_options
}

_orb_get_declarad_args_and_start_indexes() {
	local i=1; 
	# Skip first and last as arg declaring equal signs need surrounding strings
	local str; for str in "${declaration[@]:$i:$(( ${#declaration[@]}-2 ))}"; do
		if [[ "$str" == "=" ]]; then 
			local arg=${declaration[$i-1]}
			local var="${declaration[$i+1]}"
			local valid_var=false; orb_is_valid_variable_name "$var" && valid_var=true

			if orb_is_input_arg "$arg" && ($valid_var || $_orb_declared_direct_call); then
				if [[ $i != 1 ]] && orb_is_nr $arg && orb_is_any_flag ${declaration[$i-2]}; then
					arg=${declaration[$i-2]}
					_orb_declared_arg_suffixes[$arg]=${declaration[$i-1]}
					declared_args_start_indexes[$arg]=$(($i - 2))
				else
					declared_args_start_indexes[$arg]=$(($i - 1))
				fi

				_orb_declared_args+=($arg)

				if $valid_var; then
					_orb_declared_vars[$arg]="$var"
				elif $_orb_declared_direct_call; then
					_orb_declared_comments[$arg]="$var"
				else
					_orb_raise_invalid_declaration "$arg: invalid variable name '$var'."
				fi
			fi
		fi

		((i++))
	done
}

_orb_get_declared_args_lengths() {
	local counter=1

	local arg; for arg in "${_orb_declared_args[@]}"; do
		if [[ $counter == ${#_orb_declared_args[@]} ]]; then
			# Last declared
			local ends_before=${#declaration[@]}
		else
			# Not last declared - Ends before next declared
			local ends_before=${declared_args_start_indexes[${_orb_declared_args[$counter]}]}
		fi

		declared_args_lengths[$arg]=$(( $ends_before - ${declared_args_start_indexes[$arg]} ))

		((counter++))
	done
}

