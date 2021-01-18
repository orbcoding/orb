_script_name=$(_get_script_name "$@") && shift
_script_dir="$_orb_dir/scripts/$_script_name"
_function_name=$1; shift
_script_function_path=$(_get_script_function_path)
declare -n _args_declaration=${_function_name}_args
declare -A _args # args collector
_args_nrs=() # 1, 2, 3...
_args_wildcard=() # *
_args_explanation="$(_print_args_explanation)"
