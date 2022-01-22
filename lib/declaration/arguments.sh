_orb_parse_declaration() {
	_orb_prevalidate_declaration
	local arg_declaration_indexes=()
	local arg_declaration_lengths=()
	_orb_parse_declared_args
	_orb_parse_args_options_declaration
	# TODO check other global options before/after args
}

_orb_parse_declared_args() {
	_orb_get_arg_declaration_indexes
	_orb_get_arg_declaration_lengths
	_orb_store_declared_args
}

_orb_get_arg_declaration_indexes() {
	local i=1
	local len=${#_orb_declaration[@]}

	# Skip first and last as arg declaring equal signs need surrounding strings
	local str; for str in "${_orb_declaration[@]:$i:$(( $len-2 ))}"; do
		if [[ "$str" == "=" ]]; then 
			start_i=$(( $i - 1 )) # declaration starts before equal sign

			if _orb_is_arg_declaration_index $start_i; then
				arg_declaration_indexes+=( $start_i )
			fi
		fi

		((i++))
	done
}

_orb_is_arg_declaration_index() {
	local var_i=$1
	local arg_i=$(( $var_i+2 )) # skip equal sign
	local var=${_orb_declaration[$var_i]}
	local arg=${_orb_declaration[$arg_i]}

	if ! (orb_is_valid_variable_name "$var" && orb_is_input_arg "$arg"); then
		return 1
	fi
}

_orb_get_arg_declaration_lengths() {
	local len_d=${#_orb_declaration[@]}
	local counter=1

	local i; for i in "${arg_declaration_indexes[@]}"; do
		if [[ $counter == ${#arg_declaration_indexes[@]} ]]; then
			local ends_before=$len_d
		else
			# Not last declared - Ends before next declared
			local ends_before=${arg_declaration_indexes[$counter]}
		fi

		arg_declaration_lengths+=( $(( $ends_before - $i )) )

		((counter++))
	done
}

_orb_store_declared_args() {
	local i; for i in "${arg_declaration_indexes[@]}"; do
		_orb_declared_vars+=( ${_orb_declaration[$i]} )
		_orb_declared_args+=( ${_orb_declaration[$i+2]} )
	done
}

