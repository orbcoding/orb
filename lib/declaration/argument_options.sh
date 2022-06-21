_orb_parse_args_options_declaration() {
	local arg; for arg in ${_orb_declared_args[@]}; do
		_orb_set_declared_arg_options_defaults $arg

		local arg_options_declaration=()
		_orb_get_arg_options_declaration $arg
		_orb_prevalidate_arg_options_declaration $arg
		_orb_parse_arg_options_declaration $arg
	done
	
	_orb_postvalidate_declared_args_options
}

_orb_set_declared_arg_options_defaults() {
	local arg=$1

	_orb_declared_suffixes[$arg]=("")
	_orb_declared_comments[$arg]=("")
	_orb_declared_requireds+=( $(orb_is_any_flag $arg && echo false || echo true) )

	# Below only populated if present in declaration 
	# _orb_declared_ins
	# _orb_declared_defaults
	
	# Empty indexes means no value set. Allows for empty or array values
	_orb_declared_defaults_indexes[$arg]=("") 
	_orb_declared_defaults_lengths[$arg]=("")
	_orb_declared_ins_indexes[$arg]=("") 
	_orb_declared_ins_lengths[$arg]=("")
}
 
_orb_get_arg_options_declaration() {
	local arg=$1
	local i=${arg_declaration_arg_indexes[$arg]}
	local len=${arg_declaration_arg_lengths[$arg]}
	local i_offset=3
	local options_i=$(( $i + $i_offset ))
	local options_len=$(( $len - $i_offset ))

	(( $len > $i_offset )) || return # no options after
	
	if _orb_parse_arg_options_declaration_arg_suffix $arg $options_i; then 
		((i_offset++))
		(( $len > $i_offset )) || return # no options after  
		((options_i++))
		((options_len--))
  fi

	arg_options_declaration=( "${_orb_declaration[@]:$options_i:$options_len}" )
}

# Eg -f 1, where 1 is the suffix
_orb_parse_arg_options_declaration_arg_suffix() {
	local arg=$1
	local suffix_i=$2
	local suffix="${_orb_declaration[$suffix_i]}"
  
	if orb_is_any_flag $arg && orb_is_nr "$suffix"; then
		_orb_declared_suffixes[$arg]="$suffix"
	else
		return 1
	fi
}

_orb_parse_arg_options_declaration() {
	local args_i=$1
	local arg_option_declaration_indexes=()
	local arg_option_declaration_lengths=()
	_orb_get_arg_option_declaration_indexes $args_i
	_orb_get_arg_option_declaration_lengths $args_i
	_orb_store_declared_arg_options
}

_orb_get_arg_option_declaration_indexes() {
	local args_i=$1
	local last_i=$((${#arg_options_declaration[@]} - 1))
	
	local options_i; for options_i in $(seq 0 $last_i); do
		if _orb_is_arg_option_declaration_index $args_i $options_i; then
			arg_option_declaration_indexes+=( $options_i )
		fi
	done
}

_orb_is_arg_option_declaration_index() {
	local args_i=$1 
  local options_i=$2

	if _orb_is_valid_arg_option $args_i $options_i; then
		# String is valid option
		local current_option="${arg_options_declaration[$options_i]}"

		if [[ -n ${arg_option_declaration_indexes[0]} ]]; then
			local prev_start_i="${arg_option_declaration_indexes[-1]}"
			local prev_option="${arg_options_declaration[$prev_start_i]}"
		fi

		if [[ -n $prev_start_i ]] && (( $prev_start_i == $options_i - 1 )); then
			if ! _orb_is_catch_all_option $prev_option; then
				# option directly after prev option that does not allow catch all
				_orb_raise_invalid_declaration "$prev_option invalid value: $current_option"
			fi
		elif [[ $options_i == $last_i ]]; then
			# option is last str
			_orb_raise_invalid_declaration "$current_option missing value"
		else
			return 0
		fi
	fi

	return 1
}

_orb_get_arg_option_declaration_lengths() {
	local len_d=${#arg_options_declaration[@]}
	local counter=1

	local i; for i in "${arg_option_declaration_indexes[@]}"; do
		if [[ $counter == ${#arg_option_declaration_indexes[@]} ]]; then
			# Is last declared - Ends at options end
			local ends_before=$len_d
		else
			# Not last declared - Ends before next declared
			local ends_before=${arg_option_declaration_indexes[$counter]}
		fi

		arg_option_declaration_lengths+=( $(( $ends_before - $i )) )

		((counter++))
	done
}

_orb_is_valid_arg_option() {
	# local flag_options=( )
	local args_i=$1 
	local options_i=$2
	local arg=${_orb_declared_args[$args_i]}
	local option=${arg_options_declaration[$options_i]}

	_orb_is_available_option $option || return 1

	if _orb_declared_is_boolean_flag $args_i; then 
		if _orb_is_invalid_boolean_flag_option $option; then
			_orb_raise_invalid_declaration "$arg, $option not valid option for boolean flags"
		fi
	elif _orb_declared_is_array $args_i; then
		if _orb_is_invalid_array_option $option; then
			_orb_raise_invalid_declaration "$arg, $option not valid option for array arguments"
		fi
	fi
}


_orb_store_declared_arg_options() {
  local options_i=0

  for i in "${arg_option_declaration_indexes[@]}"; do
    local option=${arg_options_declaration[$i]}
    local value_i=$(( $i + 1 )) # first is option itself
    local value_len=$(( ${arg_option_declaration_lengths[$options_i]} - 1 )) # hence one shorter
    local value=( "${arg_options_declaration[@]:$value_i:$value_len}" )
    
    case $option in
      'Required:')
        _orb_declared_requireds[-1]="$value"
        ;;
      'Comment:')
        _orb_declared_comments[-1]="$value"
        ;;
      "Default:")
        _orb_declared_defaults_indexes[-1]=${#_orb_declared_defaults[@]} # will start after last in array
        _orb_declared_defaults+=( "${value[@]}" )
        _orb_declared_defaults_lengths[-1]=$value_len
        ;;
      "In:")
        _orb_declared_ins_indexes[-1]=${#_orb_declared_ins[@]} # will start after last in array
        _orb_declared_ins+=( "${value[@]}" )
        _orb_declared_ins_lengths[-1]=$value_len
        ;;
    esac

    ((options_i++))
  done
}

_orb_prevalidate_arg_options_declaration() {
	local args_i=$1
	
	if ! _orb_is_valid_arg_option $args_i 0; then
		_orb_raise_invalid_declaration 'Options must start with valid option'
	fi
}

_orb_postvalidate_declared_args_options() {
  return 0

  # TODO
  i=0
  for arg in ${_orb_declared_args}; do
    echo $i
    echo $arg
    ((i++))
  done
}
