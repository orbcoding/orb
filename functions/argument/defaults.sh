_orb_set_default_arg_values() {
  local _orb_arg; for _orb_arg in "${_orb_declared_args[@]}"; do
    _orb_has_arg_value $_orb_arg || _orb_set_default_from_declaration $_orb_arg
  done
}

_orb_set_default_from_declaration() {
  local _orb_default; _orb_get_arg_option_value $_orb_arg "Default:" _orb_default || return 1
  _orb_store_arg_value $_orb_arg "${_orb_default[@]}"
}
