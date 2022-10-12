# Source file if has public function
local _orb_file; for _orb_file in ${_orb_namespace_files[@]}; do
  if orb_has_public_function "$_orb_function_name" "$_orb_file"; then
    local _orb_file_with_function="$_orb_file"
    source "$_orb_root/scripts/call/source_presource.sh"
    source "$_orb_file"
    break
  fi
done

orb_function_declared $_orb_function_name || _orb_raise_error "undefined"
