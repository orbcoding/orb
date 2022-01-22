Include lib/utils/file.sh

Describe 'orb_upfind_closest'
  It 'finds the closest matching file'
    When call orb_upfind_closest _orb_nested_test_file spec/templates/nest_level_1/nest_level_2
    The output should include "spec/templates/nest_level_1/nest_level_2/_orb_nested_test_file"
    The status should be success
  End

  It 'finds the closest matching file in lower levels'
    When call orb_upfind_closest _orb_nested_test_file_level_1 spec/templates/nest_level_1/nest_level_2
    The output should include "spec/templates/nest_level_1/_orb_nested_test_file_level_1"
  End

  It 'fails if no file found'
    When call orb_upfind_closest _orb_nested_test_file_non_existent spec/templates/nest_level_1/nest_level_2
    The status should be failure
  End
End

Describe 'orb_upfind_to_arr'
  # TODO test & and |

  It 'adds file matches to array'
    arr=()
    When call orb_upfind_to_arr arr _orb_nested_test_file spec/templates/nest_level_1/nest_level_2
    The variable "arr[0]" should include "spec/templates/nest_level_1/nest_level_2/_orb_nested_test_file" 
    The variable "arr[1]" should include "spec/templates/nest_level_1/_orb_nested_test_file"
  End

  It 'stops after parsing last directory'
    arr=()
    When call orb_upfind_to_arr arr _orb_nested_test_file spec/templates/nest_level_1/nest_level_2 spec/templates/nest_level_1/nest_level_2
    The variable "arr[0]" should include "spec/templates/nest_level_1/nest_level_2/_orb_nested_test_file" 
    The variable "arr[1]" should be undefined
  End

  It 'fails if no file found'
    When call orb_upfind_closest _orb_nested_test_file_non_existent spec/templates/nest_level_1/nest_level_2
    The status should be failure
  End
End

Describe 'orb_parse_env'
  It 'exports variables from .env'
    When call orb_parse_env "$spec_orb/.env"
    The variable SPEC_TEST_VAR should equal "test"
    The variable SPEC_TEST_VAR2 should equal "test2"
  End
End

Describe 'orb_has_public_function'
  It 'succeeds if public function exists in file'
    # When call orb_has_public_function "$spec_orb/namespaces/spec/test_functions.sh"
    When call orb_has_public_function "test_orb_print_args" "$spec_orb/namespaces/spec/test_functions.sh"
    The status should be success
  End

  It 'fails if function is private (no function prefix)'
    When call orb_has_public_function private_function "$spec_orb/namespaces/spec/test_functions.sh"
    The status should be failure
  End

  It 'fails if function is private (not followed by curly bracket)'
    When call orb_has_public_function private_function2 "$spec_orb/namespaces/spec/test_functions.sh"
    The status should be failure
  End

  It 'fails if function does not exist in file'
    When call orb_has_public_function non_existent_function "$spec_orb/namespaces/spec/test_functions.sh"
    The status should be failure
  End
End
