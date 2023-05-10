# Static initialized once
declare -ga _orb_available_function_options=( Raw: )
declare -ga _orb_available_function_option_raw_values=( true false )

declare -ga _orb_available_arg_options=( Required: Default: In: Catch: Multiple: )
declare -ga _orb_available_arg_options_help=( Required: Default: In: Catch: Multiple: )

declare -ga _orb_available_arg_options_number_arg=( Required: Default: In: )
declare -ga _orb_available_arg_options_boolean_flag=( Required: Default: )
declare -ga _orb_available_arg_options_flag_arg=( Required: Default: Multiple: In: )
# flag args with suffix > 1 
declare -ga _orb_available_arg_options_array_flag_arg=( Required: Default: Multiple: )
declare -ga _orb_available_arg_options_block=( Required: Default: Multiple: )
declare -ga _orb_available_arg_options_dash=( Required: Default: )
declare -ga _orb_available_arg_options_rest=( Required: Default: Catch: )

declare -ga _orb_available_arg_option_catch_values=( any flag block dash )
declare -ga _orb_available_arg_option_required_values=( true false )
declare -ga _orb_available_arg_option_multiple_values=( true false )

declare -gA _orb_available_arg_nested_options=(
  [Default:]="IfPresent: Help:"
  # [Required:]="IfPresent: Help:"
)


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

  _orb_declared_raw

  _orb_declared_args
  _orb_declared_arg_suffixes
  _orb_declared_vars
  _orb_declared_comments

  _orb_declared_option_values
  _orb_declared_option_start_indexes
  _orb_declared_option_lengths
)
