_orb_parse_declared_args_options() {
	local arg; for arg in ${_orb_declared_args[@]}; do
		_orb_set_declared_arg_options_defaults $arg

		declared_arg_options=()
		_orb_get_declared_arg_options $arg
		_orb_prevalidate_declared_arg_options $arg
		_orb_parse_declared_arg_options $arg
	done
	
	_orb_postvalidate_declared_args_options
}

_orb_set_declared_arg_options_defaults() {
	local arg=$1
	_orb_declared_requireds[$arg]=$(orb_is_any_flag $arg && echo false || echo true)
}
 
_orb_get_declared_arg_options() {
	local arg=$1
	local i=${declared_args_start_indexes[$arg]}
	local len=${declared_args_lengths[$arg]}
	local i_offset=3
	local options_i=$(( $i + $i_offset ))
	local options_len=$(( $len - $i_offset ))

	(( $len <= $i_offset )) && return # no options after
	
	if _orb_parse_declared_arg_options_arg_suffix $arg $options_i; then 
		((i_offset++))
		(( $len <= $i_offset )) && return # no options after  
		((options_i++))
		((options_len--))
  fi

	declared_arg_options=("${declaration[@]:$options_i:$options_len}")
}

# Eg -f 1, where 1 is the suffix
_orb_parse_declared_arg_options_arg_suffix() {
	local arg=$1
	local suffix_i=$2
	local suffix="${declaration[$suffix_i]}"
  
	if orb_is_any_flag $arg && orb_is_nr "$suffix"; then
		_orb_declared_arg_suffixes[$arg]="$suffix"
	else
		return 1
	fi
}

_orb_prevalidate_declared_arg_options() {
	local arg=$1
	
	if ! _orb_is_valid_arg_option $arg 0; then
		_orb_raise_invalid_declaration "$arg: Invalid option: ${declared_arg_options[0]}. Available options: ${_orb_available_arg_options[@]}"
	fi
}

_orb_parse_declared_arg_options() {
	local arg=$1
	local declared_arg_options_start_indexes=()
	local declared_arg_options_lengths=()
	_orb_get_declared_arg_options_start_indexes $arg
	_orb_get_declared_arg_options_lengths $arg
	_orb_store_declared_arg_options $arg
}

_orb_get_declared_arg_options_start_indexes() {
	local arg=$1

	local options_i; for options_i in $(seq 0 $((${#declared_arg_options[@]} - 1))); do
		if _orb_is_declared_arg_options_start_index $arg $options_i; then
			declared_arg_options_start_indexes+=( $options_i )
		fi
	done
}

_orb_is_declared_arg_options_start_index() {
	local arg=$1 
  local options_i=$2

	if _orb_is_valid_arg_option $arg $options_i; then
		# String is valid option
		local current_option="${declared_arg_options[$options_i]}"

		if [[ -n ${declared_arg_options_start_indexes[0]} ]]; then
			local prev_start_i="${declared_arg_options_start_indexes[-1]}"
			local prev_option="${declared_arg_options[$prev_start_i]}"
		fi

		if [[ -n $prev_start_i ]] && (( $prev_start_i == $options_i - 1 )); then
			_orb_raise_invalid_declaration "$prev_option invalid value: $current_option"
		elif [[ $options_i == $((${#declared_arg_options[@]} - 1)) ]]; then
			# option is last str
			_orb_raise_invalid_declaration "$current_option missing value"
		else
			return 0
		fi
	fi

	return 1
}

_orb_get_declared_arg_options_lengths() {
	local options_length=${#declared_arg_options[@]}
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


_orb_store_declared_arg_options() {
	local arg=$1
  local options_i=0

  for i in "${declared_arg_options_start_indexes[@]}"; do
    local option=${declared_arg_options[$i]}
    local value_start_i=$(( $i + 1 )) # first is option itself
    local value_len=$(( ${declared_arg_options_lengths[$options_i]} - 1 )) # hence one shorter
    local value=( "${declared_arg_options[@]:$value_start_i:$value_len}" )
    
    case $option in
      'Required:')
        _orb_declared_requireds[$arg]="$value"
        ;;
      'Comment:')
        _orb_declared_comments[$arg]="$value"
        ;;
      "Default:")
        _orb_declared_defaults_start_indexes[$arg]=${#_orb_declared_defaults[@]} # will start after last in array
        _orb_declared_defaults_lengths[$arg]=$value_len
        _orb_declared_defaults+=( "${value[@]}" )
        ;;
      "In:")
        _orb_declared_ins_start_indexes[$arg]=${#_orb_declared_ins[@]} # will start after last in array
        _orb_declared_ins_lengths[$arg]=$value_len
        _orb_declared_ins+=( "${value[@]}" )
        ;;
      "Catch:")
        _orb_declared_catchs_start_indexes[$arg]=${#_orb_declared_catchs[@]} # will start after last in array
        _orb_declared_catchs_lengths[$arg]=$value_len
        _orb_declared_catchs+=( "${value[@]}" )
        ;;
    esac

    ((options_i++))
  done
}

