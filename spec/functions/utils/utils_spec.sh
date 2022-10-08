Include functions/utils/utils.sh

Describe 'orb_function_declared'
  test_fn() { :; }
  It 'succeeds if function exists'
    When call orb_function_declared test_fn
    The status should be success
  End

  It 'fails if function does not exist'
    unset -f test_fn
    When call orb_function_declared test_fn
    The status should be failure
  End
End

Describe 'orb_grep_between'
  It 'gets value between two strings'
    When call orb_grep_between 123456 2 5
    The output should equal 34
  End
End

Describe 'orb_join_by'
  It 'joins array by separator'
    arr=(1 2 3)
    When call orb_join_by a "${arr[@]}"
    The output should equal 1a2a3
  End
End

Describe 'orb_eval_variable_or_string'
  It 'evaluates variable if given'
    my_var=test
    When call orb_eval_variable_or_string '$my_var'
    The output should equal "test"
  End

  It 'evaluates string if given'
    When call orb_eval_variable_or_string my_var
    The output should equal my_var
  End
End

Describe 'orb_eval_variable_or_string_options'
  It 'evaluates variable in correct order'
    my_var=test
    When call orb_eval_variable_or_string_options '$no_var|$my_var'
    The output should equal "test"
  End

  It 'evaluates string if given'
    When call orb_eval_variable_or_string_options '$no_var|$no_var2|fallback'
    The output should equal fallback
  End
End

Describe 'orb_is_empty_arr'
  It 'succeeds if arr is empty'
    arr=()
    When call orb_is_empty_arr arr
    The status should be success
  End

  It 'fails if arr not empty'
    arr=(1 2)
    When call orb_is_empty_arr arr
    The status should be failure
  End
End


Describe 'orb_remove_prefix'
End

# orb_index_of
Describe 'orb_index_of'
  It 'returns the index of item in array'
    arr=(first second third)
    When call orb_index_of second arr
    The output should equal 1
  End

  It 'returns -1 and fails if not found'
    arr=(first second third)
    When call orb_index_of fourth arr
    The status should be failure
    The output should equal -1
  End
End

# orb_in_arr
Describe 'orb_in_arr'
  It 'succeeds if item in array'
    arr=(first second third)
    When call orb_in_arr second arr
    The status should be success
  End

  It 'fails if not found'
    arr=(first second third)
    When call orb_in_arr fourth arr
    The status should be failure
  End
End

# _orb_rename_variable
Describe '_orb_rename_variable'
  first_var=spec

  It 'renames variable based on declaration'
    eval $(_orb_rename_variable first_var new_var)
    The variable first_var should be undefined
    The variable new_var should eq spec
  End

  It 'does not unset old name if false'
    eval $(_orb_rename_variable first_var new_var false)
    The variable first_var should eq spec
    The variable new_var should eq spec
  End

  rename() {
    global=$1
    eval $(_orb_rename_variable first_var new_var true $global)
  }
  It 'creates local variable if false'
    When call rename false
    The variable new_var should be undefined
  End
  
  It 'creates a global variable if true'
    When call rename true
    The variable new_var should eq spec
  End

  It 'does nothing if no variable found'
    When call _orb_rename_variable unknown_var new_var
    The status should be failure 
  End
End
