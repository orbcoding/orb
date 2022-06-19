_orb_collect_orb_extensions() { # $1 = start path, $2 = stop path
  # Start collecting in order of priority
  orb_upfind_to_arr _orb_extensions "_orb&.orb" $1 $2
  if [[ -d ~/.orb ]] && ! [[ ${_orb_extensions[@]} =~ "~/.orb" ]]; then
		 _orb_extensions+=( ~/.orb )
	fi
}

_orb_collect_namespace_extensions() {
  local _extension; for _extension in "${_orb_extensions[@]}"; do

    local _file; for _file in $(ls "$_extension/namespaces"); do
      local _orb_namespace=$(basename $_file)

      if [[ ! " ${_orb_namespaces[@]} " =~ " ${_orb_namespace} " ]]; then
        _orb_namespaces+=( "${_orb_namespace/\.*/}" )
      fi
    done
  done
}

_orb_parse_env_extensions() {
  local _ext; for _ext in ${_orb_extensions[@]}; do
    if [[ -f $_ext/.env ]]; then
      orb_parse_env $_ext/.env
    fi
  done
}

_orb_collect_orb_namespace_files() {
	# local _orb_config_dirs=( $_orb_dir )

	# _orb_config_dirs+=( "${_orb_extensions[@]}" )
	# local _conf_dir

 	for _ext in "${_orb_extensions[@]}"; do
	 	# TODO loop through multiple namespaces directories
	 	local _files _dir="$_ext/namespaces/$_orb_namespace"

		if [[ -d "$_dir" ]]; then
			readarray -d '' _files < <(find $_dir -type f -name "*.sh" ! -name '_*' -print0 | sort -z)

			local _from=${#_orb_namespace_files[@]}
			local _to=$(( ${#_orb_namespace_files[@]} + ${#_files[@]} - 1 ))
			local _i; for _i in $(seq $_from $_to ); do
				_orb_namespace_files_dir_tracker[$_i]="$_ext"
			done

			_orb_namespace_files+=( "${_files[@]}" )

		elif [[ -f "${_dir}.sh" ]]; then
			_orb_namespace_files_dir_tracker[${#_orb_namespace_files[@]}]="$_ext"
			_orb_namespace_files+=( "${_dir}.sh" )
		fi
	done
}
