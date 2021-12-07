Include lib/arguments/collection.sh

Describe '_orb_parse_orb_prefixed_args'
  declare -A _orb_settings=(
    ['-d']=false
  )
  _orb_print_function_help() { echo_me; }
  _orb_parse_args() { echo_me; }

	It 'prints function help if 1 == help'
    When run _orb_parse_orb_prefixed_args --help
    The output should equal _orb_print_function_help
  End

	It 'sets positional args if orb_settings[-d]'
    _orb_settings[-d]=true
    When call _orb_parse_orb_prefixed_args 1 2 3
    The variable "_orb_positional[2]" should equal 3
  End

	It 'parses args by default'
    When call _orb_parse_orb_prefixed_args 1 2 3
    The output should equal _orb_parse_args
  End
End

Describe '_orb_parse_args'
  _raise_error() { echo_me; exit 1; }
  Context 'no args declared'
    It 'raises error if receive input args'
      When run _orb_parse_args 1 2 3
      The status should be failure 
      The output should equal "_raise_error" 
    End
  End
End
