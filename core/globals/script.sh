_script_name=$(_get_script_name "$@") && shift
_function_name=$1; shift
_function_descriptor=$(_get_function_descriptor)
_script_dir="$_orb_dir/scripts/$_script_name"
_script_files=() # script files collector
! $_core_files_only && _current_script_extension_file=$(_get_current_script_extension_file)
declare -n _args_declaration=${_function_name}_args
declare -A _args # args collector
_args_nrs=() # 1, 2, 3...
_args_wildcard=() # *
# _args_explanation="$(_print_args_explanation)"
