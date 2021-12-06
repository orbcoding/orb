# _ee
declare -A _ee_args=(
  ['*']='msg; CATCH_ANY'
); function _ee() { # echo to stderr, useful for debugging without polluting stdout
  echo "$@" >&2
}

# _print_args
function _print_args() { # print collected arguments, useful for debugging
  source orb

	declare -A | grep 'A _orb_caller_args=' | cut -d '=' -f2-

  local _orb_blocks=( $(_orb_declared_blocks _orb_caller_args_declaration) )
  local _orb_block; for _orb_block in "${_orb_blocks[@]}"; do
    declare -n ref="$(_orb_block_to_arr_name "$_orb_block")"
    if [[ ${_orb_caller_args["$_orb_block"]} == true ]]; then
      echo "[$_orb_block]=${ref[*]}"
    fi
  done
  
  # | cut -d '=' -f2-
	if [[ ${_orb_caller_args["*"]} == true || ${_orb_caller_args["-- *"]} == true ]]; then
    echo "[*]=${_orb_caller_wildcard[*]}"
    echo "[-- *]=${_orb_caller_dash_wildcard[*]}"
  fi
}

