Include lib/utils/argument.sh
Include lib/declaration/checkers.sh


# _orb_is_available_option
Describe '_orb_is_available_option'
  _orb_raise_invalid_declaration() { echo "$@"; exit 1; }

  It 'succeeds for Default:'
    When call _orb_is_available_option Default:
    The status should be success
  End

  It 'fails for other'
    When call _orb_is_available_option Unknown:
    The status should be failure
  End
End


# _orb_is_available_boolean_flag_option
Describe '_orb_is_available_boolean_flag_option'
  It 'succeeds for In:'
    When call _orb_is_available_boolean_flag_option Default:
    The status should be success
  End

  It 'fails for other'
    When call _orb_is_available_boolean_flag_option In:
    The status should be failure
  End
End

# _orb_is_available_array_option
Describe '_orb_is_available_array_option'
  It 'suceeds for In:'
    When call _orb_is_available_array_option Default:
    The status should be success
  End

  It 'fails for other'
    When call _orb_is_available_array_option In:
    The status should be failure
  End
End


# _orb_is_available_catch_value
Describe '_orb_is_available_catch_value'
  It 'suceeds for In:'
    When call _orb_is_available_catch_value flag
    The status should be success
  End

  It 'fails for other'
    When call _orb_is_available_catch_value unknown
    The status should be failure
  End
End

# _orb_is_available_required_value
Describe '_orb_is_available_required_value'
  It 'suceeds for In:'
    When call _orb_is_available_required_value true
    The status should be success
  End

  It 'fails for other'
    When call _orb_is_available_required_value unknown
    The status should be failure
  End
End

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


# _orb_has_declared_array
Describe '_orb_has_declared_array'
  _orb_declared_args=(-f -m -a ... -b- --)
  declare -A _orb_declared_arg_suffixes=([-f]="2" [-m]="1")

  It 'suceeds for flagged arg with suffix > 1'
    When call _orb_has_declared_array -f
    The status should be success
  End

  It 'suceeds for flagged arg with catches multiple'
    declare -a _orb_declared_catchs=(multiple)
    declare -A _orb_declared_catchs_start_indexes=([-m]=0)
    declare -A _orb_declared_catchs_lengths=([-m]=1)
    When call _orb_has_declared_array -m
    The status should be success
  End

  It 'fails for flagged arg with suffix <= 1'
    When call _orb_has_declared_array -a
    The status should be failure
  End

  It 'suceeds for ...'
    When call _orb_has_declared_array ...
    The status should be success
  End

  It 'suceeds for block'
    When call _orb_has_declared_array -b-
    The status should be success
  End

  It 'suceeds for --'
    When call _orb_has_declared_array --
    The status should be success
  End

  It 'fails for boolean flag'
    When call _orb_has_declared_array 1
    The status should be failure
  End
End


# _orb_arg_is_required
Describe '_orb_arg_is_required'
  declare -A _orb_declared_requireds=([1]=true [-f]=false)
  
  It 'succeeds if required'
    When call _orb_arg_is_required 1
    The status should be success
  End 

  It 'fails if not'
    When call _orb_arg_is_required -f
    The status should be failure
  End 
  
  It 'fails if missing'
    When call _orb_arg_is_required -a
    The status should be failure
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


# _orb_get_arg_default_arr
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


# _orb_arg_catches
Describe '_orb_arg_catches'
  declare -A _orb_declared_catchs_start_indexes=([1]=0)
  declare -A _orb_declared_catchs_lengths=([1]=1)
  _orb_declared_catchs=(flag)
  
  It 'adds catch values to arg_catchs'
    When call _orb_arg_catches 1 -f
    The status should be success
  End
End

