_collect_orb_extensions() {
	_collect_user_extension
	_collect_local_extensions
	local _namespace_files=( $_orb_extension/namespaces/* )

	local _file; for _file in ${_namespace_files}; do
		_namespace=$(basename $_file)
		_namespaces+=( ${_namespace/.*/} )
	done
}

_collect_user_extension() {
  if [[ -d ~/.orb-cli ]]; then
    _orb_extensions+=( ~/.orb-cli )
	fi
  # if [[ -d ~/.orb-cli/namespaces ]]; then
	# 	readarray -d '' _user_namespace_extensions < <(find ~/.orb-cli/namespaces/* -maxdepth 1 -type d -print0)
	# fi
}

_collect_local_extensions() {
	local _orb_extension _path
	while true; do
		if [[ ${#_orb_extensions[@]} != 0 ]]; then
			local _parent=$(dirname ${_orb_extensions[-1]})
			# break if last found was in root
			[[ $_parent == '/' ]] && break || _path=$(dirname $_parent)
		else
			_path="$PWD"
		fi

		if _orb_extension="$(_find_closest _orb_extension "$_path")"; then
    _echoerr 'found'
			_orb_extensions+=( "$_orb_extension" )
		else
    _echoerr 'nofound'
			break # no extensions found
		fi
	done
}

_parse_env_extensions() {
	if [[ -f ~/.orb-cli/.env ]]; then
		_parse_env ~/.orb-cli/.env
	fi
}
