# 'source orb' can be called in the following contexts:
#
# 1. To initialize and load the orb function into the current shell.
#
#   When you call orb in a terminal or script, the orb script will be executed in a bash subshell.
#   This means your orb function cannot modify the environment in the calling scope.
#   This behavior also what makes it possible to call bash scripts in other shells such as zsh.
#   Once the script is initialized however, the 'orb' function is declared to replace the orb script.
#   Any nested orb calls will then invoke the 'orb' function, which does not create a subshell.
#   So once the 'orb' function is defined, orb functions can interact with the caller's environment.
#   
#   But if you are already in a bash environment, 
#   You can source the orb script to load the orb function into the current shell.
#   Once initialized, all your orb calls will run in the same shell,
#   Enabeling you to set variables and interact with your environment. 
#   It also prevents the need of reinitializing orb in its own subshell for each call 
#    
# 2. From within any bash function to ensure it is orb handled, even if called without orb prefix.
#
#   Example script: 

#   #!/bin/bash
#   direct_call_orb=(
#    1 = first
#    -f = flag 
#   ) 
#   direct_call() {
#     source orb
#     echo $first $flag
#   }
#
#   direct_call hello -f
#   #> hello true
  
#   Sourcing orb in this was prefered over calling any type of function
#   as it allows for directly setting local variables in the sourcers scope.
#  
#   An eval statement could also have been used but is not as concise. 
#
if [[ $_orb_sourced == true ]]; then
  if [[ -z ${_orb_function_trace[@]} ]] || ( 
     [[ ${_orb_function_trace[0]} == "source" ]] &&
     [[ ${_orb_function_trace[2]} == "orb" ]]
    ); then
    # Do nothing if orb was sourced for initialization outside the context of a function.
    # Or if sourced in a function that was already called through orb
    # If so the arguments would have already been handled
    unset _orb_sourced && return 0
  fi
else
  # Return false to proceed with normal call
  return 1
fi

_orb_sourced_in_fn=true

source "$_orb_root/scripts/call/history.sh"
source "$_orb_root/scripts/call/variables.sh"
source "$_orb_root/scripts/call/namespace_and_function.sh"
source "$_orb_root/scripts/call/source_presource.sh"

_orb_parse_function_declaration

source "$_orb_root/scripts/call/function_args.sh"
set -- "${_orb_args_positional[@]}"

unset _orb_sourced_in_fn

return 0
