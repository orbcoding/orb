# Save information about nested orb caller
# Copies/prefixes var => _caller_var
local _orb_vars_to_caller=(
  _orb_namespace
  _orb_function
  _orb_function_descriptor
  _orb_function_exit_code
)

local _orb_arrs_to_caller=(
  _orb_rest
  _orb_dash_rest
)

local _orb_blocks=($(_orb_has_declared_args))
local _orb_block; for _orb_block in "${_orb_blocks[@]}"; do
  _orb_arrs_to_caller+=( "$(_orb_block_to_arr_name "$_orb_block")" )
done

local _orb_associative_arrs_to_caller=(
  _args
  _orb_function_declaration
)

# vars to caller
local _orb_var; for _orb_var in "${_orb_vars_to_caller[@]}"; do
  [[ -v $_orb_var ]] && declare "_orb_caller$(orb_remove_prefix _orb ${_orb_var})"="${!_orb_var}"
done

# arrs to caller
local _orb_arr; for _orb_arr in ${_orb_arrs_to_caller[@]}; do
  declare -n _orb_arr_ref=$_orb_arr
  local _orb_caller_arr="_orb_caller$(orb_remove_prefix _orb $_orb_arr)"
  orb_is_empty_arr "$_orb_arr" && continue
  declare -a $_orb_caller_arr
  declare -n _orb_caller_ref=$_orb_caller_arr

  _orb_caller_ref=("${_orb_arr_ref[@]}")
done

# associative arrs to caller
local _orb_arr; for _orb_arr in ${_orb_associative_arrs_to_caller[@]}; do
  local _orb_caller_arr="_orb_caller$(orb_remove_prefix _orb $_orb_arr)"
  declare -n _orb_arr_ref=$_orb_arr
  declare -A $_orb_caller_arr
  orb_is_empty_arr "$_orb_arr" && continue
  declare -n _orb_caller_ref=$_orb_caller_arr

  local _orb_key; for _orb_key in "${!_orb_arr_ref[@]}"; do
    _orb_caller_ref["$_orb_key"]=${_orb_arr_ref["$_orb_key"]}
  done
done
