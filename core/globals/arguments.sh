# Name ref to function defined args (from string variable)
declare -n args_declaration=${function_name}_args

# non-flagged args_nrs $1, $2... (* appended) will be passed forward so
# $1 == ${args[1]} (unless [1] optional and fail validation so cought by wildcard instead)
args_nrs=()
# if mixing numbered and wildcard input, this variable can be used to distinguish them
# args[*] only holds boolean as nested arrays not supported and string list wont preserve indexes
args_wildcard=()
declare -A args # all args

args_explanation="$(_print_args_explanation)"
