_orb_get_orb_namespace() {
	if ${_orb_settings['call']}; then
		local _namespace; _namespace="$(_orb_get_orb_namespace_from_args "$@")"
		local _status=$?
		echo $_namespace && return $_status
	else
		echo "$(_orb_get_orb_namespace_from_sourcer)"
		return 1 # no shift
	fi
}

_orb_get_orb_function() {
	if ${_orb_settings['call']}; then
		echo "$1"
	else
		echo "$(_orb_get_orb_function_from_sourcer)"
		return 1
	fi
}

_orb_get_orb_namespace_from_args() {
	if [[ " ${_orb_namespaces[@]} " =~ " ${1} " ]]; then
		echo "$1"
	elif [[ -n $ORB_DEFAULT_NAMESPACE ]]; then
		echo "$ORB_DEFAULT_NAMESPACE"
		return 1
	elif ! ${_orb_settings[--help]}; then
		_raise_error +t -d "$(_bold)${1-\"\"}$(_normal)" "not a valid namespace and \$ORB_DEFAULT_NAMESPACE not set. \n\n  Available namespaces: ${_orb_namespaces[*]}"
	fi
}

_orb_get_orb_namespace_from_sourcer() {
  local _set_namespacer="$(_orb_get_current_sourcer_file)"
  local _set_namespacer_dir="$(dirname $_set_namespacer)"
  
  if [[ "$(basename "$_set_namespacer_dir")" != namespaces ]]; then
    _set_namespacer="$(dirname $_set_namespacer)"
    _set_namespacer_dir="$(dirname "$_set_namespacer_dir")"
  fi

  if [[ "$(basename "$_set_namespacer_dir")" == namespaces ]]; then
    echo "$(basename "$_set_namespacer")"
  fi
}

_orb_get_current_sourcer_file() {
	local _i=1
	local _f; for _f in "${BASH_SOURCE[@]}"; do
		if [[ $_f == "$_orb_dir/bin/orb" ]]; then
			echo "${BASH_SOURCE[$_i]}" 
			return 0
		fi
		(( _i++ ))
	done
}

_orb_get_orb_function_from_sourcer() {
	local _i=1
	local _fn; for _fn in "${FUNCNAME[@]}"; do
		if [[ $_fn == "source" ]]; then
			echo "${FUNCNAME[$(($_i + 2))]}" && return
		fi
		(( _i++ ))
	done
}

_orb_get_orb_function_descriptor() { # $1 = $_orb_function $2 = $_orb_namespace
	if [[ -n $1 ]]; then
		echo "$2->$(_bold)${1}$(_normal)"
	else
		echo "$(_bold)$2$(_normal)"
	fi
}
