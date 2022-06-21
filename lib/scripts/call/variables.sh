# These and call/history.sh
# are the only variables that should
# be available in scope of called function
# rest of variables will be declared local inside
# lower level function calls

# Orb settings
local _orb_setting_global_help=false
local _orb_setting_namespace_help=false
local _orb_setting_direct_call=false
local _orb_setting_reload_functions=false
local _orb_setting_sourced=false

# Namespace info
local _orb_namespace
local _orb_function
local _orb_function_descriptor
local _orb_function_exit_code

# Extensions
local _orb_extensions=()
# local _orb_namespace_files=()
# local _orb_namespace_files_dirs=()

# Will be a nameref to function_name_orb declaration
declare -a _orb_function_declaration

declare -a _orb_declared_args # ordered
# Argument as key: eg: -f
# TODO might verbose _orb_declared_arg_vars etc
declare -A _orb_declared_vars
declare -A _orb_declared_suffixes
declare -A _orb_declared_requireds
declare -A _orb_declared_comments
# Separate normal array stores to maintain word separation
declare -a _orb_declared_defaults
declare -a _orb_declared_ins
# Tracked by index and length
declare -A _orb_declared_defaults_indexes
declare -A _orb_declared_defaults_lengths
declare -A _orb_declared_ins_indexes
declare -A _orb_declared_ins_lengths

# Call arguments and final argument values
declare -a _orb_args_positional # passed inline to called function
declare -a _orb_args_values # final arg values
# Argument as key: eg: -f
declare -A _orb_args_values_indexes
declare -A _orb_args_values_lengths


