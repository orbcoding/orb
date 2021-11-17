_orb_collect_orb_extensions() {
  # Start collecting in order of priority
  _upfind_to_arr _orb_extensions "_orb_extension&.orb_extension"
  [[ -d ~/.orb-cli ]] && _orb_extensions+=( ~/.orb-cli )
}

_orb_collect_namespace_extensions() {
  local _extension; for _extension in "${_orb_extensions[@]}"; do

    local _file; for _file in $(ls "$_extension/namespaces"); do
      local _orb_namespace=$(basename $_file)

      if [[ ! " ${_orb_namespaces[@]} " =~ " ${_namespace} " ]]; then
        _orb_namespaces+=( "${_namespace/\.*/}" )
      fi
    done
  done
}

_orb_parse_env_extensions() {
  local _ext; for _ext in ${_orb_extensions[@]}; do
    if [[ -f $_ext/.env ]]; then
      _parse_env $_ext/.env
    fi
  done
}

_orb_collect_orb_namespace_files() {
	local _orb_config_dirs=( $_orb_dir )

	_orb_config_dirs+=( "${_orb_extensions[@]}" )
	local _conf_dir

 	for _conf_dir in "${_orb_config_dirs[@]}"; do
	 	# TODO loop through multiple namespaces directories
	 	local _files _dir="$_conf_dir/namespaces/$_orb_namespace"

		if [[ -d "$_dir" ]]; then
			readarray -d '' _files < <(find $_dir -type f -name "*.sh" ! -name '_*' -print0 | sort -z)

			local _from=${#_orb_namespace_files[@]}
			local _to=$(( ${#_orb_namespace_files[@]} + ${#_files[@]} - 1 ))
			local _i; for _i in $(seq $_from $_to ); do
				_orb_namespace_files_dir_tracker[$_i]="$_conf_dir"
			done

			_orb_namespace_files+=( "${_files[@]}" )

		elif [[ -f "${_dir}.sh" ]]; then
			_orb_namespace_files_dir_tracker[${#_orb_namespace_files[@]}]="$_conf_dir"
			_orb_namespace_files+=( "${_dir}.sh" )
		fi
	done
}
