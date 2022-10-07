Include functions/declaration/getters.sh
Include functions/declaration/checkers.sh
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


# TODO
