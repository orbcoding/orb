# Save information about nested orb caller
# Copies/prefixes var => _caller_var
_vars_to_caller=(
  _current_namespace
  _function_name
  _function_descriptor
)

_arrs_to_caller=(
  _args
  _args_wildcard
  _args_declaration
)

for _var in "${_vars_to_caller[@]}"; do
  [[ -v $_var ]] && declare "_caller${_var}"="${!_var}"
done; unset _vars_to_caller _var

for _arr in ${_arrs_to_caller[@]}; do
  declare -n _arr_ref=$_arr
  declare -A _caller$_arr
  [[ ! -v "$_arr[@]" ]] && continue
  declare -n _caller_ref=_caller$_arr

  for _key in "${!_arr_ref[@]}"; do
    _caller_ref["$_key"]=${_arr_ref["$_key"]}
  done
done; unset _arrs_to_caller _arr _key
