# orb_raise_error
orb_raise_error_orb=(
  1 = error_message "Error message"
  2 = descriptor 
    DefaultHelp: '$_orb_caller_function_descriptor || $_orb_function_descriptor'
  # -k = kill_script "Kill script instead of exit, even if subshell"
  #   Default: true
  # -t = trace "show stack trace"
  #   Default: true
) 
function orb_raise_error() { # raise pretty error msg and kills execution
  orb_eval_variable_or_string 
  # source orb
  # echo "$@"
  # echo $trace
  orb_print_error "$1" "$2"
  exit
  # orb_pass -a _cmd orb_print_error -- -d 1 # not using -x as would change caller_info
  # "${_cmd[@]}"
  # $trace && orb_print_stack_trace >&2
  # $kill_script && orb_kill_script || exit 1
}


# orb_print_error
orb_print_error_orb=(
  "Print pretty error"

  1 = message "Error message"
    Catch: flag block dash
  2 = descriptor "Error descriptor"
)
    # Default: '$_orb_caller_function_descriptor|$_orb_function_descriptor'
function orb_print_error() { # 
  # source orb

	msg=(
    "$(orb_red)$(orb_bold)Error:$(orb_normal)"
    "$2"
    "$1"
  )

	echo -e "${msg[*]}" >&2
};

# orb_kill_script
# https://stackoverflow.com/a/14152313
function orb_kill_script() { # kill script
  kill -PIPE 0
}

# orb_print_stack_trace
function orb_print_stack_trace() {
  local _i=0
  local _line_no
  local _orb_function
  local _file_name
  echo
  while caller $_i; do ((_i++)); done | while read _line_no _orb_function _file_name; do
    echo -e "$_file_name:$_line_no\t$_orb_function_name"
  done
}
