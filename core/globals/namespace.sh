_namespaces=( ${_core_namespaces[@]} )
! $_core_files_only && [[ -n "$_orb_extensions" ]] && _collect_namespace_extensions
_current_namespace=$(_get_current_namespace "$@") && shift
_function_name=$1; shift
_function_descriptor=$(_get_function_descriptor)
_namespace_dir="$_orb_dir/namespaces/$_current_namespace"
_namespace_files=() # namespace files collector

! $_core_files_only && _current_namespace_extension_file=$(_get_current_namespace_extension)

_namespace_help_requested=false
declare -A _namespace_options=(
  ['--help']='show help'
)

if _is_flag "$_function_name"; then
  if [[ $_function_name == '--help' ]]; then
    _namespace_help_requested=true
  else
    orb -c utils raise_error "invalid option\n"
  fi
fi


if ! $_global_help_requested && ! $_namespace_help_requested; then
  [[ -z $_function_name ]] && orb -c utils raise_error "is a namespace, no command or function provided\n Add --help for list of functions"

  if ! declare -n _args_declaration=${_function_name}_args 2> /dev/null; then
    orb -c utils raise_error "not a valid option or function name"
  fi

  declare -A _args # args collector
  _args_nrs=() # 1, 2, 3...
  _args_wildcard=() # *
fi
