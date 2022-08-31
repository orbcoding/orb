Include functions/declaration/getters.sh
Include functions/utils/argument.sh

# _orb_get_declared_number_args_in_order
Describe '_orb_get_declared_number_args_in_order'
  _orb_declared_args=(4 6 -f 1 5 3 ... 2)
  
  It 'gets declared number args in sorted order'
    When call _orb_get_declared_number_args_in_order _arr
    The variable "_arr[@]" should equal "1 2 3 4 5 6"
  End
End

# _orb_get_arg_comment
Describe '_orb_get_arg_comment'
  declare -A _orb_declared_comments=([1]="first comment" [2]="" [-f]="third comment")
  
  It 'succeeds and outputs comment if has comment'
    When call _orb_get_arg_comment 1
    The output should equal "first comment"
  End 
  
  It 'fails if no comment'
    When call _orb_get_arg_comment 2
    The status should be failure
  End 
  
  It 'fails if missing'
    When call _orb_get_arg_comment -a
    The status should be failure
  End 
End

# _orb_get_arg_default_arr
Describe '_orb_get_arg_default_arr'
  declare -A _orb_declared_defaults_start_indexes=([1]=0 [-a]=5)
  declare -A _orb_declared_defaults_lengths=([1]=5 [-a]=2)
  _orb_declared_defaults=(1 2 3 4 5 6 7)
  arg_default=()
  
  It 'adds default values to arg_default'
    When call _orb_get_arg_default_arr 1 arg_default
    The variable "arg_default[@]" should equal "1 2 3 4 5"
  End 

  It 'fails if no default for arg'
    When call _orb_get_arg_default_arr 2 arg_default
    The status should be failure
  End 

  It 'handles nested values'
    When call _orb_get_arg_default_arr -a arg_default
    The variable "arg_default[@]" should equal "6 7"
  End 
End


# _orb_get_arg_in_arr
Describe '_orb_get_arg_in_arr'
  declare -A _orb_declared_ins_start_indexes=([1]=0 [-a]=5)
  declare -A _orb_declared_ins_lengths=([1]=5 [-a]=2)
  _orb_declared_ins=(1 2 3 4 5 6 7)
  arg_ins=()
  
  It 'adds in values to arg_ins'
    When call _orb_get_arg_in_arr 1 arg_ins
    The variable "arg_ins[@]" should equal "1 2 3 4 5"
  End 

  It 'fails if no in for arg'
    When call _orb_get_arg_in_arr 2 arg_ins
    The status should be failure
  End 

  It 'handles nested values'
    When call _orb_get_arg_in_arr -a arg_ins
    The variable "arg_ins[@]" should equal "6 7"
  End 
End


# _orb_get_arg_catch_arr
Describe '_orb_get_arg_catch_arr'
  declare -A _orb_declared_catchs_start_indexes=([1]=0 [-a]=5)
  declare -A _orb_declared_catchs_lengths=([1]=5 [-a]=2)
  _orb_declared_catchs=(1 2 3 4 5 6 7)
  arg_catch=()
  
  It 'adds catch values to arg_catchs'
    When call _orb_get_arg_catch_arr 1 arg_catch
    The variable "arg_catch[@]" should equal "1 2 3 4 5"
  End 

  It 'fails if no catchs for arg'
    When call _orb_get_arg_catch_arr 2 arg_catch
    The status should be failure
  End 

  It 'handles nested values'
    When call _orb_get_arg_catch_arr -a arg_catch
    The variable "arg_catch[@]" should equal "6 7"
  End 
End
