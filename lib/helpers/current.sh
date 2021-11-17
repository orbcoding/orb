_get_current_namespace() {
	if ${_orb_settings['call']}; then
		local _namespace; _namespace="$(_get_current_namespace_from_args "$@")"
		local _status=$?
		echo $_namespace && return $_status
	else
		echo "$(_get_current_namespace_from_sourcer)"
		return 1 # no shift
	fi
}

_get_function_name() {
	if ${_orb_settings['call']}; then
		echo "$1"
	else
		echo "$(_get_function_name_from_sourcer)"
		return 1
	fi
}

_get_current_namespace_from_args() {
	if [[ " ${_namespaces[@]} " =~ " ${1} " ]]; then
		echo "$1"
	elif [[ -n $ORB_DEFAULT_NAMESPACE ]]; then
		echo "$ORB_DEFAULT_NAMESPACE"
		return 1
	elif ! ${_orb_settings[--help]}; then
		_raise_error +t -d "$(_bold)${1-\"\"}$(_normal)" "not a valid namespace and \$ORB_DEFAULT_NAMESPACE not set. \n\n  Available namespaces: ${_namespaces[*]}"
	fi
}

_get_current_namespace_from_sourcer() {
  local _set_namespacer="$(_get_current_sourcer_file)"
  local _set_namespacer_dir="$(dirname $_set_namespacer)"
  
  if [[ "$(basename "$_set_namespacer_dir")" != namespaces ]]; then
    _set_namespacer="$(dirname $_set_namespacer)"
    _set_namespacer_dir="$(dirname "$_set_namespacer_dir")"
  fi

  if [[ "$(basename "$_set_namespacer_dir")" == namespaces ]]; then
    echo "$(basename "$_set_namespacer")"
  fi
}

_get_current_sourcer_file() {
	local _i=1
	local _f; for _f in "${BASH_SOURCE[@]}"; do
		if [[ $_f == "$_orb_dir/bin/orb" ]]; then
			echo "${BASH_SOURCE[$_i]}" 
			return 0
		fi
		(( _i++ ))
	done
}

_get_function_name_from_sourcer() {
	local _i=1
	local _fn; for _fn in "${FUNCNAME[@]}"; do
		if [[ $_fn == "source" ]]; then
			echo "${FUNCNAME[$(($_i + 2))]}" && return
		fi
		(( _i++ ))
	done
}

_get_function_descriptor() { # $1 = $_function_name $2 = $_current_namespace
	if [[ -n $1 ]]; then
		echo "$2->$(_bold)${1}$(_normal)"
	else
		echo "$(_bold)$2$(_normal)"
	fi
}
