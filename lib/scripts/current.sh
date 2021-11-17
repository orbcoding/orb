local _orb_namespaces=( core )

if [[ "${#_orb_extensions[@]}" != 0 ]]; then
  _orb_collect_namespace_extensions
fi

local _orb_namespace; _orb_namespace=$(_orb_get_orb_namespace "$@") && shift
local _orb_function; _orb_function="$(_orb_get_orb_function "$@")" && shift
local _orb_function_descriptor=$(_orb_get_orb_function_descriptor $_orb_function $_orb_namespace)

local _orb_namespace_files=() # namespace files collector
local _orb_namespace_files_dir_tracker # index with directory

declare -A _orb_namespace_settings=(
  ['--help']='false'
)

declare -A _orb_namespace_arguments=(
  ['--help']='show help'
)

if _is_flag "$_orb_function"; then
  if [[ $_orb_function == '--help' ]]; then
    _orb_namespace_settings['--help']=true
  else
    _raise_error "invalid option\n"
  fi
fi

# No more arguments required if requesting help
${_orb_settings[--help]} || ${_orb_namespace_settings['--help']} && return

if [[ -z $_orb_function ]]; then
  _raise_error +t "is a namespace, no command or function provided\n\n Add --help for list of functions"
fi

# declare args declaration and raise if fails
if ! declare -n _orb_args_declaration=${_orb_function}_args 2> /dev/null; then
  declare
  _raise_error "not a valid option or function name"
fi

declare -A _args # args collector
local _args_nrs=() # 1, 2, 3...
local _args_wildcard=() # *
local _args_dash_wildcard=() # -- *

# declare block arrays
local _orb_blocks=($(_orb_declared_blocks))
local _orb_block; for _orb_block in "${_orb_blocks[@]}"; do
  declare -a "$(_orb_block_to_arr_name "$_orb_block")"
done
