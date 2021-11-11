Include namespaces/core/parsing.sh

Describe '_function_declared'
  test_fn() { :; }
  It 'succeeds if function exists'
    When call _function_declared test_fn
    The status should be success
  End

  It 'fails if function does not exist'
    unset -f test_fn
    When call _function_declared test_fn
    The status should be failure
  End
End

Describe '_collect_my_args'
  Include lib/initialize.sh
  Include spec/templates/test_functions.sh

  It 'returns code to be evaluated in parent function'
    When call _collect_my_args
    The output should equal 'source "$_orb_dir/lib/arguments/collection_post_call.sh" core "$FUNCNAME" "$@" && set -- "${_args_nrs[@]}" "${_args_wildcard[@]}"'
  End

  It 'When evaluated in parent function it collects function args'
    When call test_orb_fn "${test_orb_fn_input_args[@]}"
    The output should equal "$test_orb_fn_print_args"
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


Describe '_parse_env'
  It 'exports variables from .env'
    When call _parse_env "spec/templates/test.env"
    The variable MY_TEST_VAR should equal "test"
    The variable MY_TEST_VAR2 should equal "test2"
  End
End

Describe '_grep_between'
  It 'gets value between two strings'
    When call _grep_between 123456 2 5
    The output should equal 34
  End
End

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

Describe '_join_by'
  It 'joins array by separator'
    arr=(1 2 3)
    When call _join_by a "${arr[@]}"
    The output should equal 1a2a3
  End
End

Describe '_eval_variable_or_string'
  It 'evaluates variable if given'
    my_var=test
    When call _eval_variable_or_string '$my_var'
    The output should equal "test"
  End

  It 'evaluates string if given'
    When call _eval_variable_or_string my_var
    The output should equal my_var
  End
End

Describe '_eval_variable_or_string_options'
  It 'evaluates variable in correct order'
    my_var=test
    When call _eval_variable_or_string_options '$no_var|$my_var'
    The output should equal "test"
  End

  It 'evaluates string if given'
    When call _eval_variable_or_string_options '$no_var|$no_var2|fallback'
    The output should equal fallback
  End
End

Describe '_is_empty_arr'
  It 'succeeds if arr is empty'
    arr=()
    When call _is_empty_arr arr
    The status should be success
  End

  It 'fails if arr not empty'
    arr=(1 2)
    When call _is_empty_arr arr
    The status should be failure
  End
End


Todo '_got_orb_prefix'
