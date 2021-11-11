# Include lib/initialize.sh
# Todo 'Remove initialize dep?'

# _strict_run
Describe '_strict_run'
  Mock _kill_script
    exit 1
  End

  success_msg="$(echo -e "$(_green)test$(_normal)")"

  Context 'cmd succeeds'
    Context 'cmd without error'
      It 'succeeds'
        When call _strict_run "test" echo something
        # _strict_run "test run" echo hej
        The status should be success
        The output should equal $success_msg
      End

      It 'passes output with -o'
        When call _strict_run -o "test" echo output_msg 
        The status should be success
        The output should include "test"
        The output should include "output_msg"
      End
    End

    Context 'cmd outputs error'
      Mock fn_with_error
        echo error_msg >&2
      End 

      Mock fn_with_output_and_error
        echo error_msg >&2 && echo output_msg
      End 

      It 'raises error'
        When call _strict_run "test" fn_with_error 
        # _strict_run "test run" echo hej
        The status should be failure
        The error should include error_msg
        The error should include fn_with_error
      End

      It 'fails without raising error with +r'
        When call _strict_run  +r "test" fn_with_error
        The error should include error_msg
        The status should be failure
      End

      It 'succeeds with -s'
        When call _strict_run "test" -s fn_with_error 
        # _strict_run "test run" echo hej
        The output should equal $success_msg
        The status should be success
      End

      It 'passes output with -o'
        When call _strict_run -o "test" fn_with_output_and_error
        The status should be failure
        The output should include output_msg
        The error should include error_msg
      End
    End
  End

  Context 'cmd fails'
    It 'raises error'
      When call _strict_run "test" exit 1
      The status should be failure
      The error should include "test failed"
      The error should include "exit 1"
    End

    It 'fails without raising error with +r'
      When call _strict_run  +r "test" exit 1
      The status should be failure
    End
  End
End

Describe '_raise_error'
  Mock _kill_script
    exit 1
  End
  
  _function_descriptor=test_caller_descriptor
  
  It 'prints error with trace and kills script'
    When call _raise_error "test error"
    The status should be failure
    The error should include Error:
    The error should include "test_caller_descriptor"
    The error should include "test error"
    # Parts of trace
    The error should include error_handling.sh
    The error should include _raise_error
  End

  It 'does not print trace with +t'
    When call _raise_error +t "test error"
    The status should be failure
    The error should include Error:
    The error should include "test error"
    The error should include "test_caller_descriptor"
    # Parts of trace
    The error should not include error_handling.sh
    The error should not include _raise_error
  End

  It 'accepts custom descriptor'
    When call _raise_error -d "custom_descriptor" "test error"
    The status should be failure
    The error should include Error:
    The error should include "test error"
    The error should include "custom_descriptor"
  End
End

Describe '_print_error'
  _function_descriptor=test_caller_descriptor

  It 'prints pretty error'
    When call _print_error 'test error'
    The status should be success
    The error should include Error:
    The error should include "test error"
    The error should include "test_caller_descriptor"
  End

  It 'accepts custom descriptor'
    When call _print_error -d "custom_descriptor" "test error"
    The status should be success
    The error should include Error:
    The error should include "test error"
    The error should include "custom_descriptor"
  End
End

Describe '_kill_script'
  It 'kills -PIPE 0'
    kill() {
      echo $*
    }
    
    When call _kill_script
    The output should equal "-PIPE 0"
  End
End

Describe '_print_stack_trace'
  It 'Should print stack trace to stdout'
    caller_fn() { _print_stack_trace; }
    When call caller_fn
    The first line of output should equal ""
    The second line of output should include main:
    The second line of output should include caller_fn
  End
End
