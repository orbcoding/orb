# These and call/history.sh
# are the only variables that should
# be available in scope of called function
# rest of variables will be declared locally inside
# lower level function calls

if [[ $1 != only_args_collection ]]; then
  # Orb settings
  declare _orb_setting_help=false
  declare _orb_setting_direct_call=false
  declare _orb_setting_reload_functions=false
  declare -a _orb_setting_extensions=()
  declare -a _orb_settings_args=()
  
  # Internal configs
  declare _orb_function_dump

  # Namespace and function info
  declare _orb_namespace
  declare _orb_function
  declare _orb_function_descriptor
  declare _orb_function_exit_code

  declare -a _orb_namespace_files=() # namespace files collector
  declare -a _orb_namespace_files_orb_dir_tracker=() # same indexes with directory

  # Extensions
  declare -a _orb_extensions=()
  # _orb_function_declaration will be a nameref to ${_orb_function_name}_orb

  # Set to point orb functions to another declaration/argument/variable 
  # Eg: ${_orb_function_declaration}${_orb_variable_suffix}
  # Useful for working with call history 
  declare _orb_variable_suffix
fi


# Call arguments and final argument values
declare -a _orb_args_positional=() # passed inline to called function
declare -a _orb_args_values=() # final arg values
# Argument as key: eg: -f
declare -A _orb_args_values_start_indexes=()
declare -A _orb_args_values_lengths=()


# Declaration
declare _orb_declared_direct_call=false
declare -a _orb_declared_args=() # ordered
declare -A _orb_declared_arg_suffixes=()
declare -A _orb_declared_vars=()
declare -A _orb_declared_comments=()

# One array holding all option values mixed
# Start_indexes and lengths for each option provided by separate arrays 
# Eg: _orb_declared_start_indexes[Default:] would return "0 2 6..." 
# for each declared arg in order, leaving '-' for blanks.
declare -a _orb_declared_option_values=() 
declare -A _orb_declared_option_start_indexes=()
declare -A _orb_declared_option_lengths=()
