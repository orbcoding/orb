Include lib/utils/debug.sh

Describe 'orb_ee'
	It 'outputs to stderr'
    When call orb_ee text
    The error should equal text
  End
End

Describe 'orb_print_args'
  Include $spec_orb/namespaces/spec/test_functions.sh

  It 'prints args'
    When call test_orb_print_args "${test_orb_print_args_input_args[@]}"
    The output should equal "$test_orb_print_argsorb_print_args"
  End
End
