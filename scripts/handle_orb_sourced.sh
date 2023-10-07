# call 'source $orb' from within any function to ensure it is orb handled, even if called without orb prefix. 
#
# Example: 
#
# my_script.sh
#
# declare -A my_function_args=(
#  [1]='first arg'
#  [-f]='flag' 
# ); function my_function() {
#   source $orb
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

if [[ "${_orb_source_trace[-1]}" != "$0" ]]; then
  # Do nothing if sourced eg from shell
  # https://nickjanetakis.com/blog/detect-if-a-shell-script-is-being-executed-or-sourced
  return 0
elif [[ ${_orb_function_trace[0]} != "source" ]]; then
  # Return false to proceed with normal call
  return 1
elif [[ ${_orb_function_trace[2]} == "orb" ]]; then
  # Do nothing if sourced when parent function already called through orb
  return 0
fi

_orb_sourced=true

source "$_orb_root/scripts/call/history.sh"
source "$_orb_root/scripts/call/variables.sh"
source "$_orb_root/scripts/call/namespace_and_function.sh"
source "$_orb_root/scripts/call/source_presource.sh"

_orb_parse_function_declaration

source "$_orb_root/scripts/call/function_args.sh"
set -- "${_orb_args_positional[@]}"

unset _orb_sourced

return 0
