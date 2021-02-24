_collect_orb_extensions() {
  # Start collecting in order of priority
  _upfind_to_arr _orb_extensions "_orb_extension&.orb_extension"
  [[ -d ~/.orb-cli ]] && _orb_extensions+=( ~/.orb-cli )
}

_collect_namespace_extensions() {
  local _extension; for _extension in "${_orb_extensions[@]}"; do

    local _file; for _file in $(ls "$_extension/namespaces"); do
      _namespace=$(basename $_file)

      if [[ ! " ${_namespaces[@]} " =~ " ${_namespace} " ]]; then
        _namespaces+=( "${_namespace/\.*/}" )
      fi
    done
  done
}

_parse_env_extensions() {
  local _ext; for _ext in ${_orb_extensions[@]}; do
    if [[ -f $_ext/.env ]]; then
      _parse_env $_ext/.env
    fi
  done
}
