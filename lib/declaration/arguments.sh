_orb_parse_declaration() {
	declare -n declaration=$1
	_orb_prevalidate_declaration
	declare -A arg_declaration_arg_indexes
	declare -A arg_declaration_arg_lengths
	_orb_parse_declared_args
	_orb_parse_args_options_declaration
	# TODO check other global options before/after args
}

_orb_parse_declared_args() {
	_orb_get_arg_declaration_arg_indexes_vars_and_args
	_orb_get_arg_declaration_arg_lengths
	_orb_store_declared_args
}

_orb_get_arg_declaration_arg_indexes_vars_and_args() {
	local i=1; 
	# Skip first and last as arg declaring equal signs need surrounding strings
	local str; for str in "${declaration[@]:$i:$(( ${#declaration[@]}-2 ))}"; do
		if [[ "$str" == "=" ]]; then 
			local var=${declaration[$i-1]}
			local arg=${declaration[$i+1]}

			if (orb_is_valid_variable_name "$var" && orb_is_input_arg "$arg"); then
				_orb_declared_args+=($arg)
				_orb_declared_vars[$arg]=$var
				arg_declaration_arg_indexes[$arg]=$(($i - 1))
			fi
		fi

		((i++))
	done
}

_orb_get_arg_declaration_arg_lengths() {
	local counter=1

	local arg; for arg in "${!arg_declaration_arg_indexes[@]}"; do
		if [[ $counter == ${#arg_declaration_arg_indexes[@]} ]]; then
			# Last declared
			local ends_before=${#declaration[@]}
		else
			# Not last declared - Ends before next declared
			local ends_before=${arg_declaration_arg_indexes[$counter]}
		fi

		arg_declaration_arg_lengths[$arg]=$(( $ends_before - "${arg_declaration_arg_indexes[$arg]}" ))

		((counter++))
	done
}

