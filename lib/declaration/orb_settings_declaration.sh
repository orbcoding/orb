_orb_settings_declaration=(
  --help = _orb_setting_help
    "Show help"
  -e 1 = _orb_setting_extensions
    "Additional orb extension folders"
    Catch: multiple
  -d = _orb_setting_direct_call
    "Direct function call"
  -r = _orb_setting_reload_functions
    "Restore function declarations after call"
)
