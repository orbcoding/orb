_orb_collect_namespace_files() {
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


_orb_collect_namespaces() {
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

# Return success => shift away namespace argument from positional args
_orb_get_current_namespace() {
	if $_orb_sourced; then
		echo "$(_orb_get_current_namespace_from_file_structure)"
		return 2 # no shift
	else
		local namespace; namespace="$(_orb_get_current_namespace_from_args "$@")"
		local status=$?
		echo $namespace && return $status
	fi
}

_orb_get_current_namespace_from_args() {
	if [[ " ${_orb_namespaces[@]} " =~ " ${1} " ]]; then
		echo "$1"
	elif [[ -n $ORB_DEFAULT_NAMESPACE ]]; then
		echo "$ORB_DEFAULT_NAMESPACE"
		return 2
	elif ! $_orb_setting_help; then
		orb_raise_error +t -d "$(orb_bold)${1-\"\"}$(orb_normal)" "not a valid namespace and \$ORB_DEFAULT_NAMESPACE not set. \n\n  Available namespaces: ${_orb_namespaces[*]}"
	fi
}

_orb_get_current_namespace_from_file_structure() {
  local _set_namespacer="$(_orb_get_current_sourcer_file_path)"
  local _set_namespacer_dir="$(dirname $_set_namespacer)"
  
  if [[ "$(basename "$_set_namespacer_dir")" != namespaces ]]; then
    _set_namespacer="$(dirname $_set_namespacer)"
    _set_namespacer_dir="$(dirname "$_set_namespacer_dir")"
  fi

  if [[ "$(basename "$_set_namespacer_dir")" == namespaces ]]; then
    echo "$(basename "${_set_namespacer%.*}")"
	else
		return 1
  fi
}

# Return success => shift away function_name argument from positional args
_orb_get_current_function() {
	if $_orb_sourced; then
		echo "$(_orb_get_current_function_from_source_chain)"
		return 2
	else
		echo "$1"
	fi
}

_orb_get_current_sourcer_file_path() {
	local _i=1
	local _f; for _f in "${_orb_source_trace[@]}"; do
		if [[ $_f == "$_orb_root/bin/orb" ]]; then
			echo "${_orb_source_trace[$_i]}" 
			return 0
		fi
		(( _i++ ))
	done
}

_orb_get_current_function_from_source_chain() {
	local _i=1
	local _fn; for _fn in "${_orb_function_trace[@]}"; do
		if [[ $_fn == "source" ]]; then
			echo "${_orb_function_trace[$(($_i + 2))]}" && return
		fi
		(( _i++ ))
	done
}

_orb_get_current_function_descriptor() { # $1 = $_orb_function_name $2 = $_orb_namespace
	if [[ -n $2 ]]; then
		echo "$2->$(orb_bold)${1}$(orb_normal)"
	else
		echo "$(orb_bold)$1$(orb_normal)"
	fi
}

# _orb_runtime_shell() {
# 	# https://unix.stackexchange.com/a/72475
# 	# Determine what (Bourne compatible) shell we are running under.
# 	:
# 	# local shell=sh


# 	# if test -n "$ZSH_VERSION"; then
# 	# 	shell=zsh
# 	# elif test -n "$BASH_VERSION"; then
# 	# 	shell=bash
# 	# elif test -n "$KSH_VERSION" || test -n "$FCEDIT"; then
# 	# 	shell=ksh
# 	# elif test -n "$PS3"; then
# 	# 	shell=unknown
# 	# fi

# }
