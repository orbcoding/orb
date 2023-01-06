_orb_set_default_arg_values() {
  local arg; for arg in "${_orb_declared_args[@]}"; do
    _orb_has_arg_value $arg || _orb_set_default_from_declaration $arg
  done
}

_orb_set_default_from_declaration() {
  local default; _orb_get_arg_option_value $arg "Default:" default || return 1
  _orb_store_arg_value $arg "${default[@]}"
}
