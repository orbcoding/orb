Include functions/utils/argument.sh
Include functions/utils/utils.sh
Include functions/declaration/checkers.sh
Include functions/declaration/getters.sh
Include scripts/initialize_variables.sh

# _orb_has_declared_arg
Describe '_orb_has_declared_arg'
  _orb_declared_args=(-f)

  It 'succeeds when arg declared'
    When call _orb_has_declared_arg "-f"
    The status should be success
  End

  It 'fails when arg undeclared'
    When call _orb_has_declared_arg "-a"
    The status should be failure
  End

  It 'succeeds for flags with +'
    When call _orb_has_declared_arg "+f"
    The status should be success
  End
End

# _orb_has_declared_boolean_flag
Describe '_orb_has_declared_boolean_flag'
  _orb_declared_args=(-f)

  It 'succeeds when boolean flag declared'
    When call _orb_has_declared_boolean_flag "-f"
    The status should be success
  End

  It 'fails when boolean flag undeclared'
    When call _orb_has_declared_boolean_flag "-a"
    The status should be failure
  End
  
  It 'fails when boolean flag has suffix'
    declare -A _orb_declared_arg_suffixes=([-f]=1)
    When call _orb_has_declared_boolean_flag -f
    The status should be failure
  End

  It 'handles declaration suffixes'
    _orb_variable_suffix="_suffix"
    _orb_declared_args_suffix=(-s)
    When call _orb_has_declared_boolean_flag -s
    The status should be success
  End
End


# _orb_has_declared_flagged_arg
Describe '_orb_has_declared_flagged_arg'
  _orb_declared_args=(-f)
  declare -A _orb_declared_arg_suffixes=([-f]=1)

  It 'succeeds when flagged arg declared'
    When call _orb_has_declared_flagged_arg "-f"
    The status should be success
  End

  It 'fails when flag undeclared'
    When call _orb_has_declared_flagged_arg "-a"
    The status should be failure
  End
  
  It 'fails for boolean flags'
    declare -A _orb_declared_arg_suffixes
    When call _orb_has_declared_flagged_arg -f
    The status should be failure
  End

  It 'handles declaration suffixes'
    _orb_variable_suffix="_suffix"
    _orb_declared_args_suffix=(-s)
    declare -A _orb_declared_arg_suffixes_suffix=([-s]=1)
    When call _orb_has_declared_flagged_arg -s
    The status should be success
  End
End

# _orb_has_declared_array_flag_arg
Describe '_orb_has_declared_array_flag_arg'
  _orb_declared_args=(-a -f -n)
  declare -A _orb_declared_arg_suffixes=([-a]=2 [-f]=1)

  It 'succeeds when suffix > 1'
    When call _orb_has_declared_array_flag_arg "-a"
    The status should be success
  End

  It 'fails when suffix < 2'
    When call _orb_has_declared_array_flag_arg "-f"
    The status should be failure
  End
  
  It 'fails when no suffix (boolean flags)'
    When call _orb_has_declared_array_flag_arg -n
    The status should be failure
  End
End

# _orb_has_declared_array_arg
Describe '_orb_has_declared_array_arg'
  _orb_declared_args=(-b -f -m -a ... -b- --)
  declare -A _orb_declared_arg_suffixes=([-f]="1" [-m]="2")
  _orb_declared_option_values=(true)
  declare -A _orb_declared_option_start_indexes=([Multiple:]="- - - 0 - - -")
  declare -A _orb_declared_option_lengths=([Multiple:]="- - - 1 - - -")
  
  It 'suceeds for flagged arg with suffix > 1'
    When call _orb_has_declared_array_arg -m
    The status should be success
  End

  It 'suceeds for flagged arg with catches multiple'
    When call _orb_has_declared_array_arg -a
    The status should be success
  End

  It 'fails for flagged arg with suffix <= 1'
    When call _orb_has_declared_array_arg -f
    The status should be failure
  End

  It 'suceeds for ...'
    When call _orb_has_declared_array_arg ...
    The status should be success
  End

  It 'suceeds for block'
    When call _orb_has_declared_array_arg -b-
    The status should be success
  End

  It 'suceeds for --'
    When call _orb_has_declared_array_arg --
    The status should be success
  End

  It 'fails for number args'
    When call _orb_has_declared_array_arg 1
    The status should be failure
  End
  
  It 'fails for boolean flags'
    When call _orb_has_declared_array_arg -b
    The status should be failure
  End
End

# _orb_arg_catches
Describe '_orb_arg_catches'
  _orb_declared_args=(1)
  _orb_declared_option_values=(flag)
  declare -A _orb_declared_option_start_indexes=([Catch:]="0")
  declare -A _orb_declared_option_lengths=([Catch:]="1")
  
  It 'adds catch values to arg_catchs'
    When call _orb_arg_catches 1 -f
    The status should be success
  End
End

