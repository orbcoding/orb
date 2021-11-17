Include namespaces/core/argument.sh

# _is_flag
Describe '_is_flag'
  It 'succeeds with dash (-) flag'
    When call _is_flag -f
    The status should be success
  End

  It 'succeeds with plus (+) flag'
    When call _is_flag +f
    The status should be success
  End

  It 'succeeds with verbose flag (--) flag'
    When call _is_flag --verbose_flag
    The status should be success
  End

  It 'fails with spaces'
    When call _is_flag "-f s"
    The status should be failure
  End

  It 'fails without +/- prefix'
    When call _is_flag f
    The status should be failure
  End
End

# _is_verbose_flag
Describe '_is_verbose_flag'
  It 'succceeds with two dashes (--) flag'
    When call _is_verbose_flag --verbose_flag
    The status should be success
  End

  It 'can start with plus (+-)'
    When call _is_verbose_flag +-verbose_flag
    The status should be success
  End

  It 'fails on single dash flags'
    When call _is_verbose_flag -f
    The status should be failure
  End

  It 'fails with spaces'
    When call _is_verbose_flag "--verbose flag"
    The status should be failure
  End
End


# _is_flagged_arg
Describe '_is_flagged_arg'
  It 'succeeds with dash (-) flag arg'
    When call _is_flagged_arg "-f arg"
    The status should be success
  End

  It 'succeeds with verbose flag (--) flag arg'
    When call _is_flagged_arg "--verbose_flag arg"
    The status should be success
  End

  It 'fails with plus (+) flag arg'
    When call _is_flagged_arg "+f arg"
    The status should be failure
  End

  It 'fails without +/- prefix flag arg'
    When call _is_flagged_arg "f arg"
    The status should be failure
  End
End

# _is_nr
Describe '_is_nr'
  It 'succeeds with numbers'
    When call _is_nr 1231098
    The status should be success
  End

  It 'fails with spaces'
    When call _is_nr "1 1"
    The status should be failure
  End

  It 'fails with letters'
    When call _is_nr "1a1"
    The status should be failure
  End
End

# _is_block
Describe '_is_block'
  It 'succeeds with -b-'
    When call _is_block -b-
    The status should be success
  End

  It 'succeeds with longer name -long_orb_block-'
    When call _is_block "-long_orb_block-2-"
    The status should be success
  End

  It 'fails with spaces'
    When call _is_block "-b -"
    The status should be failure
  End
End

# _is_wildcard
Describe '_is_wildcard'
  It 'accepts *'
    When call _is_wildcard '*'
    The status should be success
  End

  It 'accepts -- *'
    When call _is_wildcard '-- *'
    The status should be success
  End

  It 'fails if not wildcard'
    When call _is_wildcard random
    The status should be failure
  End
End
