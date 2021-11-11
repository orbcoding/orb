# 'source orb' from within any function to ensure it is orb handled, even if called without orb prefix. 
#
# Eg: instead of 'orb my_namespace my_function' you can now call 'my_function' directly
#
# Another solution is to run the following instead of sourcing this file
# if ! _got_orb_prefix; then orb my_namespace my_function; return; fi
#
# However this creates a longer stack trace and cant update local positional arguments
# This is why sourcing in this way was preferered over any type of function call
if ! _got_orb_prefix 2; then
  # Set globals
  source "$_orb_dir/lib/scripts/orb_options.sh"
  source "$_orb_dir/lib/scripts/caller.sh"
  source "$_orb_dir/lib/scripts/current.sh"

  # Source namespace _presource.sh in reverse (closest last)
  local _i; for (( _i=${#_orb_extensions[@]}-1 ; _i>=0 ; _i-- )); do
    local _ext="${_orb_extensions[$_i]}"
    if [[ -f "$_ext/namespaces/$_current_namespace/_presource.sh" ]]; then
      source "$_ext/namespaces/$_current_namespace/_presource.sh"
    fi
  done

  _parse_args "$@"
fi

set "${_args_positional[@]}"
