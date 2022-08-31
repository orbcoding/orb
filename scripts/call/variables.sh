# These and call/history.sh
# are the only variables that should
# be available in scope of called function
# rest of variables will be declared locally inside
# lower level function calls

if [[ $1 != only_args_collection ]]; then
  # Orb settings
  declare _orb_setting_help=false
  declare _orb_setting_namespace_help=false
  declare _orb_setting_direct_call=false
  declare _orb_setting_reload_functions=false
  declare _orb_setting_sourced=false
  declare _orb_setting_extensions=()

  # Namespace info
  declare _orb_namespace
  declare _orb_function
  declare _orb_function_descriptor
  declare _orb_function_exit_code

  declare _orb_namespace_files=() # namespace files collector
  declare _orb_namespace_files_dir_tracker # index with directory

  # Extensions
  declare _orb_extensions=()
  # local _orb_namespace_files=()
  # local _orb_namespace_files_dirs=()

  # Will be a nameref to ${_orb_function_name}_orb declaration
  declare -a _orb_function_declaration

  # Set to point orb functions to another declaration/argument/variable 
  # Eg: ${_orb_function_declaration}${_orb_variable_suffix}
  # Useful for working with call history 
  declare _orb_variable_suffix
fi

# Call arguments and final argument values
declare -a _orb_args_positional # passed inline to called function
declare -a _orb_args_values # final arg values
# Argument as key: eg: -f
declare -A _orb_args_values_start_indexes
declare -A _orb_args_values_lengths


# Declaration
declare -a _orb_declared_args # ordered
# Argument as key: eg: -f
# TODO might verbose _orb_declared_arg_vars etc
declare -A _orb_declared_arg_suffixes
declare -A _orb_declared_vars
declare -A _orb_declared_requireds
declare -A _orb_declared_comments
declare -A _orb_declared_multiples
declare -A _orb_declared_default_evals

# Separate normal array stores to maintain word separation
# Tracked by index and length
declare -a _orb_declared_defaults
declare -A _orb_declared_defaults_start_indexes
declare -A _orb_declared_defaults_lengths

declare -a _orb_declared_ins
declare -A _orb_declared_ins_start_indexes
declare -A _orb_declared_ins_lengths

declare -a _orb_declared_catchs
declare -A _orb_declared_catchs_start_indexes
declare -A _orb_declared_catchs_lengths
