_orb_has_orb_settings_arguments "$@" || return 0
_orb_parse_declaration _orb_settings_declaration
_orb_extract_orb_settings_arguments _orb_settings_args "$@"
_orb_parse_args ${_orb_settings_args[@]}

# Reset variables
source "$_orb_dir/lib/scripts/call/variables.sh"
return ${#_orb_settings_args[@]}
