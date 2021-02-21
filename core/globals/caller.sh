# Save information about nested orb caller
# Copies/prefixes var => _caller_var
local _vars_to_caller=(
  _current_namespace
  _function_name
  _function_descriptor
)

local _arrs_to_caller=(
  _args
  _args_wildcard
  _args_declaration
)

local _var; for _var in "${_vars_to_caller[@]}"; do
  [[ -v $_var ]] && declare "_caller${_var}"="${!_var}"
done

local _arr; for _arr in ${_arrs_to_caller[@]}; do
  declare -n _arr_ref=$_arr
  declare -A _caller$_arr
  [[ ! -v "$_arr[@]" ]] && continue
  declare -n _caller_ref=_caller$_arr

  local _key; for _key in "${!_arr_ref[@]}"; do
    _caller_ref["$_key"]=${_arr_ref["$_key"]}
  done
done
