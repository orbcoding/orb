# Source file if has public function
local _file; for _file in ${_orb_namespace_files[@]}; do
  if orb_has_public_function "$_orb_function_name" "$_file"; then
    local _file_with_function="$_file"
    source "$_file"
    break
  fi
done

orb_function_declared $_orb_function_name || orb_raise_error "undefined"
