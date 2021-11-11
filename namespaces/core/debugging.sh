# _ee
declare -A _ee_args=(
  ['*']='msg; CATCH_ANY'
); function _ee() { # echo to stderr, useful for debugging without polluting stdout
  echo "$@" >&2
}

# _print_args
function _print_args() { # print collected arguments, useful for debugging
  source orb

	declare -A | grep 'A _caller_args=' | cut -d '=' -f2-

  local _blocks=( $(_declared_blocks _caller_args_declaration) )
  local _block; for _block in "${_blocks[@]}"; do
    declare -n ref="$(_block_to_arr_name "$_block")"
    if [[ ${_caller_args["$_block"]} == true ]]; then
      echo "[$_block]=${ref[*]}"
    fi
  done
  
  # | cut -d '=' -f2-
	if [[ ${_caller_args["*"]} == true || ${_caller_args["-- *"]} == true ]]; then
    echo "[*]=${_caller_args_wildcard[*]}"
    echo "[-- *]=${_caller_args_dash_wildcard[*]}"
  fi
}

