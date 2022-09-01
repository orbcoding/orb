_orb_collect_orb_extensions() { # $1 = start path, $2 = stop path
  # Start collecting in order of priority
  orb_upfind_to_arr "_orb_extensions" "_orb&.orb" $1 $2

	if [[ -d "$HOME/.orb" ]] && ! [[ " ${_orb_extensions[@]} " =~ "$HOME/.orb" ]]; then 
		_orb_extensions+=( "$HOME/.orb" )
	fi

	orb_trim_uniq_realpaths "_orb_extensions" "_orb_extensions" 
}

_orb_collect_namespace_extensions() {
  local ext; for ext in "${_orb_extensions[@]}"; do

    local file; for file in $(ls "$ext/namespaces"); do
      local namespace=$(basename $file)
			namespace="${namespace/\.*/}"

      if [[ ! " ${_orb_namespaces[@]} " =~ " $namespace " ]]; then
        _orb_namespaces+=( $namespace )
      fi
    done
  done
}

_orb_parse_env_extensions() {
  local ext; for ext in ${_orb_extensions[@]}; do
    if [[ -f "$ext/.env" ]]; then
      orb_parse_env "$ext/.env"
    fi
  done
}

_orb_collect_namespace_files() {
	# local _orb_config_dirs=( $_orb_dir )

	# _orb_config_dirs+=( "${_orb_extensions[@]}" )
	# local _conf_dir

 	local ext; for ext in "${_orb_extensions[@]}"; do
	 	# TODO loop through multiple namespaces directories
		local dir="$ext/namespaces/$_orb_namespace"

		if [[ -d "$dir" ]]; then
	 		local files 
			readarray -d '' files < <(find $dir -type f -name "*.sh" ! -name '_*' -print0 | sort -z)

			local from=${#_orb_namespace_files[@]}
			local to=$(( ${#_orb_namespace_files[@]} + ${#files[@]} - 1 ))

			local i; for i in $(seq $from $to ); do
				_orb_namespace_files_orb_dir_tracker[$i]="$ext"
			done

			_orb_namespace_files+=( "${files[@]}" )

		elif [[ -f "${dir}.sh" ]]; then
			_orb_namespace_files_orb_dir_tracker[${#_orb_namespace_files[@]}]="$ext"
			_orb_namespace_files+=( "${dir}.sh" )
		fi
	done
}
