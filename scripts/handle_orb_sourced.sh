# call 'source orb' from within any function to ensure it is orb handled, even if called without orb prefix. 
#
# Example: 
#
# my_script.sh
#
# declare -A my_function_args=(
#  [1]='first arg'
#  [-f]='flag' 
# ); function my_function() {
#   source orb
#   orb_print_args
# }
#
# instead of 'orb my_namespace my_function' you can now call 'my_function' directly
# $ my_script.sh my_function my_arg -f
#
# sourcing orb in this way was prefered over calling orb as a function
# as it makes it possible to set local variables in scope of calling function
# without having to write a more verbose and conditional nested orb prefixed call
# eg: # if ! _got_orb_prefix; then orb --call my_function "$@"; return; fi
# which couldve become something like =>: orb --call "$@" && return
# This would've also pollute stack trace when functions are called directly
# my_function => orb => my_function
#
[[ "${_orb_function_trace[1]}" != "source" ]] && return 1
# 'source orb' was called, which then sourced this file, hence both index 0 and 1 == source
if [[ "${_orb_function_trace[3]}" != "orb" ]]; then
  # index 2 is sourcer function, which was not orb prefixed if index 3 != orb"
  
  source "$_orb_dir/scripts/call/history.sh"
  source "$_orb_dir/scripts/call/variables.sh"
  _orb_setting_sourced=true
  source "$_orb_dir/scripts/call/preparation.sh"
  source "$_orb_dir/scripts/source/presource.sh"

  _orb_parse_function_declaration "${_orb_function_name}_orb"
  _orb_parse_function_args "$@"
  _orb_set_function_arg_default_values
  _orb_set_function_positional_args

  set "${_orb_args_positional[@]}"
fi
