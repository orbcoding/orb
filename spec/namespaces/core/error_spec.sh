Include namespaces/core/error.sh

Describe '_raise_error'
  kill() {
    return 2
  }
  
  _function_descriptor=test_caller_descriptor
  
  It 'prints error with trace and kills script'
    When call _raise_error "test error"
    The status should equal 2
    The error should include Error:
    The error should include "test_caller_descriptor"
    The error should include "test error"
    # Parts of trace
    The error should include error.sh
    The error should include _raise_error
  End

  It 'does not kill script with +k'
    exit() {
      return 1
    }
    When call _raise_error +k "test error"
    The status should be failure
    The error should include Error:
    The error should include "test_caller_descriptor"
    The error should include "test error"
    # Parts of trace
    The error should include error.sh
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
