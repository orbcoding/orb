# Save information about nested orb caller
# Copies/prefixes var => _orb_caller_var
_vars_to_caller=(
  _script_name
  _function_name
  _script_function_path
  _args_explanation
)

_arrs_to_caller=(
  _args
  _args_wildcard
  _args_declaration
)

for _var in "${_vars_to_caller[@]}"; do
  [[ -v $_var ]] && declare "_orb_caller${_var}"="${!_var}"
done; unset _vars_to_caller _var

if [[ -n $_orb_caller_script_name && -n $_orb_caller_function_name ]]; then
  _orb_caller_descriptor="$_orb_caller_script_name->$(bold)$_orb_caller_function_name$(normal)"
fi

for _arr in ${_arrs_to_caller[@]}; do
  declare -n _arr_ref=$_arr
  declare -A _orb_caller$_arr
  [[ ! -v "$_arr[@]" ]] && continue
  declare -n _orb_caller_ref=_orb_caller$_arr

  for _key in "${!_arr_ref[@]}"; do
    _orb_caller_ref["$_key"]=${_arr_ref["$_key"]}
  done
done; unset _arrs_to_caller _arr _key
