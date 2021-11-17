Include namespaces/core/file.sh

Describe '_upfind_closest'
  It 'finds the closest matching file'
    When call _upfind_closest _orb_nested_test_file spec/templates/nest_level_1/nest_level_2
    The output should include "spec/templates/nest_level_1/nest_level_2/_orb_nested_test_file"
    The status should be success
  End

  It 'finds the closest matching file in lower levels'
    When call _upfind_closest _orb_nested_test_file_level_1 spec/templates/nest_level_1/nest_level_2
    The output should include "spec/templates/nest_level_1/_orb_nested_test_file_level_1"
  End

  It 'fails if no file found'
    When call _upfind_closest _orb_nested_test_file_non_existent spec/templates/nest_level_1/nest_level_2
    The status should be failure
  End
End

Describe '_upfind_to_arr'
  It 'adds file matches to array'
    arr=()
    print_arr() { echo "${arr[@]}"; }
    
    When call _upfind_to_arr arr _orb_nested_test_file spec/templates/nest_level_1/nest_level_2
    The result of "print_arr()" should include "spec/templates/nest_level_1/nest_level_2/_orb_nested_test_file" 
    The result of "print_arr()" should include "spec/templates/nest_level_1/_orb_nested_test_file"
  End

  It 'fails if no file found'
    When call _upfind_closest _orb_nested_test_file_non_existent spec/templates/nest_level_1/nest_level_2
    The status should be failure
  End
End

Describe '_parse_env'
  It 'exports variables from .env'
    When call _parse_env "spec/templates/test.env"
    The variable MY_TEST_VAR should equal "test"
    The variable MY_TEST_VAR2 should equal "test2"
  End
End

Describe '_has_public_function'
  It 'succeeds if public function exists in file'
    # When call _has_public_function "spec/templates/test_functions.sh"
    When call _has_public_function "test_orb_fn" "spec/templates/test_functions.sh"
    The status should be success
  End

  It 'fails if function is private (no function prefix)'
    When call _has_public_function private_function "spec/templates/test_functions.sh"
    The status should be failure
  End

  It 'fails if function is private (not followed by curly bracket)'
    When call _has_public_function private_function2 "spec/templates/test_functions.sh"
    The status should be failure
  End

  It 'fails if function does not exist in file'
    When call _has_public_function non_existent_function "spec/templates/test_functions.sh"
    The status should be failure
  End
End
