_orb_collect_namespaces
_orb_get_current_namespace "$@" && shift
_orb_get_current_function "$@" && shift
_orb_get_current_function_descriptor $_orb_function_name $_orb_namespace

if [[ -z $_orb_function_name ]]; then
  if ! $_orb_setting_help; then
    _orb_raise_error "is a namespace, no command or function provided\n\n Use \`orb --help $_orb_namespace\` for list of functions"
  fi
else
  declare -n _orb_function_declaration="${_orb_function_name}_orb"
fi

_orb_collect_namespace_files


