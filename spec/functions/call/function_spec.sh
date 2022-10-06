Include functions/call/function.sh
Include functions/utils/text.sh


Describe _orb_get_current_function
  Context 'with _orb_sourced'
    _orb_sourced=true
    _orb_get_current_function_from_trace() { echo_fn; }

    It 'calls _orb_get_current_function_from_trace and returns 2'
      When call _orb_get_current_function my_function
      The status should equal 2
      The output should equal _orb_get_current_function_from_trace
    End
  End

  Context 'without _orb_sourced'
    _orb_sourced=false

    It 'returns 0 and outputs $1'
      When call _orb_get_current_function my_function
      The status should be success
      The output should equal my_function
    End
  End
End

Describe '_orb_get_current_function_from_trace'
  It 'gets function from source chain'
    _orb_function_trace=("source" "fn" )
    When call _orb_get_current_function_from_trace
    The output should eq fn
  End
End


Describe '_orb_get_current_function_descriptor'
  It 'includes namespace if present'
    When run _orb_get_current_function_descriptor test_fn test_namespace
    The output should equal "test_namespace->$(orb_bold)test_fn$(orb_normal)"
  End

  It 'only fn if no namespace'
    When run _orb_get_current_function_descriptor test_fn
    The output should equal $(orb_bold)test_fn$(orb_normal)
  End
End

