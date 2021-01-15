# List of useful global variables
# globals=(
#   # See orb
#   script_name
#   function_name
#   script_function_path

#   # See arguments_collector
#   args
#   args_wildcard
#   args_declaration
#   args_explanation

#   # See orb_caller_info
#   orb_caller_args
#   orb_caller_args_wildcard
#   orb_caller_args_declaration
#   orb_caller_args_explanation
# )


scripts=( orb git utils text )

if [[ " ${scripts[@]} " =~ " ${1} " ]]; then
  # Specified script tag
  script_name="$1"
  shift
else
  script_name=orb
fi

# First argument is function name
function_name=$1; shift
script_function_path="$script_name"
[[ -n $function_name ]] && script_function_path+="->$(bold)${function_name}$(normal)"

script_dir="$orb_dir/scripts/$script_name"

