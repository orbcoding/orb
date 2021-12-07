Include namespaces/core/debug.sh

Describe '_ee'
	It 'outputs to stderr'
    When call _ee text
    The error should equal text
  End
End

Describe '_print_args'
  Include spec/templates/.orb_extension/namespaces/spec/test_functions.sh

  It 'prints args'
    When call test_orb_fn "${test_orb_fn_input_args[@]}"
    The output should equal "$test_orb_fn_print_args"
  End
End
