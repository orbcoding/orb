# Static initialized once
# Without -g they did not persist in sourcing shell scope
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
