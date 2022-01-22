Include lib/utils/argument.sh
Include lib/helpers/declaration/argument_options.sh

# _orb_is_available_option
Describe '_orb_is_available_option'
  _orb_raise_invalid_declaration() { echo "$@"; exit 1; }

  It 'suceeds for Default:'
    When call _orb_is_available_option Default:
    The status should be success
  End

  It 'fails for other'
    When call _orb_is_available_option Unknown:
    The status should be failure
  End
End

# _orb_is_catch_all_option
Describe '_orb_is_catch_all_option'
  It 'suceeds for Default:'
    When call _orb_is_catch_all_option Default:
    The status should be success
  End

  It 'suceeds for In:'
    When call _orb_is_catch_all_option In:
    The status should be success
  End

  It 'fails for other'
    When call _orb_is_catch_all_option Comment:
    The status should be failure
  End
End

# _orb_is_invalid_boolean_flag_option
Describe '_orb_is_invalid_boolean_flag_option'
  It 'suceeds for In:'
    When call _orb_is_invalid_boolean_flag_option In:
    The status should be success
  End

  It 'fails for other'
    When call _orb_is_invalid_boolean_flag_option Default:
    The status should be failure
  End
End

# _orb_is_invalid_array_option
Describe '_orb_is_invalid_array_option'
  It 'suceeds for In:'
    When call _orb_is_invalid_array_option In:
    The status should be success
  End

  It 'fails for other'
    When call _orb_is_invalid_array_option Default:
    The status should be failure
  End
End

# _orb_declared_arg_is_boolean_flag
Describe '_orb_declared_arg_is_boolean_flag'
  _orb_declared_args=(-f -a 1)
  _orb_declared_arg_suffixes=(2 "" "")

  It 'suceeds for flagged arg with empty suffix'
    When call _orb_declared_arg_is_boolean_flag 1
    The status should be success
  End

  It 'fails for flagged arg with suffix'
    When call _orb_declared_arg_is_boolean_flag 0
    The status should be failure
  End

  It 'fails for non flag args'
    When call _orb_declared_arg_is_boolean_flag 2
    The status should be failure
  End
End

# _orb_declared_arg_is_array
Describe '_orb_declared_arg_is_array'
  _orb_declared_args=(-f -a ... -b- --)
  _orb_declared_arg_suffixes=(2 "" "" "" "")

  It 'suceeds for flagged arg with suffix > 1'
    When call _orb_declared_arg_is_array 0
    The status should be success
  End

  It 'fails for flagged arg with suffix <= 1'
    When call _orb_declared_arg_is_array 1
    The status should be failure
  End

  It 'suceeds for ...'
    When call _orb_declared_arg_is_array 2
    The status should be success
  End

  It 'suceeds for block'
    When call _orb_declared_arg_is_array 3
    The status should be success
  End

  It 'suceeds for --'
    When call _orb_declared_arg_is_array 4
    The status should be success
  End

  It 'fails for boolean flag'
    When call _orb_declared_arg_is_array 1
    The status should be failure
  End
End
