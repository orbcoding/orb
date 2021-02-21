local _namespaces=( core )
! $_core_files_only && [[ "${#_orb_extensions[@]}" != 0 ]] && _collect_orb_extensions
local _current_namespace; _current_namespace=$(_get_current_namespace "$@") && shift
local _function_name=$1; shift
local _function_descriptor=$(_get_function_descriptor)
local _namespace_dir="$_orb_dir/namespaces/$_current_namespace"
local _namespace_files=() # namespace files collector

! $_core_files_only && local _current_namespace_extension_file=$(_get_current_namespace_extension)

local _namespace_help_requested=false
declare -A _namespace_options=(
  ['--help']='show help'
)

if _is_flag "$_function_name"; then
  if [[ $_function_name == '--help' ]]; then
    _namespace_help_requested=true
  else
    orb core _raise_error "invalid option\n"
  fi
fi


if ! $_global_help_requested && ! $_namespace_help_requested; then
  [[ -z $_function_name ]] && orb core _raise_error "is a namespace, no command or function provided\n Add --help for list of functions"

  if ! declare -n _args_declaration=${_function_name}_args 2> /dev/null; then
    orb core _raise_error "not a valid option or function name"
  fi

  declare -A _args # args collector
  local _args_nrs=() # 1, 2, 3...
  local _args_wildcard=() # *
fi
