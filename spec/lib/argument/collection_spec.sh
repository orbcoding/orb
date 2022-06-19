Include lib/arguments/collection.sh
# Include lib/scripts/orb/settings.sh

Describe '_orb_parse_orb_prefixed_args'
  settings='lib/scripts/orb/settings.sh'
  call_with_settings() { source "$settings"; "$@"; }
  _orb_print_function_help() { echo_me; }
  _orb_parse_args() { echo_me; }

	It 'prints function help if 1 == help'
    When run call_with_settings _orb_parse_orb_prefixed_args --help
    The output should equal _orb_print_function_help
  End

	It 'sets positional args if _orb_settings_direct_call'
    call_with_settings() {
      source "$settings"
      _orb_setting_direct_call=true
      _orb_parse_orb_prefixed_args 1 2 3
    }
    When call call_with_settings
    The variable "_orb_positional[2]" should equal 3
  End

	It 'parses args by default'
    When call call_with_settings _orb_parse_orb_prefixed_args 1 2 3
    The output should equal _orb_parse_args
  End
End

Describe '_orb_parse_args'
  orb_raise_error() { echo_me; exit 1; }
  
  Context 'no args declared'
    It 'raises error if receive input args'
      When run _orb_parse_args 1 2 3
      The status should be failure 
      The output should equal "orb_raise_error" 
    End
  End

  Context 'no args received'
    It 'returns success'
      When run _orb_parse_args
      The status should be success
    End
  End

  Context 'args declared'
    # TODO check if args declared
    # _orb_declaration = ()
    # It ''
  End
End
