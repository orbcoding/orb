Include functions/utils/argument.sh
Include functions/declaration/checkers.sh
Include functions/declaration/getters.sh
Include scripts/initialize_variables.sh


# _orb_is_available_arg_option
Describe '_orb_is_available_arg_option'
  _orb_raise_invalid_declaration() { echo "$@"; exit 1; }

  It 'succeeds for Default:'
    When call _orb_is_available_arg_option Default:
    The status should be success
  End

  It 'fails for other'
    When call _orb_is_available_arg_option Unknown:
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

# _orb_is_available_flag_arg_option
Describe '_orb_is_available_flag_arg_option'
  It 'suceeds for Required:'
    When call _orb_is_available_flag_arg_option Required:
    The status should be success
  End

  It 'fails for Catch:'
    When call _orb_is_available_flag_arg_option Catch:
    The status should be failure
  End
End

# _orb_is_available_array_flag_arg_option
Describe '_orb_is_available_array_flag_arg_option'
  It 'suceeds for Required:'
    When call _orb_is_available_array_flag_arg_option Required:
    The status should be success
  End

  It 'fails for Ins:'
    When call _orb_is_available_array_flag_arg_option In:
    The status should be failure
  End
End

# _orb_is_available_block_option
Describe '_orb_is_available_block_option'
  It 'suceeds for Required:'
    When call _orb_is_available_block_option Required:
    The status should be success
  End

  It 'fails for In:'
    When call _orb_is_available_block_option In:
    The status should be failure
  End
End

# _orb_is_available_dash_option
Describe '_orb_is_available_dash_option'
  It 'suceeds for Required:'
    When call _orb_is_available_dash_option Required:
    The status should be success
  End

  It 'fails for In:'
    When call _orb_is_available_dash_option In:
    The status should be failure
  End
End

# _orb_is_available_rest_option
Describe '_orb_is_available_rest_option'
  It 'suceeds for Required:'
    When call _orb_is_available_rest_option Required:
    The status should be success
  End

  It 'fails for In:'
    When call _orb_is_available_rest_option In:
    The status should be failure
  End
End

# _orb_is_available_catch_option_value
Describe '_orb_is_available_catch_option_value'
  It 'suceeds for flag'
    When call _orb_is_available_catch_option_value flag
    The status should be success
  End

  It 'fails for other'
    When call _orb_is_available_catch_option_value unknown
    The status should be failure
  End
End

# _orb_is_available_required_option_value
Describe '_orb_is_available_required_option_value'
  It 'suceeds for true'
    When call _orb_is_available_required_option_value true
    The status should be success
  End

  It 'fails for other'
    When call _orb_is_available_required_option_value unknown
    The status should be failure
  End
End

# _orb_is_available_multiple_option_value
Describe '_orb_is_available_multiple_option_value'
  It 'suceeds for true'
    When call _orb_is_available_multiple_option_value true
    The status should be success
  End

  It 'fails for other'
    When call _orb_is_available_multiple_option_value unknown
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
  declare -A _orb_declared_multiples=([-a]=true)
  declare -A _orb_declared_arg_suffixes=([-f]="1" [-m]="2")

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

# _orb_has_declared_arg_default
Describe '_orb_has_declared_arg_default'
  declare -A _orb_declared_defaults_start_indexes=([-f]=1)
  
  It 'succeeds if has default start index'
    When call _orb_has_declared_arg_default -f
    The status should be success
  End 

  It 'fails if not'
    When call _orb_has_declared_arg_default 1
    The status should be failure
  End 
End

# _orb_has_declared_arg_default_help
Describe '_orb_has_declared_arg_default_help'
  declare -A _orb_declared_default_helps=([-f]=val)
  
  It 'succeeds if has default start index'
    When call _orb_has_declared_arg_default_help -f
    The status should be success
  End 

  It 'fails if not'
    When call _orb_has_declared_arg_default_help 1
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

# _orb_arg_is_multiple
Describe '_orb_arg_is_multiple'
  declare -A _orb_declared_multiples=([-f]=true)
  
  It 'succeeds if multiple is true'
    When call _orb_arg_is_multiple -f
    The status should be success
  End 

  It 'fails if not'
    When call _orb_arg_is_multiple -a
    The status should be failure
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

