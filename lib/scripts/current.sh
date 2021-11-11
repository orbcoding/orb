local _namespaces=( core )

if [[ "${#_orb_extensions[@]}" != 0 ]]; then
  _collect_namespace_extensions
fi

local _current_namespace; _current_namespace=$(_get_current_namespace "$@") && shift
local _function_name; _function_name="$(_get_function_name "$@")" && shift
local _function_descriptor=$(_get_function_descriptor $_function_name $_current_namespace)

local _namespace_files=() # namespace files collector
local _namespace_files_dir_tracker # index with directory

local _namespace_help_requested=false
declare -A _namespace_options=(
  ['--help']='show help'
)

if _is_flag "$_function_name"; then
  if [[ $_function_name == '--help' ]]; then
    _namespace_help_requested=true
  else
    _raise_error "invalid option\n"
  fi
fi

# No more arguments required if requesting help
${_orb_options[--help]} || $_namespace_help_requested && return

if [[ -z $_function_name ]]; then
  _raise_error +t "is a namespace, no command or function provided\n\n Add --help for list of functions"
fi

# declare args declaration and raise if fails
if ! declare -n _args_declaration=${_function_name}_args 2> /dev/null; then
  _raise_error "not a valid option or function name"
fi

declare -A _args # args collector
local _args_nrs=() # 1, 2, 3...
local _args_wildcard=() # *
local _args_dash_wildcard=() # -- *

# declare block arrays
local _blocks=($(_declared_blocks))
local _block; for _block in "${_blocks[@]}"; do
  declare -a "$(_block_to_arr_name "$_block")"
done
