Include lib/argument/assignment.sh
Include $spec_orb/namespaces/spec/test_functions.sh

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


# TODO update assignment functions
# Describe '_orb_assign_flagged_arg'
  
# End

  # It 'prints args'
  #   When call test_orb_print_args "${test_orb_print_args_input_args[@]}"
  #   The output should equal "$test_orb_print_argsorb_print_args"
  # End
