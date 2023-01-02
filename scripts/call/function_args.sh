# Set args locally
local _orb_var; for _orb_var in "${_orb_declared_vars[@]}"; do 
  declare "$_orb_var"=
done; unset _orb_var

if ! $_orb_setting_raw_args && ! $_orb_declared_raw_args; then 
  _orb_collect_function_args "$@"
fi
_orb_set_function_positional_args "$@"
