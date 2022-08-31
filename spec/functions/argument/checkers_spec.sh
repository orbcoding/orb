Include functions/arguments/checkers.sh
Include functions/declaration/checkers.sh
Include functions/utils/argument.sh

# _orb_get_arg_value
Describe '_orb_get_arg_value'
  declare -A _orb_args_values_start_indexes=([1]=0 [...]=5)
  declare -A _orb_args_values_lengths=([1]=5 [...]=2)
  _orb_args_values=(1 2 3 4 5 1 2)
  values=()
  
  It 'adds arg values to ref'
    When call _orb_get_arg_value 1 values
    The variable "values[@]" should equal "1 2 3 4 5"
  End 

  It 'stores as array for array args'
    When call _orb_get_arg_value ... values
    The variable "values[0]" should equal "1"
  End 

  It 'stores as string for non array args'
    When call _orb_get_arg_value 1 values
    The variable "values[0]" should equal "1 2 3 4 5"
  End 
End

Describe '_orb_has_arg_value'
  It 'succeeds when has start index'
    declare -A _orb_args_values_start_indexes=([1]=0)
    When call _orb_has_arg_value 1
    The status should be success
  End

  It 'fails when does not have start index'
    When call _orb_has_arg_value 1
    The status should be failure
  End
End
