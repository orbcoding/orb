Include lib/helpers/declaration/general.sh

Describe '_orb_prevalidate_declaration'
  raise_invalid_declaration() { echo "$@"; }

  _orb_declaration=(= value)

  It 'raises invalid declaration if starts with ='
    When call _orb_prevalidate_declaration
    The output should equal "Cannot start with ="
  End
End

Describe '_orb_raise_invalid_declaration'
  orb_raise_error() { echo "$@"; }

  It 'calls raise error with invalid declaration error'
    When call _orb_raise_invalid_declaration "error message"
    The output should equal "Invalid declaration. error message"
  End
End


# Describe '_orb_index_of_declared'
#   It "succeeds if arg in declaration"
#     When call _orb_index_of_declared -q 
#     The status should be success
#     The output should equal 0
#   End

#   It "fails if arg not in declaration"
#     When call _orb_index_of_declared -a
#     The status should be failure
#     The output should equal -1
#   End

#   It "succeeds for flags even if declared with following number"
#     When call _orb_index_of_declared -w
#     The status should be success
#     The output should equal 1
#   End

#   It "works with verbose flags"
#     When call _orb_index_of_declared --verbose-flag
#     The status should be success
#     The output should equal 2
#   End

#   It "works with blocks"
#     When call _orb_index_of_declared -b-
#     The status should be success
#     The output should equal 3
#   End

#   It "works with @"
#     When call _orb_index_of_declared @
#     The status should be success
#     The output should equal 4
#   End

#   It "works with --"
#     When call _orb_index_of_declared --
#     The status should be success
#     The output should equal 5
#   End

#   Context "with other array name input"
#     It "succeeds if arg in declaration"
#       When call _orb_index_of_declared -a _orb_caller_args_declared
#       The status should be success
#       The output should equal 0
#     End

#     It "fails if arg not in declaration"
#       When call _orb_index_of_declared -q _orb_caller_args_declared
#       The status should be failure
#     The output should equal -1
#     End
#   End
# End

# Describe '_orb_caller_index_of_declared'
#   It "returns success if argument in caller declaration"
#     When call _orb_caller_index_of_declared -a 
#     The status should be success
#     The output should equal 0
#   End

#   It "returns success if argument in caller declaration"
#     When call _orb_caller_index_of_declared -q
#     The status should be failure
#     The output should equal -1
#   End
# End
