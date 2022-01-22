# orb_raise_error
declare -A orb_raise_error_args=(
  ['1']='error_message;'
  ['-d arg']='descriptor; DEFAULT: $_orb_caller_function_descriptor|$_orb_function_descriptor;'
  ['-k']='kill script instead of exit; DEFAULT: true'
  ['-t']='trace; DEFAULT: true'
); function orb_raise_error() { # raise pretty error msg and kills execution
  source orb

  local _cmd=()
  orb_pass -a _cmd orb_print_error -- -d 1 # not using -x as would change caller_info
  "${_cmd[@]}"
  ${_args[-t]} && orb_print_stack_trace >&2
  if ${_args[-k]}; then 
    orb_kill_script 
  else
    exit 1
  fi
}


# orb_print_error
declare -A orb_print_error_args=(
	['1']='message; CATCH_ANY;'
  ['-d arg']='descriptor; DEFAULT: $_orb_caller_function_descriptor|$_orb_function_descriptor'
); function orb_print_error() { # print pretty error
  source orb

	msg=(
    "$(orb_red)$(orb_bold)Error:$(orb_normal)"
    "${_args[-d arg]}"
    "${_args[1]}"
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
    echo -e "$_file_name:$_line_no\t$_orb_function"
  done
}
