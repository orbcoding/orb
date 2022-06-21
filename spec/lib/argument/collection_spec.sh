Include lib/arguments/collection.sh

# Variables are local so have to be sourced inside function
variables_path=lib/scripts/call/variables.sh
pre_fn() { :; }
post_fn() { :; }
call_with_variables() { source $variables_path; pre_fn; "$@"; post_fn; }

Describe '_orb_parse_orb_prefixed_args'
  _orb_print_function_help() { echo_me; }
  _orb_parse_args() { echo_me; }

	It 'prints function help if 1 == --help'
    When run call_with_variables _orb_parse_orb_prefixed_args --help
    The output should equal _orb_print_function_help
  End

	It 'sets directly to positional args if _orb_settings_direct_call'
    pre_fn() { _orb_setting_direct_call=true; }
    post_fn() { echo ${_orb_args_positional[@]}; }
    When call call_with_variables _orb_parse_orb_prefixed_args 1 2 3
    The output should equal "1 2 3"
  End

	It 'parses args by default'
    When call call_with_variables _orb_parse_orb_prefixed_args 1 2 3
    The output should equal _orb_parse_args
  End
End

Describe '_orb_parse_args'
  orb_raise_error() { echo_me; exit 1; }
  _orb_collect_args() { echo_me; }
  _orb_set_arg_defaults() { echo_me; }  
  _orb_args_post_validation() { echo_me; }
  _orb_set_args_positional() { echo_me; }
  
  Context 'no args declared'
    It 'raises error if receive input args'
      When run _orb_parse_args 1 2 3
      The status should be failure 
      The output should equal "orb_raise_error" 
    End

    It 'returns without parsing if no args received'
      When run _orb_parse_args
      The status should be success
      The variable "spec_fns[@]" should be blank 
    End
  End

  Context 'args declared'
    _orb_declaration=(
      var = 1 
    )

    It 'parses args'
      When run _orb_parse_args 1 2 3
      The output should equal "_orb_collect_args
_orb_set_arg_defaults
_orb_args_post_validation
_orb_set_args_positional"
      The status should be success
    End

    It 'continues even if no args received'
      When run _orb_parse_args
      The output should equal "_orb_collect_args
_orb_set_arg_defaults
_orb_args_post_validation
_orb_set_args_positional"
      The status should be success
    End
  End
End

Describe '_orb_collect_args'
  It ''
    When call _orb_collect_args
    The status should be 
  End
End
