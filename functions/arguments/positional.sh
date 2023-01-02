_orb_set_function_positional_args() {
  local _orb_value _orb_nrs _orb_nr

  if $_orb_setting_raw_args || $_orb_declared_raw_args; then
    _orb_args_positional=("$@")
    return
  fi

  _orb_get_declared_number_args_in_order _orb_nrs

  for _orb_nr in ${_orb_nrs[@]}; do
    if _orb_has_arg_value $_orb_nr; then
      _orb_store_arg_value $_orb_nr _orb_value
      _orb_args_positional+=( "$_orb_value" )
    fi
  done

  if _orb_has_arg_value ...; then
    _orb_store_arg_value ... _orb_value
    _orb_args_positional+=( "${_orb_value[@]}" )
  fi
}

