_orb_get_function_trace() {
	declare -n assign_ref="$1"
	assign_ref=( "${FUNCNAME[@]}" )
}

_orb_get_source_trace() {
	declare -n assign_ref="$1"
	assign_ref=( "${BASH_SOURCE[@]}" )
}


_orb_is_sourced_by_unhandled_fn() {
	# Not sourced:        orb [3] fn [2] somefn [1] orb [0]
	# Sourced handled:    orb [3] fn [2] source [1] orb [0]
	# Sourced unhandled:  fn1 [3] fn [2] source [1] orb [0]
	[[ "${_orb_function_trace[1]}" == "source" ]] && 
	[[ "${_orb_function_trace[3]}" != "orb" ]]
}
