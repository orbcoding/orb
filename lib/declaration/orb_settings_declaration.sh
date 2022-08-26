_orb_settings_declaration=(
  --help = _orb_settings_help
    : 'show help'
  -e 1 = _orb_settings_extensions
    : 'additional orb extension folders'
    Catch: multiple
  -d = _orb_settings_direct_call
    : 'direct function call'
  -r = _orb_settings_reload_functions
    : 'restore function declarations after call'
)
