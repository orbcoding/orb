Include namespaces/core/debugging.sh

Describe '_ee'
	It 'outputs to stderr'
    When call _ee text
    The error should equal text
  End
End

Describe '_print_args'
  Include lib/initialize.sh
  Include spec/templates/test_functions.sh

  It 'prints args'
    When call test_orb_fn "${test_orb_fn_input_args[@]}"
    The output should equal "$test_orb_fn_print_args"
  End
End

# _catch
Describe '_catch'
	It 'captures stdout, stderr and exit status code'
    succeeding_fn() { echo output && echo error >&2 && exit 0; }
    When call _catch out err status succeeding_fn
    The variable out should equal output
    The variable err should equal error
    The variable status should equal 0
    The status should be success
  End

	It 'also works for failing functions'
    failing_fn() { echo output && echo error >&2 && exit 1; }
    When call _catch out err status failing_fn
    The variable out should equal output
    The variable err should equal error
    The variable status should equal 1
    The status should be failure
  End
End
