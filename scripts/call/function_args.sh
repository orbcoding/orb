if ! $_orb_setting_raw_args && ! $_orb_declared_raw_args; then 
  _orb_collect_function_args "$@"
  
  # Collecting arg values is separated from final assignment to declared variables. 
  # This allows for freely named local variables in the collection process 
  # without risk of shadowing the user's argument variables in the top scope
  
  # Declare variables as local in orb function scope
  for _orb_var in "${_orb_declared_vars[@]}"; do
    declare "$_orb_var"=
  done; unset _orb_var

  _orb_assign_stored_arg_values_to_declared_variables
fi

_orb_set_function_positional_args "$@"
