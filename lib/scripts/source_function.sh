  # Source file if has public function
  local _file; for _file in ${_namespace_files[@]}; do
    if _has_public_function "$_function_name" "$_file"; then
      local _file_with_function="$_file"
      source "$_file"
      break
    fi
  done

  _function_declared $_function_name
