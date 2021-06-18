# Save information about nested orb caller
# Copies/prefixes var => _caller_var
local _vars_to_caller=(
  _current_namespace
  _function_name
  _function_descriptor
)

local _arrs_to_caller=(
  _args_wildcard
  _args_dash_wildcard
)

local _blocks=($(_declared_blocks))
local _block; for _block in "${_blocks[@]}"; do
  _arrs_to_caller+=( "$(_block_to_arr_name "$_block")" )
done

local _associative_arrs_to_caller=(
  _args
  _args_declaration
)

# vars to caller
local _var; for _var in "${_vars_to_caller[@]}"; do
  [[ -v $_var ]] && declare "_caller${_var}"="${!_var}"
done

# arrs to caller
local _arr; for _arr in ${_arrs_to_caller[@]}; do
  declare -n _arr_ref=$_arr
  _is_empty_arr "$_arr" && continue
  declare -a _caller$_arr
  declare -n _caller_ref=_caller$_arr

  _caller_ref=("${_arr_ref[@]}")
done

# associative arrs to caller
local _arr; for _arr in ${_associative_arrs_to_caller[@]}; do
  declare -n _arr_ref=$_arr
  declare -A _caller$_arr
  _is_empty_arr "$_arr" && continue
  declare -n _caller_ref=_caller$_arr

  local _key; for _key in "${!_arr_ref[@]}"; do
    _caller_ref["$_key"]=${_arr_ref["$_key"]}
  done
done
