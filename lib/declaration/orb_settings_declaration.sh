_orb_settings_declaration=(
  --help = _orb_setting_help
    : 'show help'
  -e 1 = _orb_setting_extensions
    : 'additional orb extension folders'
    Catch: multiple
  -d = _orb_setting_direct_call
    : 'direct function call'
  -r = _orb_setting_reload_functions
    : 'restore function declarations after call'
)
