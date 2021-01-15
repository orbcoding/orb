vars_to_caller=(
  script_name
  function_name
  script_function_path
  args_explanation
)

for var in ${vars_to_caller[@]}; do
  [[ -v "$var" ]] && declare "orb_caller_${var}"="${!var}"
done

if [[ -n $orb_caller_script_name && -n $orb_caller_function_name ]]; then
  orb_caller_descriptor="$orb_caller_script_name->$(bold)$orb_caller_function_name$(normal)"
fi

arrs_to_caller=(
  args
  args_wildcard
  args_declaration
)

for arr in ${arrs_to_caller[@]}; do
  declare -n arr_ref=$arr
  declare -A orb_caller_$arr
  [[ ! -v "$arr[@]" ]] && continue
  declare -n orb_caller_ref=orb_caller_$arr
  for key in "${!arr_ref[@]}"; do
    orb_caller_ref["$key"]=${arr_ref["$key"]}
  done
done
