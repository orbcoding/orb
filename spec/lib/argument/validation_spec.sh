Include lib/arguments/validation.sh

# _orb_is_valid_arg
Describe '_orb_is_valid_arg'
  _orb_is_valid_in() { echo_fn $@; }
  
  It 'should call _orb_is_valid_in'
    When call _orb_is_valid_arg 1 2
    The output should equal "_orb_is_valid_in 1 2"
  End
End


Describe '_orb_is_valid_in'
  Context 'with In declaration'
    declare -A _orb_declared_ins_start_indexes=([1]=1)
    declare -A _orb_declared_ins_lengths=([1]=3)
    declare -a _orb_declared_ins=(1 2 3 4 5)

    It 'succeeds if arg value in In array'
      When call _orb_is_valid_in 1 2
      The status should be success
    End
    
    It 'fails if arg value not in In array'
      When call _orb_is_valid_in 1 1
      The status should be failure
    End
  End

  It 'succeeds if no In declaration'
    When call _orb_is_valid_in 1 2
    The status should be success
  End
End
