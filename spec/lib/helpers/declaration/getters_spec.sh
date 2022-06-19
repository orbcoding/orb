Include lib/helpers/declaration/getters.sh

# _orb_get_args_index
Describe '_orb_get_args_index'
  _orb_declared_args=(1 -f ...)
  
  It 'gets index of arg'
    When call _orb_get_args_index -f
    The output should equal 1
  End 

  It 'fails if no index'
    When call _orb_get_args_index --
    The status should be failure
  End 
End

# _orb_arg_is_required
Describe '_orb_arg_is_required'

  _orb_declared_arg_requireds=(true false true)
  
  It 'succeeds if required'
    When call _orb_arg_is_required 0
    The status should be success
  End 

  It 'fails if not'
    When call _orb_arg_is_required 1
    The status should be failure
  End 
End


# _orb_get_arg_comment
Describe '_orb_get_arg_comment'
  _orb_declared_arg_comments=("first comment" "" "third comment")
  
  It 'succeeds and outputs comment if has comment'
    When call _orb_get_arg_comment 0
    The output should equal "first comment"
  End 
  
  It 'fails if no comment'
    When call _orb_get_arg_comment 1
    The status should be failure
  End 
End

# _orb_get_arg_default_arr
Describe '_orb_get_arg_default_arr'
  _orb_declared_arg_defaults_indexes=(0 "" 5)
  _orb_declared_arg_defaults_lengths=(5 "" 2)
  _orb_declared_arg_defaults=(1 2 3 4 5 6 7)
  arg_default=()
  
  It 'adds default values to arg_default'
    When call _orb_get_arg_default_arr 0
    The variable "arg_default[@]" should equal "1 2 3 4 5"
  End 

  It 'fails if no default for arg'
    When call _orb_get_arg_default_arr 1
    The status should be failure
  End 

  It 'handles nested values'
    When call _orb_get_arg_default_arr 2
    The variable "arg_default[@]" should equal "6 7"
  End 
End


# _orb_get_arg_default_arr
Describe '_orb_get_arg_in_arr'
  _orb_declared_arg_ins_indexes=(0 "" 5)
  _orb_declared_arg_ins_lengths=(5 "" 2)
  _orb_declared_arg_ins=(1 2 3 4 5 6 7)
  arg_default=()
  
  It 'adds default values to arg_default'
    When call _orb_get_arg_in_arr 0
    The variable "arg_in[@]" should equal "1 2 3 4 5"
  End 

  It 'fails if no default for arg'
    When call _orb_get_arg_in_arr 1
    The status should be failure
  End 

  It 'handles nested values'
    When call _orb_get_arg_in_arr 2
    The variable "arg_in[@]" should equal "6 7"
  End 
End
