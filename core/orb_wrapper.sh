function orb() {
	caller_info=$(cat << EOF
caller_script_name=$script_name
caller_function_name=$function_name
	\n
EOF
)

	arrs_to_copy=( args args_wildcard )

	for arr in ${arrs_to_copy[@]}; do
		[[ ! -v $arr[@] ]] && continue
		declare -n arr_ref=$arr
		caller_info+="declare -A caller_$arr\n"
		for key in "${!arr_ref[@]}"; do
			caller_info+="caller_$arr[\"$key\"]=\"${arr_ref[$key]}\"\n"
		done
	done


	caller_info="$caller_info" $(which orb) "$@"
}
