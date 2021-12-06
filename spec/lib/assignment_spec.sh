Include lib/arguments/assignment.sh

Describe '_orb_flag_value'
	It 'returns true if starts with -'
    When call _orb_flag_value -f
    The output should equal true
  End

	It 'returns false if does not start with -'
    When call _orb_flag_value +f
    The output should equal false
  End
End


Todo '_orb_assign_flagged_arg'

  It 'prints args'
    When call test_orb_fn "${test_orb_fn_input_args[@]}"
    The output should equal "$test_orb_fn_print_args"
  End
End
