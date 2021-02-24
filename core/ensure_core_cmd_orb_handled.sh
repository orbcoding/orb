# Fix core function not being called with orb prefix
# This is primarily used to avoid the need for constant "orb namespace" prefixing
# for commonly used orb functions which require orb arguments parsing.
# Such as _raise_error _args_to etc.
#
# OBS! Sourcing this file does not update function input arguments.
# So you have to use ${_args[1]} instead of $1 etc.
# To fix it use: set -- "${_args_nrs[@]}" "${_args_wildcard[@]}" after sourcing
#
# Another solution is to run the following instead of sourcing this file
# if ! _got_orb_prefix; then orb namespace $FUNCNAME "$@"; return; fi
# however this will create a longer stack trace
#
if ! _got_orb_prefix 1; then
  # Set globals
  source "$_orb_dir/core/globals/orb.sh"
  source "$_orb_dir/core/globals/caller.sh"
  source "$_orb_dir/core/globals/namespace.sh"

  # Source namespace _presource.sh in reverse (closest last)
  local _i; for (( _i=${#_orb_extensions[@]}-1 ; _i>=0 ; _i-- )); do
    local _ext="${_orb_extensions[$_i]}"
    if [[ -f "$_ext/namespaces/$_current_namespace/_presource.sh" ]]; then
      source "$_ext/namespaces/$_current_namespace/_presource.sh"
    fi
  done

  _parse_args "$@"
fi
