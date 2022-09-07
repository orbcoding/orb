_orb_collect_namespaces
_orb_namespace="$(_orb_get_current_namespace "$@")" && shift
_orb_function_name="$(_orb_get_current_function "$@")" && shift
_orb_function_descriptor="$(_orb_get_current_function_descriptor $_orb_function_name $_orb_namespace)"

if [[ -z $_orb_function_name ]]; then
  # No more arguments required if requesting help
  $_orb_setting_help && return
  orb_raise_error +t "is a namespace, no command or function provided\n\n Add --help for list of functions"
fi

unset _orb_function_declaration # to clear out listed in variables
declare -n _orb_function_declaration="${_orb_function_name}_orb"
# # declare args declaration and raise if fails
# if ! declare -n _orb_function_declaration=${_orb_function_name}_orb 2> /dev/null; then
#   orb_raise_error "not a valid option or function name"
# fi

# declare -A _args # args collector
# local _args_nrs=() # 1, 2, 3...
# local _orb_rest=() # *
# local _orb_dash_rest=() # -- *
# declare block arrays
# local _orb_blocks=($(_orb_has_declared_args))
# local _orb_block; for _orb_block in "${_orb_blocks[@]}"; do
#   declare -a "$(_orb_block_to_arr_name "$_orb_block")"
# done

_orb_collect_namespace_files


