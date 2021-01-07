function orb() {
	init_hook=$(cat << EOF
parent_script_name=$script_name
parent_function_name=$function_name
	\n
EOF
)

	arrs_to_copy=( args args_wildcard )

	for arr in ${arrs_to_copy[@]}; do
		[[ ! -v $arr[@] ]] && continue
		declare -n arr_ref=$arr
		init_hook+="declare -A parent_$arr\n"
		for key in "${!arr_ref[@]}"; do
			init_hook+="parent_$arr[\"$key\"]=\"${arr_ref[$key]}\"\n"
		done
	done


	init_hook="$init_hook" $(which orb) "$@"
}
