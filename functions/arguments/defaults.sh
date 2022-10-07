_orb_set_function_arg_default_values() {
  local _orb_default

  local _orb_arg; for _orb_arg in "${_orb_declared_args[@]}"; do
    if ! _orb_has_arg_value $_orb_arg && _orb_get_arg_option_value $_orb_arg "Default:" _orb_default; then
      _orb_assign_arg_value $_orb_arg "${_orb_default[@]}"
    fi
  done
}

# TODO default_evals
