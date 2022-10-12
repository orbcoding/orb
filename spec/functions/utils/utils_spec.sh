Include functions/utils/utils.sh

# orb_function_declared
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

# orb_variable_or_string_value
Describe 'orb_variable_or_string_value'
  It 'evaluates variable if given'
    my_var=spec
    When call orb_variable_or_string_value store_var '$my_var'
    The variable store_var should equal "spec"
  End

  It 'evaluates string if given'
    When call orb_variable_or_string_value store_var my_var
    The variable store_var should equal my_var
  End

  It 'fails if var not found'
    When call orb_variable_or_string_value store_var '$my_var'
    The status should be failure
    The variable store_var should be undefined
  End
End

# orb_if_present
Describe 'orb_if_present'
  It 'stores first present if variable'
    my_var=spec
    When call orb_if_present store_var '$unknown || $my_var || fallback'
    The variable store_var should eq spec
  End

  It 'stores first present if string to variable'
    When call orb_if_present store_var '$unknown || fallback'
    The variable store_var should eq fallback
  End

  It 'fails if no present variable'
    When call orb_if_present store_var '$unknown'
    The status should be failure
    The variable store_var should be undefined
  End
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

# _orb_copy_variable
Describe '_orb_copy_variable'
  first_var=spec

  It 'copies variable based on declaration'
    eval $(_orb_copy_variable first_var new_var)
    The variable new_var should eq spec
  End

  rename() {
    global=$1
    eval $(_orb_copy_variable first_var new_var $global)
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
    When call _orb_copy_variable unknown_var new_var
    The status should be failure 
  End
End


# Describe 'orb_grep_between'
#   It 'gets value between two strings'
#     When call orb_grep_between 123456 2 5
#     The output should equal 34
#   End
# End

# Describe 'orb_join_by'
#   It 'joins array by separator'
#     arr=(1 2 3)
#     When call orb_join_by a "${arr[@]}"
#     The output should equal 1a2a3
#   End
# End

# Describe 'orb_is_empty_arr'
#   It 'succeeds if arr is empty'
#     arr=()
#     When call orb_is_empty_arr arr
#     The status should be success
#   End

#   It 'fails if arr not empty'
#     arr=(1 2)
#     When call orb_is_empty_arr arr
#     The status should be failure
#   End
# End


# Describe 'orb_remove_prefix'
# End
