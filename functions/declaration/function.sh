_orb_parse_function_declaration() {
	declare -n declaration=${1-"_orb_function_declaration"}
	local parse_args=${2-true}
	_orb_prevalidate_declaration
	_orb_parse_function_options
	$parse_args && _orb_parse_declared_args "$@" || return 0
}
 
_orb_parse_function_options() {
	declare -a declared_function_options_start_indexes
	declare -a declared_function_options_lengths
	declare -a declared_function_options
	_orb_get_function_options
	_orb_prevalidate_declared_function_options
	_orb_get_function_options_start_indexes
	_orb_get_function_options_lengths
	_orb_store_function_options
	_orb_postvalidate_declared_function_options
}

_orb_get_function_options() {
	local start_i=0;
	local end_i; for end_i in $(seq 0 $((${#declaration[@]} - 1))); do
		# We need to know if declared direct call ahead of time to know if argument assignment needs a valid_var or just comment
		if [[ ${declaration[$end_i]} == "DirectCall:" ]] && [[ ${declaration[$end_i+1]} == true ]]; then
			_orb_declared_direct_call=true
		fi

		if [[ ${declaration[$end_i+1]} == "=" ]] && orb_is_input_arg ${declaration[$end_i]} && (\
			$_orb_declared_direct_call || orb_is_valid_variable_name ${declaration[$end_i+2]} \
		); then 
			((end_i--))
			break
		fi
	done

	declared_function_options=( "${declaration[@]:$start_i:$end_i+1}" )
	_orb_extract_function_comment && declared_function_options=( "${declared_function_options[@]:1}" )
}

_orb_prevalidate_declared_function_options() {
	_orb_is_valid_function_option ${declared_function_options[0]} true
}

_orb_extract_function_comment() {
	local comment=${declared_function_options[0]}
	if [[ -n $comment ]] && ! _orb_is_available_function_option $comment; then
		_orb_declared_comments["function"]="$comment"
	else
		return 1
	fi
}

_orb_get_function_options_start_indexes() {
	local options_i; for options_i in $(seq 0 $((${#declared_function_options[@]} - 1))); do
		if _orb_is_function_options_start_index $options_i; then
			declared_function_options_start_indexes+=( $options_i )
		fi
	done
}

_orb_is_function_options_start_index() {
  local options_i=$1
	local current_option="${declared_function_options[$options_i]}"

	if _orb_is_available_function_option $current_option; then
		if [[ -n ${declared_function_options_start_indexes[0]} ]]; then
			local prev_start_i="${declared_function_options_start_indexes[-1]}"
			local prev_option="${declared_function_options[$prev_start_i]}"
		fi

		if [[ -n $prev_start_i ]] && (( $prev_start_i == $options_i - 1 )); then
			_orb_raise_invalid_declaration "$prev_option invalid value: $current_option"
		elif [[ $options_i == $((${#declared_function_options[@]} - 1)) ]]; then
			# option is last str
			_orb_raise_invalid_declaration "$current_option missing value"
		else
			return 0
		fi
	fi

	return 1
}

_orb_get_function_options_lengths() {
	local options_length=${#declared_function_options[@]}
	local counter=1

	local i; for i in "${declared_function_options_start_indexes[@]}"; do
		if [[ $counter == ${#declared_function_options_start_indexes[@]} ]]; then
			# Is last declared - Ends at options end
			local ends_before=$options_length
		else
			# Not last declared - Ends before next declared
			local ends_before=${declared_function_options_start_indexes[$counter]}
		fi

		declared_function_options_lengths+=( $(( $ends_before - $i )) )

		((counter++))
	done
}


_orb_store_function_options() {
  local options_i=0

  local i; for i in "${declared_function_options_start_indexes[@]}"; do
    local option=${declared_function_options[$i]}
    local value_start_i=$(( $i + 1 )) # first is option itself
    local value_len=$(( ${declared_function_options_lengths[$options_i]} - 1 )) # hence one shorter
    local value=( "${declared_function_options[@]:$value_start_i:$value_len}" )


    case $option in
      'DirectCall:')
        _orb_declared_direct_call="${value[@]}"
        ;;
    esac

    ((options_i++))
  done

	return 0
}
