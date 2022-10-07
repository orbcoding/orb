_orb_parse_declared_args_options() {
	local arg; for arg in "${_orb_declared_args[@]}"; do
		arg_options_declaration=()
		_orb_get_arg_options_declaration $arg

		_orb_prevalidate_declared_arg_options $arg
		_orb_parse_declared_arg_options $arg
	done
	
	_orb_postvalidate_declared_args_options
}


_orb_get_arg_options_declaration() {
	local arg=$1
	local i_offset=3
	[[ -n ${_orb_declared_arg_suffixes[$arg]} ]] && (( i_offset++ ))
	_orb_store_declared_arg_comment $arg $i_offset && (( i_offset++ )) 

	local options_i=$(( ${declared_args_start_indexes[$arg]} + $i_offset ))
	local options_len=$(( ${declared_args_lengths[$arg]} - $i_offset ))

	[[ $options_len == 0 ]] && return

	arg_options_declaration=("${declaration[@]:$options_i:$options_len}")
}

_orb_store_declared_arg_comment() {
	local arg=$1
	local i_offset=$2
	(( ${declared_args_lengths[$arg]} == $i_offset )) && return 1 # no comment available 

	local comment_i=$(( ${declared_args_start_indexes[$arg]} + $i_offset ))

	if ! _orb_is_valid_arg_option $arg "${declaration[$comment_i]}"; then
		_orb_declared_comments[$arg]="${declaration[$comment_i]}"
	else
		return 1
	fi
}

_orb_prevalidate_declared_arg_options() {
	local arg=$1
	[[ -z ${arg_options_declaration[@]} ]] || \
	_orb_is_valid_arg_option $arg "${arg_options_declaration[0]}" true
}

_orb_parse_declared_arg_options() {
	local arg=$1
	local declared_arg_options_start_indexes=()
	local declared_arg_options_lengths=()
	local declared_arg_option_names=()
	_orb_get_declared_arg_options_start_indexes $arg
	_orb_get_declared_arg_options_lengths $arg
	_orb_get_declared_arg_option_names $arg
	_orb_store_declared_arg_option_values $arg
}

_orb_get_declared_arg_options_start_indexes() {
	local arg=$1

	local options_i; for options_i in $(seq 0 $((${#arg_options_declaration[@]} - 1))); do
		if _orb_is_declared_arg_options_start_index $arg $options_i; then
			declared_arg_options_start_indexes+=( $options_i )
		fi
	done
}

_orb_is_declared_arg_options_start_index() {
	local arg=$1 
  local options_i=$2
	local current_option="${arg_options_declaration[$options_i]}"

	if _orb_is_valid_arg_option $arg "$current_option"; then
		if [[ -n ${declared_arg_options_start_indexes[0]} ]]; then
			local prev_start_i="${declared_arg_options_start_indexes[-1]}"
			local prev_option="${arg_options_declaration[$prev_start_i]}"
		fi

		if [[ -n $prev_start_i ]] && (( $prev_start_i == $options_i - 1 )); then
			_orb_raise_invalid_declaration "$prev_option invalid value: $current_option"
		elif [[ $options_i == $((${#arg_options_declaration[@]} - 1)) ]]; then
			# option is last str
			_orb_raise_invalid_declaration "$current_option missing value"
		else
			return 0
		fi
	fi

	return 1
}

_orb_get_declared_arg_options_lengths() {
	local options_length=${#arg_options_declaration[@]}
	local counter=1

	local i; for i in "${declared_arg_options_start_indexes[@]}"; do
		if [[ $counter == ${#declared_arg_options_start_indexes[@]} ]]; then
			# Is last declared - Ends at options end
			local ends_before=$options_length
		else
			# Not last declared - Ends before next declared
			local ends_before=${declared_arg_options_start_indexes[$counter]}
		fi

		declared_arg_options_lengths+=( $(( $ends_before - $i )) )

		((counter++))
	done
}

_orb_get_declared_arg_option_names() {
	for i in "${declared_arg_options_start_indexes[@]}"; do
    declared_arg_option_names+=(${arg_options_declaration[$i]})
	done
}

_orb_store_declared_arg_option_values() {
	local arg=$1
	local prefix; [[ $arg == "${_orb_declared_args[0]}" ]] && prefix="" || prefix=" "


	local option; for option in "${_orb_available_arg_options[@]}"; do
		local i value=() value_start_i value_len

		if i=$(orb_index_of $option declared_arg_option_names); then
			value_start_i=$(( ${declared_arg_options_start_indexes[$i]} + 1))
			value_len=$(( ${declared_arg_options_lengths[$i]} - 1))
			value=("${arg_options_declaration[@]:$value_start_i:$value_len}")
		else
			_orb_get_arg_option_default_value $arg $option value
		fi

		if [[ -n "${value[@]}" ]]; then
			_orb_declared_option_start_indexes[$option]+="$prefix${#_orb_declared_option_values[@]}"
			_orb_declared_option_values+=("${value[@]}")
			_orb_declared_option_lengths[$option]+="$prefix${#value[@]}"
		else
			_orb_declared_option_start_indexes[$option]+="${prefix}-"
			_orb_declared_option_lengths[$option]+="${prefix}-"
		fi
	done

	return 0
}

