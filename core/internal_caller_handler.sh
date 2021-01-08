vars_to_caller=( script_name function_name )

for var in ${vars_to_caller[@]}; do
  [[ -v "$var" ]] && declare "caller_${var}"="${!var}"
done

arrs_to_caller=( args args_wildcard )

for arr in ${arrs_to_caller[@]}; do
  declare -n arr_ref=$arr
  declare -A caller_$arr
  [[ ! -v "$arr[@]" ]] && continue
  declare -n caller_ref=caller_$arr
  for key in "${!arr_ref[@]}"; do
    caller_ref["$key"]=${arr_ref["$key"]}
  done
done
