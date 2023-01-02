_orb_has_orb_settings_arguments "$@" || return 0
_orb_parse_function_declaration _orb_settings_declaration
_orb_extract_orb_settings_arguments _orb_settings_args "$@"
_orb_collect_function_args ${_orb_settings_args[@]}

# Add any collected extensions
if [[ -n "${_orb_setting_extensions[@]}" ]]; then
  _orb_extensions+=("${_orb_setting_extensions[@]}")
fi

# Store function dump if reload functions
$_orb_setting_restore_functions && local _orb_function_dump="$(declare -f)"

# Reset collection variables
source "$_orb_root/scripts/call/variables.sh" only_args_collection
