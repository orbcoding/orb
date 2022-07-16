_orb_parse_declaration() {
	declare -n declaration=${1-"_orb_function_declaration"}
	_orb_prevalidate_declaration

	# local internal variables
	declare -A declared_args_start_indexes
	declare -A declared_args_lengths

	_orb_parse_declared_args
	_orb_parse_declared_args_options
	# TODO check other global options before/after args
}

_orb_parse_declared_args() {
	_orb_get_declarad_args_and_start_indexes
	_orb_get_declared_args_lengths
	# _orb_store_declared_args
}

_orb_get_declarad_args_and_start_indexes() {
	local i=1; 
	# Skip first and last as arg declaring equal signs need surrounding strings
	local str; for str in "${declaration[@]:$i:$(( ${#declaration[@]}-2 ))}"; do
		if [[ "$str" == "=" ]]; then 
			local var=${declaration[$i-1]}
			local arg=${declaration[$i+1]}

			if (orb_is_valid_variable_name "$var" && orb_is_input_arg "$arg"); then
				_orb_declared_args+=($arg)
				_orb_declared_vars[$arg]=$var
				declared_args_start_indexes[$arg]=$(($i - 1))
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

		declared_args_lengths[$arg]=$(( $ends_before - "${declared_args_start_indexes[$arg]}" ))

		((counter++))
	done
}

