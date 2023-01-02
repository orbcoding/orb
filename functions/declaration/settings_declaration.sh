_orb_settings_declaration=(
  --help = _orb_setting_help
    "Show help"
  -n = _orb_setting_list_namespaces
    "List available namespaces"
  -e 1 = _orb_setting_extensions
    "Additional orb extension folders"
    Multiple: true
  -r = _orb_setting_raw_args
    "Pass raw input arguments to called function"
    Default: true
  --restore-fns = _orb_setting_restore_functions
    "Restore functions after call, as declared before sourcing function files."
)
