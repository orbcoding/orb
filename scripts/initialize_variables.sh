# Static initialized once
declare -ga _orb_available_function_options=( DirectCall: )
declare -ga _orb_available_function_option_direct_call_values=( true false )

declare -ga _orb_available_arg_options=( Required: Default: In: Catch: Multiple: DefaultHelp: )
# Skip DefaultHelp as will be checked for default
declare -ga _orb_available_arg_options_help=( Required: Default: In: Catch: Multiple: )

declare -ga _orb_available_arg_options_number_arg=( Required: Default: DefaultHelp: In: )
declare -ga _orb_available_arg_options_boolean_flag=( Required: Default: DefaultHelp: )
declare -ga _orb_available_arg_options_flag_arg=( Required: Default: DefaultHelp: Multiple: In: )
# flag args with suffix > 1 
declare -ga _orb_available_arg_options_array_flag_arg=( Required: Default: DefaultHelp: Multiple: )
declare -ga _orb_available_arg_options_block=( Required: Default: DefaultHelp: Multiple: )
declare -ga _orb_available_arg_options_dash=( Required: Default: DefaultHelp: )
declare -ga _orb_available_arg_options_rest=( Required: Default: DefaultHelp: Catch: )

declare -ga _orb_available_arg_option_catch_values=( any flag block dash )
declare -ga _orb_available_arg_option_required_values=( true false )
declare -ga _orb_available_arg_option_multiple_values=( true false )

declare -g _orb_history_max_length=3

declare -ga _orb_history_variables=(
  _orb_namespace
  _orb_function_name
  _orb_function_descriptor
  _orb_function_exit_code

  _orb_args_positional
  _orb_args_values
  _orb_args_values_start_indexes
  _orb_args_values_lengths

  _orb_declared_direct_call

  _orb_declared_args
  _orb_declared_arg_suffixes
  _orb_declared_vars
  _orb_declared_comments

  _orb_declared_option_values
  _orb_declared_option_start_indexes
  _orb_declared_option_lengths
)
