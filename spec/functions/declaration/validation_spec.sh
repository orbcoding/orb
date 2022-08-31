Include functions/declaration/validation.sh
Include functions/declaration/checkers.sh
Include scripts/call/variables.sh
Include functions/utils/argument.sh
Include functions/help.sh

# _orb_prevalidate_declaration
Describe '_orb_prevalidate_declaration'
  raise_invalid_declaration() { echo "$@"; }

  declaration=(= value)

  It 'raises invalid declaration if starts with ='
    When call _orb_prevalidate_declaration
    The output should equal "Cannot start with ="
  End
End

# _orb_raise_invalid_declaration
Describe '_orb_raise_invalid_declaration'
  orb_raise_error() { echo "$@"; }

  It 'calls raise error with invalid declaration error'
    When call _orb_raise_invalid_declaration "error message"
    The output should equal "Invalid declaration. error message"
  End
End

# _orb_raise_undeclared
Describe '_orb_raise_undeclared'
  orb_raise_error() { echo "$@"; }

  It 'calls raise error with undeclared error'
    # When call _orb_raise_undeclared "1"
    # The output should equal "'1' not in args declaration"
  End
End


# _orb_postvalidate_declared_args_options
Describe '_orb_postvalidate_declared_args_options'
  It 'calls _orb_postvalidate_declared_args_options_catchs'
    _orb_postvalidate_declared_args_options_catchs() { echo_fn; }
    When call _orb_postvalidate_declared_args_options
    The status should be success
    The output should equal "_orb_postvalidate_declared_args_options_catchs"
  End
End


# _orb_postvalidate_declared_args_options_catchs
Describe '_orb_postvalidate_declared_args_options_catchs'
  _orb_declared_args=(-f)
  declare -a _orb_declared_catchs=(1 flag block dash 2)
  declare -A _orb_declared_catchs_start_indexes=([-f]=1)
  declare -A _orb_declared_catchs_lengths=([-f]=3)

  It 'succeeds on valid catch values'
    When call _orb_postvalidate_declared_args_options_catchs
    The status should be success
  End

  It 'fails on invalid catch values'
    _orb_raise_invalid_declaration() { echo_fn $@; exit 1; }
    declare -A _orb_declared_catchs_start_indexes=([-f]=0)
    When run _orb_postvalidate_declared_args_options_catchs
    The status should be failure
    The output should equal "_orb_raise_invalid_declaration -f: Invalid catch value: 1. Available values: flag block dash multiple"
  End
End


# _orb_is_valid_arg_option
Describe '_orb_is_valid_arg_option'
  _orb_raise_invalid_declaration() { echo "$@"; return 1; }
  _orb_declared_args=(-f 1 ...)

  It 'suceeds for Default:'
    When call _orb_is_valid_arg_option -f Default:
    The status should be success
  End

  It 'fails for boolean with invalid boolean option'
    When call _orb_is_valid_arg_option -f In:
    The status should be failure
    The output should equal "-f: Invalid option: In:. Available options for boolean flags: Required: Default:"
  End

  It 'succeeds for nr with In:'
    When call _orb_is_valid_arg_option 1 In:
    The status should be success
  End

  It 'fails for ... with invalid array option'
    When call _orb_is_valid_arg_option ... In:
    The status should be failure
    The output should equal "...: Invalid option: In:. Available options for array type arguments: Required: Default: Catch:"
  End
End
